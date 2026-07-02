#!/usr/bin/env python3
import os
import sys
import time
import json
import array
import shutil
import signal
import hashlib
import zipfile
import argparse
import subprocess
from typing import *
import urllib.request
from dataclasses import *

FRIDA_VERSION = 6

class FridaException(Exception):
	def __init__(self, message: str):
		self.message = message
	def add_unwind_action(self, action):
		self.message = f"{action}\n{self.message}"

def unwind_action(adder):
	def decorator(func):
		def wrapper(*args, **kwargs):
			try:
				func(*args, **kwargs)
			except FridaException as e:
				e.add_unwind_action(adder(*args, **kwargs))
				raise e
		return wrapper
	return decorator

	
### dependency management ### 

class DependencyFetchException(FridaException):
	pass

def lockfile_set(cli_frida_root: str, dependency: str, value: str):
	print(f"Locking {dependency}: {value}")
	if not os.path.isfile(f"{cli_frida_root}/frida.lock"):
		lock = dict()
	else:
		try:
			with open(f"{cli_frida_root}/frida.lock", "r") as f:
				lock = json.load(f)
		except:
			raise DependencyFetchException("Failed to read lockfile/it is invalid")
	lock[dependency] = value
	with open(f"{cli_frida_root}/frida.lock", "w") as f:
		json.dump(lock, f)

def lockfile_get(cli_frida_root, dependency: str) -> str | None:
	if os.path.isfile(f"{cli_frida_root}/frida.lock"):
		try:
			with open(f"{cli_frida_root}/frida.lock", "r") as f:
				lock = json.load(f)
		except:
			raise DependencyFetchException("Failed to read lockfile/it is invalid")
		if dependency in lock:
			return lock[dependency]
	return None

def path_explore_downwards(path: str, amount: int) -> str:
	if amount <= 0:
		return path
	ls = os.listdir(path)
	if len(ls) == 1 and os.path.isdir(f"{path}/{ls[0]}"):
		return path_explore_downwards(f"{path}/{ls[0]}", amount - 1)
	raise DependencyFetchException("Wrong amount of zip wrappers set for this dependency")
		
class Dependency():
	def __init__(self):
		self.path_offset = ""
		pass
	def get_path(self, dotfrida) -> str:
		return ""
	def needs_download(self) -> bool:
		return True
	def get_zip_url(self, cli_frida_root) -> str:
		return ""
	def get_zip_wrappers(self) -> int:
		return 0
	def get_frida_root_candidate_paths(self, path: str) -> list[str]:
		path = path_explore_downwards(path, self.get_zip_wrappers())
		if self.path_offset != "":
			return [f"{path}/{self.path_offset}", f"{path}/{self.path_offset}/g3man"]
		else:
			return [path, f"{path}/g3man"]
		
class PathDependency(Dependency):
	def __init__(self, path):
		self.path = path
		self.path_offset = ""
	def get_path(self, dotfrida) -> str:
		return self.path
	def needs_download(self) -> bool:
		return False
	def __str__(self):
		return f"path:{self.path}"


class GitHubTagDependency(Dependency):
	def __init__(self, user: str, repo: str, path_offset : str, tag: Optional[str]):
		self.user = user
		self.repo = repo
		self.tag = tag
		self.path_offset = path_offset
	def get_path(self, dotfrida) -> str:
		return f"{dotfrida}/deps/github-{self.user}-{self.repo}"

	def get_zip_url(self, cli_frida_root) -> str:
		if self.tag == None:
			early = lockfile_get(cli_frida_root, str(self))
			if early is not None:
				tag_name = early
			else:
				url = f"https://api.github.com/repos/{self.user}/{self.repo}/releases/latest"
				try:
					with urllib.request.urlopen(url) as response:
						content = json.loads(response.read().decode('utf-8'))
						tag_name = content["tag_name"]
				except Exception as e:
					raise DependencyFetchException(f"Failed to fetch latest release of {self}")
				lockfile_set(cli_frida_root, str(self), tag_name)
		else:
			tag_name = self.tag
		return f"https://api.github.com/repos/{self.user}/{self.repo}/zipball/{tag_name}"
	def get_zip_wrappers(self) -> int:
		return 1
	def __str__(self):
		return f"github-tag:{self.user}/{self.repo}"
		
class GitHubCommitDependency(Dependency):
	def __init__(self, user: str, repo: str, branch: str, path_offset : str, commit: Optional[str]):
		self.user = user
		self.repo = repo
		self.branch = branch
		self.commit = commit
		self.path_offset = path_offset
	def get_path(self, dotfrida) -> str:
		return f"{dotfrida}/deps/github-{self.user}-{self.repo}-{self.branch}"
	def get_zip_url(self, cli_frida_root) -> str:
		if self.commit == None:
			early = lockfile_get(cli_frida_root, str(self))
			if early is not None:
				sha = early
			else:
				url = f"https://api.github.com/repos/{self.user}/{self.repo}/branches/{self.branch}"
				try:
					with urllib.request.urlopen(url) as response:
						content = json.loads(response.read().decode('utf-8'))
						commit = content["commit"]
						sha = commit["sha"]
				except Exception as e:
					raise FridaException(f"Failed to fetch latest release of {self}")
				lockfile_set(cli_frida_root, str(self), sha)
		else:
			sha = self.commit
			
		return f"http://api.github.com/repos/{self.user}/{self.repo}/zipball/{sha}"
	def get_zip_wrappers(self) -> int:
		return 1
	def __str__(self):
		return f"github:{self.user}/{self.repo}/{self.branch}"


def parse_dependency_or_return_string_error(dependency):
	parts = dependency.split(':', 1)
	if dependency.strip() == "" or len(parts) == 1:
		return f"Dependency {dependency} does not have a prefix. You need to specify a prefix, like \"path:\", or \"github-tag:\"."
	
	arg_parts = parts[1].rsplit('?', 1)
	args = dict()
	if len(arg_parts) == 2:
		assignments = arg_parts[1].split('&')
		for assignment in assignments:
			lr = dependency.split('=', 1)
			if len(lr) != 2:
				return f"Dependency {dependency} has invalid argument assignment: {assignment}"
			args[lr[0]] = lr[1]
	
	
	prefix = parts[0]
	if prefix == "path":
		path = parts[1]
		return PathDependency(path)
	if prefix == "github-tag":
		subparts = parts[1].split('/')
		
		if len(subparts) == 2:
			user = subparts[0]
			repo = subparts[1]
			return GitHubTagDependency(user, repo, args.get("frida_root", ""), args.get("tag"))
		else:
			return f"Dependency {dependency}'s content should be of the form \"user/repo\""
	if prefix == "github":
		subparts = parts[1].split('/')
		if len(subparts) == 3:
			user = subparts[0]
			repo = subparts[1]
			branch = subparts[2]

			return GitHubCommitDependency(user, repo, branch, args.get("frida_root", ""), args.get("commit"))
		else:
			return f"Dependency {dependency}'s content should be of the form \"user/repo/branch\""


def parse_project_dependencies(arr, issues, _):
	parsed_dependencies = []
	for dependency in arr:
		ret = parse_dependency_or_return_string_error(dependency)
		if type(ret) == str:
			issues.append(ret)
		else:
			parsed_dependencies.append(ret)
	return parsed_dependencies

### frida configs ### 

## project config ##

def non_blank_string(string: str, issues, field_name):
	if string.strip() == "":
		issues.append(f"{field_name} cannot be a blank string, if provided")
	return string

@dataclass
class Issues:
	critical: list[str]
	non_critical : list[str]
	def has_critical_issues(self):
		return len(self.critical) > 0
	def issues_as_string(self, filename):
		str = f"Issues found with {filename}:\n"
		i = 1
		for issue in self.critical:
			str += f"{i}. {issue}\n"
			i += 1
		return str
	def print_issues(self, filename):
		print(self.issues_as_string(filename))


project_config_template = """// This file is the project config. This file isn't personal to any user and should be shared by everyone working on this mod.
//
// You *can* use backslashes when filling out paths, but they must be escaped, i.e. you have to write "\\" instead of "\" every time.
// Save yourself the hassle and use forward slashes.
//
// Frida wiki entry: https://github.com/skirlez/frida/wiki/Project-Config
{
	// Name that gets printed out when Frida mentions this project.
	// It is not important.
	"name": "",

	// Example build strategy for GameMaker (gms2 and above) projects:
	"build": {
		// Where to export the project's datafile inside the output mods folder.
		// This path is usually set to "(your mod's ID)/mod_data.win"
		// So then you can reference it in your mod.json file.
		"export_path": "",
		
		"type": "gms2",
		"options": {
			// (Relative!) path to the GameMaker project.
			"project_path": "",
			// Runtime version this project was made for
			"runtime_version": "",
		},
	},

	// Testing profile:
	// When you apply your mod to the game using `frida.py apply`,
	// frida generates a profile using the following block.
	"profile": {
		// Mod order/priority
		// You should put the ID of your mod and its dependencies here.
		// Earlier in the list means higher priority.		
		"mod_order": ["mod_id_here"],
	},

	// Don't change this number.
	"format_version": 2,
}
"""

@dataclass(eq=False) # need eq=False for dicts
class ProjectConfig:
	name : str
	
	@dataclass
	class Profile:
		mod_order : list[str]
		modded_save_name: str | None = field(default=None, metadata={"type_override": str, "pass_through": non_blank_string, "optional": True})
		name: str = field(default_factory=lambda : "Frida testing profile", metadata={ "optional": True })
		id: str = field(default_factory=lambda : "frida_testing_profile", metadata={ "optional": True })
		description: str = field(default_factory=lambda : "", metadata={ "optional": True })
		
	profile : Profile = field(metadata={"contract": Profile })
	
	@dataclass
	class Publish:
		exclude: list[str] = field(default_factory=list, metadata={"optional": True})
		as_profile: bool = field(default=False, metadata={"optional": True})
	publish: Publish = field(default_factory=lambda: ProjectConfig.Publish(), metadata={"contract": Publish, "optional": True})
	
	@dataclass
	class Fetch:
			dependencies: list[Dependency] = field(default_factory=list,
				metadata={"optional": True, 
				"pass_through_initial_type": list[str], 
				"pass_through": parse_project_dependencies}
			)
			recursive: bool = field(default=True, metadata={"optional": True})

	fetch : Fetch = field(default_factory=lambda: ProjectConfig.Fetch(), metadata={"contract": Fetch, "optional": True})

	
	@dataclass
	class Build:
		@dataclass
		class GMS2Options:
			project_path : str
			runtime_version : str
			configuration: str = field(default_factory=lambda : "Default", metadata={"optional": True})
			included_files_export_path : str | None = field(default=None, metadata={"type_override": str, "optional": True})
		
		export_path : str
		options : GMS2Options = (
			field(metadata= {
				"contract_switch_field": "type",
				"contract_switch_map" : {
					"gms2" : GMS2Options,
				}
			}
		))

	build : Build | None = field(default=None, metadata={"contract": Build, "optional": True})



		
@dataclass
class Project:
	config : ProjectConfig
	frida_root : str
	
## user config ##

user_config_template = """// This file is the user config. This file is personal to you and your computer, and should not be shared with others or committed with Git.
//
// You *can* use backslashes when filling out paths, but they must be escaped, i.e. you have to write "\\" instead of "\" every time.
// Save yourself the hassle and use forward slashes.
//
// Frida wiki entry: https://github.com/skirlez/frida/wiki/User-Config
{
	// Fill this part out if you want to build GameMaker (gms2 and above) projects.
	"gms2": {
		// Linux: Likely is /home/USER/.local/share/GameMakerStudio-Beta/Cache
		// Windows: Likely is C:/ProgramData/GameMakerStudio2/Cache
		"cache_path": "",
	},

	// Fill this part out if you want to be able to apply your mod to the game using Frida. Or delete this whole block if you don't want that.
	"apply": {
		// The path to g3man's executable file.
		// https://github.com/skirlez/g3man/releases		
		"g3man_path": "",
		
		"game_path": "",

		// The name of the new datafile g3man will put in the game folder, with mods applied to it.
		"output_datafile_name": "data.win",
		
		// Path to the game's clean/unmodified/vanilla datafile.
		// Take notice: It is recommended to not just put the game's datafile (data.win) here, it can easily get modified
		// by accident. It's better to copy the clean version of it elsewhere, and provide the path to that location.
		"clean_datafile_path": "",
	},

	"check_for_updates": true,  
	"format_version": 2
}
"""

@dataclass
class UserConfig:
	check_for_updates: bool

	@dataclass
	class Gms2:
		cache_path : str
		#user_directory_or_license_path : str
	gms2 : Gms2 | None =  field(default=None, metadata={"contract": Gms2, "optional": True})

	@dataclass
	class Apply:
		g3man_path: str
		game_path: str
		clean_datafile_path: str
		output_datafile_name: str = field(default="g3man_data.win", metadata={"pass_through": non_blank_string, "optional": True})
		@dataclass
		class ExeLaunchOptions:
			path: str
		@dataclass
		class SteamLaunchOptions:
			app_id : int
			steam_executable_path: str
		launch_options : ExeLaunchOptions | SteamLaunchOptions | None = (
			field(default=None, metadata = {
				"contract_switch_field": "launch_type",
				"contract_switch_map" : {
					"steam" : SteamLaunchOptions,
					 "executable" : ExeLaunchOptions 
				},
				"optional": True,
			}
		))
	apply : Apply | None = field(default=None, metadata={"contract": Apply, "optional": True})


def type_name(atype):
	if (get_origin(atype) is list):
		return f"a list of {type_name(get_args(atype)[0])}"
	elif get_origin(atype) is None:
		if atype == list:
			return "a list of unknown type"
		if atype == str:
			return "a string"
		if atype == int:
			return "an integer"
		if atype == bool:
			return "a boolean"
		return atype.__name__
def conforms(value, expected_type):
	if (type(value) is expected_type):
		return True

	if (get_origin(expected_type) is list):
		if (len(value) == 0):
			return True
		if (get_args(expected_type))[0] == type(value[0]):
			return True
	return False


def construct_with_issues(json: dict[str, Any], dataclass: type, issues: list[str], prefix = ""):
	# allows us to set attributes despite types being frozen
	# (ended up not freezing the dataclasses but whatever)
	set_attribute = object.__setattr__
	
	instance: Any = object.__new__(dataclass)
	def type_error(key, expected, got):
		return f"\"{prefix}{key}\" is of the wrong type: It should be {type_name(expected)}, but it's {type_name(got)}"
	for field in fields(dataclass):
		key = field.name
		ftype = field.type
		
		if key not in json:
			if not field.metadata.get("optional", False):
				issues.append(f"\"{prefix}{key}\" is missing")
			else:
				if not (field.default is MISSING):
					set_attribute(instance, key, field.default)
				else:
					assert field.default_factory is not MISSING
					set_attribute(instance, key, field.default_factory())
			# TODO: report as missing recursively any non-optional field under this guy
			continue

		if "type_override" in field.metadata:
			ftype = field.metadata["type_override"]
		if "contract" in field.metadata:
			if (type(json[key]) is not dict):
				print("her")
				issues.append(type_error(key, ftype, type(json[ftype])))
				continue
			result = construct_with_issues(json[key], field.metadata["contract"], issues, f"{prefix}{key}.")
			set_attribute(instance, key, result)
			continue
		if "contract_switch_field" in field.metadata:
			assert "contract_switch_map" in field.metadata
			
			if (type(json[key]) is not dict):
				issues.append(type_error(key, dict, type(json[key])))
				continue
			target_field = field.metadata["contract_switch_field"]
			if (target_field not in json):
				issues.append(f"\"{prefix}{key}\" is defined, but the matching field \"{prefix}{target_field}\" is not")
				continue
				
			
			map = field.metadata["contract_switch_map"]
			if json[target_field] not in map:
				issues.append(f"\"{json[target_field]}\" is not a valid value for \"{prefix}{target_field}\". Possible values: {[x for x in map.keys()]}")
				continue
			chosen_dataclass: type = map[json[target_field]]
			result = construct_with_issues(json[key], chosen_dataclass, issues, f"{prefix}{key}.")
			set_attribute(instance, key, result)
			continue
		if "pass_through" in field.metadata:
			if "pass_through_initial_type" in field.metadata:
				initial_type = field.metadata["pass_through_initial_type"]
			else:
				initial_type = ftype
			if not conforms(json[key], initial_type):
				issues.append(type_error(key, ftype, type(json[key])))
				continue
			value = field.metadata["pass_through"](json[key], issues, f"{prefix}{key}")
			set_attribute(instance, key, value)
			continue
		if not conforms(json[key], ftype):
			issues.append(type_error(key, ftype, type(json[key])))
			continue
		set_attribute(instance, key, json[key])
	return instance


def generate_dependency_graph(frida_root, project_config: ProjectConfig) -> dict[ProjectConfig, list[Project]]:
	graph : dict[ProjectConfig, list[Project]] = dict()
	dotfrida = f"{frida_root}/.frida"

	@unwind_action(lambda project_config: f"While fetching dependencies of \"{project_config.name}\"")
	def fill_dependency_graph(project_config: ProjectConfig):
		projects = []
		graph[project_config] = projects
		for dependency in project_config.fetch.dependencies:
			path = dependency.get_path(dotfrida)
			if (not os.path.exists(path)):
				raise FridaException(f"Dependency \"{dependency}\" has not yet been fetched. Please fetch first.")
			candidate_paths = dependency.get_frida_root_candidate_paths(path)
			dependency_project_dict, dependency_frida_root = get_project_dict(path, candidate_paths)
			dependency_project_config, issues = construct_project_config_with_issues(dependency_frida_root, dependency_project_dict)
			if (dependency_project_config is None or issues.has_critical_issues()):
				raise FridaException(f"Dependency \"{dependency}\" has issues:\n{issues.issues_as_string("frida-project-config.jsonc")}")

			projects.append(Project(dependency_project_config, dependency_frida_root))
			fill_dependency_graph(dependency_project_config)
		
	fill_dependency_graph(project_config)
	return graph
	
### building project ### 

def hash_file(full_path: str, relative_path: str, hash_func):
	hash_func.update(relative_path.encode())
	with open(full_path, 'rb') as f:
		for chunk in iter(lambda: f.read(4096), b''):
			hash_func.update(chunk)

def hash_gamemaker_project(project_path: str, yyp_file: str):
	with open(yyp_file, 'r') as f:
		json_str = f.read() # todo: make a function to just strip trailing commas
	yyp_json = json.loads(strip_comments_and_trailing_commas(json_str))
	interesting_folders = set()
	for resource in yyp_json["resources"]:
		unwrapped = resource["id"]
		path: str = os.path.normpath(unwrapped["path"])
		interesting_folders.add(path.split(os.path.sep)[0])

	interesting_folders.add("options")

	# todo: this should parse the yyp
	interesting_folders.add("datafiles")
	
	project_folder = os.path.abspath(project_path)
	normalized_ignored_files = []

	hash_func = hashlib.md5()
	hash_file(yyp_file, os.path.basename(yyp_file), hash_func)
	for interesting_folder in sorted(list(interesting_folders)):
		if not os.path.exists(f"{project_path}/{interesting_folder}"):
			continue
		for root, directories, files in os.walk(f"{project_path}/{interesting_folder}", followlinks=True):
			relative_root = os.path.relpath(root, project_folder)
			i = 0
			length = len(directories)
			while (i < length):
				if os.path.normpath(f"{relative_root}/{directories[i]}") in normalized_ignored_files:
					del directories[i]
					i -= 1
					length -= 1
				i += 1
			for file_path in sorted(files):
				full_path = os.path.join(root, file_path)
				relative_path = os.path.relpath(full_path, project_folder)
				hash_file(full_path, relative_path, hash_func)

	return hash_func.hexdigest()

def get_yyp_filename(path):
	for filename in os.listdir(path):
		if filename.endswith(".yyp"):
			return filename
			
	raise FridaException(f"No .yyp file found in {path}")
def build_routine(cli_frida_root: str, frida_root: str, project_config: ProjectConfig, user_config : UserConfig, dependency_graph: dict[ProjectConfig, list[Project]], should_build_dependencies = True, force_build = False, verbose = False):
	if (project_config.build is not None):
		build_config = project_config.build
		assert type(build_config.options) is ProjectConfig.Build.GMS2Options
		if (user_config.gms2 is None):
			raise FridaException("Tried to build gms2 project, but gms2 user config is missing.")
		build_gamemaker_project(cli_frida_root, frida_root, build_config.options, user_config.gms2, force_build=force_build, verbose=verbose)
	if not should_build_dependencies:
		return
	for dependency in dependency_graph[project_config]:
		if (dependency.config.build is not None):
			build_routine(cli_frida_root, dependency.frida_root, dependency.config, user_config, dependency_graph, should_build_dependencies=project_config.fetch.recursive, force_build=force_build, verbose=verbose)


def build_gamemaker_project(
		cli_frida_root: str,
		frida_root: str,
		build_options: ProjectConfig.Build.GMS2Options, 
		gms2_user_config: UserConfig.Gms2,
		force_build = False,
		verbose=False):

	dotfrida = os.path.abspath(f"{cli_frida_root}/.frida")
	gamemaker_project_path = f"{frida_root}/{build_options.project_path}"
	yyp_filename = get_yyp_filename(gamemaker_project_path)
	
	project_hash = hash_gamemaker_project(gamemaker_project_path, f"{gamemaker_project_path}/{yyp_filename}")
	project_name = yyp_filename.removesuffix(".yyp")
	yyp_path = os.path.abspath(f"{gamemaker_project_path}/{yyp_filename}")
	
	if (not force_build):
		if (os.path.isfile(f"{dotfrida}/gmac/outputs/{project_name}/hash.txt")):
			try:
				with open(f"{dotfrida}/gmac/outputs/{project_name}/hash.txt", 'r') as f:
					previous_hash = f.read()
				if previous_hash != "":
					if project_hash == previous_hash:
						return			
			except:
				pass

	print(f"Building GameMaker project: \"{yyp_filename}\"")
	
	if os.name == "posix":
		GMAC_OS="linux"
		GMAC_DATAFILE_EXT="unx"
	elif os.name == "nt":
		GMAC_OS="windows"
		GMAC_DATAFILE_EXT="win"

	runtime_path = f"{gms2_user_config.cache_path}/runtimes/runtime-{build_options.runtime_version}"
	gmac_path = f"{runtime_path}/bin/assetcompiler/{GMAC_OS}/x64/GMAssetCompiler"
	
	try:
		outputs_folder = f"{dotfrida}/gmac/outputs/{project_name}"	
		cache_folder = f"{dotfrida}/gmac/cache/{project_name}"	
		temp_folder = f"{dotfrida}/gmac/temp"

		for folder in [temp_folder, cache_folder, outputs_folder]:
			os.makedirs(folder, exist_ok=True)
			
		for folder in [temp_folder, outputs_folder]:
			for entry in os.listdir(folder):
				full_path = f"{folder}/{entry}"
				if os.path.isfile(full_path):
					os.remove(full_path)
				else:
					shutil.rmtree(full_path)
		
	except Exception as e:
		raise FridaException(f"Failed to set up build folders:\n{e}")
		
	try:
		# these arguments are copied from how the IDE runs gmac. Comments are mostly from gmac's help command.
		program = subprocess.Popen(
			[gmac_path, 
				"/c", # "do not display gui compile only"
				"/cvm", # compile to vm (YYC otherwise?) 
				"/zpex", # "enable zp mode" (tries loading kernel32 otherwise?)
				"/cins", # case insensitive
				"/nru", # NoRemoveUnused
				# "target mask". I found documentation for it in https://github.com/YAL-GMEdit/builder/blob/master/BuilderCompile.js, (thanks YAL)
				# 1<<6 is windows, which is what we'll leave it at for now
				f"/tgt={1<<6}",
				"/mv=1", # "major version"
				"/iv=0", # "minor version"
				"/rv=0", # "release version"
				"/bv=0", # "build version"
				"/j=8", # number of processors to use for parallel tasks (TODO: why not increase this to 16)
				"/sh=True", # enable / disable Short Circuit evaluation on VM 
				#	f"/zpuf={gms2_user_config.user_directory_or_license_path}", "zp user folder"
				f"/td={temp_folder}", # "temp base directory"
				f"/cd={cache_folder}", # cache directory
				f"/o={outputs_folder}", # output directory (we later take the datafile outside this folder)
				f"/rtp={runtime_path}", # runtime path
				f"/cfg={build_options.configuration}",
				"/rt=v", # "runtime" (no idea)
				f"/m={GMAC_OS}", # "set machine type"
				yyp_path,
			],
			cwd = f"{dotfrida}/gmac",
			text=True,
			stdout=subprocess.PIPE,
		)
	except Exception as e:
		raise FridaException(f"Failed to launch asset compiler:\n{e}")

	assert program.stdout is not None
	errors = []
	for line in program.stdout:
		if verbose:
			print(line, end="")
		if line.startswith("Error : "):
			errors.append(line.rstrip())

	returncode = program.wait()

	if (returncode != 0):
		if (len(errors) != 0):
			raise FridaException(f"Asset compiler gave return code {returncode}, with the following errors: \n{'\n'.join(errors)}")
		else:
			raise FridaException(f"Asset compiler gave return code {returncode}, with no errors")
	if not os.path.exists(f"{outputs_folder}/{project_name}.{GMAC_DATAFILE_EXT}"):
		raise FridaException(f"Building failed to produce a datafile. Report this as an error!")

	try:
		outputs = os.listdir(outputs_folder)
		if (len(outputs) != 1):
			os.mkdir(f"{outputs_folder}/included_files")
			for entry in outputs:
				if entry != f"{project_name}.{GMAC_DATAFILE_EXT}":
					shutil.move(f"{outputs_folder}/{entry}", f"{outputs_folder}/included_files")
		else:
			if (build_options.included_files_export_path is not None):
				raise FridaException(
									"Build error: Project config has \"build.options.included_files_export_path\" set"
									f" to {build_options.included_files_export_path}, but the build produced no included files.")
			
		shutil.move(f"{outputs_folder}/{project_name}.{GMAC_DATAFILE_EXT}", f"{outputs_folder}/datafile")
			
		with open(f"{outputs_folder}/hash.txt", 'w') as f:
			f.write(project_hash)
	except Exception as e:
		raise FridaException(f"Error occurred after building:\n{e}")			



def make_profile_json_dict(profile: ProjectConfig.Profile):
	p = {}
	p["format_version"] = 2
	p["name"] = profile.name
	p["id"] = profile.id
	
	modded_save_name = profile.modded_save_name
	p["separate_modded_save"] = modded_save_name is not None
	p["modded_save_name"] = "" if modded_save_name is None else modded_save_name
	
	p["mod_order"] = profile.mod_order
	
	p["mods_disabled"] = []
	p["description"] = profile.description
	p["version"] = ""
	p["credits"] = []
	p["links"] = []
	return p

### packaging mod
 
def pack_project(cli_frida_root: str, out_mods_folder: str, frida_root: str, project_config: ProjectConfig, linkbase=False):
	dotfrida = f"{cli_frida_root}/.frida"

	def symlink(target: str, output: str):
		if os.name == "nt":
			os.link(target, output)
		else:
			os.symlink(target, output)

	
	has_true_symlink = (os.name != "nt")
	
	copy_function = shutil.copy2 if not linkbase else symlink
	required_symlink_copy_func = copy_function if has_true_symlink else shutil.copy2
	
	shutil.copytree(f"{frida_root}/base", out_mods_folder, dirs_exist_ok=True, copy_function=copy_function)
	
	if (project_config.build is None):
		return
	match (type(project_config.build.options)):
		case ProjectConfig.Build.GMS2Options:
			options = project_config.build.options
			gamemaker_project_name = get_yyp_filename(f"{frida_root}/{options.project_path}").removesuffix(".yyp")
			
			gmac_results = f"{dotfrida}/gmac/outputs/{gamemaker_project_name}"
			if not os.path.isfile(f"{gmac_results}/hash.txt") or not os.path.isfile(f"{gmac_results}/datafile"):
				raise FridaException(f"Cannot package this project: Build outputs are missing")
				
			export_path = f"{out_mods_folder}/{project_config.build.export_path}"
			if os.path.isdir(export_path):
				export_path += "/mod_data.win"
			shutil.copy(f"{gmac_results}/datafile", export_path)
			if options.included_files_export_path is not None:
				if not os.path.exists(f"{gmac_results}/included_files"):
					raise FridaException(f"Cannot package this project: Included files folder is missing")
				shutil.copytree(f"{gmac_results}/included_files", f"{out_mods_folder}/{options.included_files_export_path}", dirs_exist_ok=True, copy_function=required_symlink_copy_func)


def pack_subroutine(cli_frida_root: str, out_profile_folder : str, frida_root: str, project_config: ProjectConfig, 
		dependency_graph: dict[ProjectConfig, list[Project]], linkbase=False):
	print(f"Packing: {project_config.name}")
	pack_project(cli_frida_root, 
					out_profile_folder,
					frida_root,
					project_config,
				 	linkbase=linkbase)

	for dependency in dependency_graph.get(project_config, []):
		pack_subroutine(cli_frida_root, out_profile_folder, dependency.frida_root, dependency.config, dependency_graph, linkbase=linkbase)


def pack_routine(cli_frida_root: str, project_config: ProjectConfig, dependency_graph : dict[ProjectConfig, list[Project]], linkbase=False):
	out_folder = f"{cli_frida_root}/out"
	out_mods_folder = f"{out_folder}/mods"

	if os.path.isdir(out_folder):
		shutil.rmtree(out_folder)
	os.makedirs(out_folder, exist_ok=True)
	pack_subroutine(cli_frida_root, out_mods_folder, cli_frida_root, project_config, dependency_graph, linkbase=linkbase)

	profile_json = make_profile_json_dict(project_config.profile)
	
	os.mkdir(f"{out_folder}/jsons")
	with open(f"{out_folder}/jsons/profile.json", "wt") as f:
		json.dump(profile_json, f)


def publish_as_zip(cli_frida_root, project_config: ProjectConfig):
	out_folder = f"{cli_frida_root}/out"
	out_mods_folder = f"{out_folder}/mods"
	
	if os.path.exists(f"{cli_frida_root}/out.zip"):
		os.remove(f"{cli_frida_root}/out.zip")
	normalized_zip_exclude = [os.path.normpath(path) for path in project_config.publish.exclude]
	
	if project_config.publish.as_profile:
		with open(f"{out_folder}/jsons/profile.json", "rt") as f:
			profile_json = json.load(f)
			profile_id = profile_json["id"]
		zip_filename = profile_id
		prepend_relative_root = f"{profile_id}/"
	else:
		zip_filename = "out"
		prepend_relative_root = ""


	zip_full_path = f"{out_folder}/{zip_filename}.zip"
	with zipfile.ZipFile(zip_full_path, "w") as f:
		if project_config.publish.as_profile:
			f.write(f"{out_folder}/jsons/profile.json", f"{profile_id}/profile.json")
		for root, directories, files in os.walk(out_mods_folder, followlinks=True):
			relative_root = prepend_relative_root + os.path.relpath(root, out_mods_folder)

			length = len(directories)
			i = 0
			while (i < length):
				if os.path.normpath(f"{relative_root}/{directories[i]}") in normalized_zip_exclude:
					del directories[i]
					i -= 1
					length -= 1
				i += 1
			
			for file in files:
				archive_path = f"{relative_root}/{file}"
				if os.path.normpath(archive_path) not in normalized_zip_exclude:
					f.write(f"{root}/{file}", f"{relative_root}/{file}")
	return os.path.relpath(zip_full_path, cli_frida_root)


### applying mod ###

def make_game_json_dict(apply: UserConfig.Apply):
	p = {}
	p["format_version"] = 2
	p["display_name"] = ""
	p["internal_name"] = ""
	p["datafile_name"] = ""

	p["executable_type"] = 0
	p["executable_path"] = ""
	p["executable_steam_app_id"] = -1
	match type(apply.launch_options):
		case UserConfig.Apply.ExeLaunchOptions:
			assert type(apply.launch_options) is UserConfig.Apply.ExeLaunchOptions
			p["executable_type"] = 0
			p["executable_path"] = apply.launch_options.path
		case UserConfig.Apply.SteamLaunchOptions:
			assert type(apply.launch_options) is UserConfig.Apply.SteamLaunchOptions
			p["executable_type"] = 1
			p["executable_steam_app_id"] = apply.launch_options.app_id
	p["output_datafile_name"] = apply.output_datafile_name
	return p

	
def apply_routine(cli_frida_root, apply_config: UserConfig.Apply, launch: bool):
	game_json = make_game_json_dict(apply_config)
	out_folder = f"{cli_frida_root}/out"
	with open(f"{out_folder}/jsons/game.json", "w") as f:
		json.dump(game_json, f)

	
	print("Applying the mod(s)")

	bonus_launch_arguments = []
	
	if launch:
		if apply_config.launch_options is None:	
			raise FridaException("Cannot launch without \"apply.launch_options\" being defined in the user config.")
		bonus_launch_arguments.append("--launch")
		if type(apply_config.launch_options) is UserConfig.Apply.SteamLaunchOptions:
			bonus_launch_arguments.append("--steam")
			bonus_launch_arguments.append(apply_config.launch_options.steam_executable_path)
	try:
		status = subprocess.run(
			[apply_config.g3man_path, "apply",
				"--game-json", f"{out_folder}/jsons/game.json",	
				"--game-folder", apply_config.game_path,	
				"--profile-json", f"{out_folder}/jsons/profile.json",	
				"--mods-folder", f"{out_folder}/mods",
				"--clean_data", apply_config.clean_datafile_path
			] + bonus_launch_arguments,
			
			cwd = ".")
	except Exception as e:
		print("Failed to launch g3man. Do you have all your variables set correctly?\n" + str(e))
		return
	if (status.returncode != 0):
		print("Something failed in g3man. Aborting.")
		print(f"Args passed in: {status.args}")
		exit()

### cli


def strip_comments_and_trailing_commas(str: str):
	build = list()
	state = 0
	last_seen_comma = -1
	for i in range(len(str) - 1):
		if state == 0:
			# "normal" state
			if str[i] == '/' and str[i + 1] == '/':
				state = 1
			elif str[i] == '/' and str[i + 1] == '*':
				state = 2
			elif str[i] == '"':
				build += '"'
				state = 3
			else:
				build += str[i]
				if str[i] == ',':
					last_seen_comma = len(build) - 1
				if last_seen_comma != -1 and (str[i + 1] == ']' or str[i + 1] == '}'):
					found = False
					for j in range(last_seen_comma + 1, len(build) - 1):
						if not build[j].isspace():
							found = True
							break
					if not found:
						build[last_seen_comma] = ' ';
						last_seen_comma = -1
		elif state == 1:
			# inside a line comment
			build += ' '
			if str[i + 1] == '\n':
				state = 0
		elif state == 2:
			# inside a multi line comment
			if str[i - 1] == '*' and str[i] == '/':
				state = 0
			elif str[i] == '\n':
				build += '\n'
			else:
				build += ' '
		elif state == 3:
			# inside a string
			build += str[i]
			if str[i] == '"':
				state = 0
	if state == 0 or state == 3:
		build += str[len(str) - 1]
	return ''.join(build)


def check_frida_root_candidates(paths: list[str]) -> str:
	for path in paths:
		if os.path.exists(f"{path}/frida-project-config.jsonc"):
			return path
	raise FridaException(f"No project config exists in any candidate path: {paths}")

def get_project_dict(path: str, candidate_paths = None):
	if (candidate_paths is None):
		candidate_paths = [path, f"{path}/g3man"]
	frida_root = check_frida_root_candidates(candidate_paths)
	frida_root = os.path.abspath(frida_root)
	try:
		with open(f"{frida_root}/frida-project-config.jsonc") as f:
			json_string = strip_comments_and_trailing_commas(f.read())
			project_dict = json.loads(json_string)
			return project_dict, frida_root
	except Exception as e:
		raise FridaException(f"Error while reading project config:\n{e}")

def get_user_dict(frida_root):
	if not os.path.isfile(f"{frida_root}/frida-user-config.jsonc"):
		raise FridaException(f"User config does not exist in {frida_root}")
	try:
		with open(f"{frida_root}/frida-user-config.jsonc") as f:
			json_string = strip_comments_and_trailing_commas(f.read())
			user_dict = json.loads(json_string)
			return user_dict
	except Exception as e:
		raise FridaException(f"Error while reading user config:\n{e}")

def construct_project_config_with_issues(frida_root, dict) -> tuple[ProjectConfig | None, Issues]:
	critical_issues = []
	config: ProjectConfig = construct_with_issues(dict, ProjectConfig, critical_issues)
	if len(critical_issues) != 0:
		return (None, Issues(critical_issues, [])) 
	warnings = []
	if config.build is not None and type(config.build.options) is ProjectConfig.Build.GMS2Options:
		options = config.build.options
		project_path = options.project_path
		if os.path.isabs(project_path):
			absolute_project_path = project_path
		else:
			absolute_project_path = os.path.abspath(f"{frida_root}/{project_path}")

		if not os.path.exists(project_path):
			critical_issues.append(f"The provided folder path \"build.options.project_path\" (\"{project_path}\") does not exist")
		else:
			yyp_filename = get_yyp_filename(absolute_project_path)
			if yyp_filename == "":
				critical_issues.append(f"Could not find any .yyp file in \"build.options.project_path\" (value: \"{project_path}\")")
			if os.path.isabs(project_path):
				warnings.append(f"build.options.project_path is currently set to \"{project_path}\", which is NOT a relative path!"
							+ f"\n(frida suggests: use the relative version \"{os.path.relpath(start=".", path=project_path)}\" instead)")
		
	if os.path.exists(f"{frida_root}/base"):
		unaccounted = [dir for dir in os.listdir(f"{frida_root}/base") if dir not in config.profile.mod_order and os.path.isdir(f"{frida_root}/base/{dir}")]
		if len(unaccounted) != 0:
			warnings.append(f"\"package.profile.mod_order\" is missing some mods that exist in the \"base\" folder: {unaccounted}. g3man will go over these last.")
	return (config, Issues(critical_issues, warnings))
	
def construct_user_config_with_issues(dict) -> tuple[UserConfig | None, Issues]:
	critical_issues = []
	config: UserConfig = construct_with_issues(dict, UserConfig, critical_issues)
	if (len(critical_issues) != 0):
		return (None, Issues(critical_issues, []))
	def validate_file_paths(keys, inst, prefix):
		for key in keys:
			if not os.path.isfile(getattr(inst, key)):
				critical_issues.append(f"The provided file path \"{prefix}{key}\" (\"{getattr(inst, key)}\") does not exist")
	def validate_folder_paths(keys, inst, prefix):
		for key in keys:
			if not os.path.exists(getattr(inst, key)):
				critical_issues.append(f"The provided folder path \"{prefix}{key}\" (\"{getattr(inst, key)}\") does not exist")
	if config.apply is not None:
		validate_file_paths(["g3man_path", "clean_datafile_path"], config.apply, "apply.")
		validate_folder_paths(["game_path"], config.apply, "apply.")
	if config.gms2 is not None:
		validate_folder_paths(["cache_path"], config.gms2, "gms2.")
		if os.path.exists(config.gms2.cache_path) and not os.path.exists(f"{config.gms2.cache_path}/runtimes"):
			critical_issues.append(f"\"gms2.cache_path\" is set to \"{config.gms2.cache_path}\", but that folder does not have a \"runtime\" subfolder.")
	return (config, Issues(critical_issues, []))

timestamp_filename = "update-timestamp.txt"

def should_check_for_update(dotfrida):
	if not os.path.isfile(f"{dotfrida}/{timestamp_filename}"):
		return True
	try:
		with open(f"{dotfrida}/{timestamp_filename}", 'r') as f:
			timestamp = int(f.read())
	except:
		return True

	difference = time.time() - timestamp
	return difference > 0

def save_update_timestamp(offset):
	try:
		os.makedirs(".frida", exist_ok=True)
		with open(f".frida/{timestamp_filename}", 'w') as f:
			f.write(str(int(time.time() + offset)))
	except:
		return True


def check_update(manual = False):
	print("Checking for updates...")
	if not manual:
		print("Remember that you can disable this by setting \"check_for_updates\" to false in frida-user-config.jsonc")
	url = "https://api.github.com/repos/skirlez/frida/releases/latest"
	try:
		with urllib.request.urlopen(url) as response:
			content = json.loads(response.read().decode('utf-8'))
			tag_name = ''.join(c for c in content["tag_name"] if c.isdigit())
			tag_number = int(tag_name)
	except Exception:
		print("Error occured while checking for updates. You should probably check manually. See you tomorrow!")
		save_update_timestamp(86400)
		return

	if tag_number > FRIDA_VERSION:
		print(f"Update found! You are on version {FRIDA_VERSION}, and the latest version is {tag_name}.")
		print("You can update by going to https://github.com/skirlez/frida/releases/latest, downloading the script, and replacing this script with the downloaded one.")
	elif tag_number < FRIDA_VERSION:
		print(f"You are on a future version: Current is version {FRIDA_VERSION}, and the latest version is {tag_name}.")
	else:
		print("You are on the latest version.")
	if not manual:
		print("See you next week!")
	save_update_timestamp(604800)
	

usage = "Usage: frida.py [ACTION] [OPTIONS]..."
def bad_usage():
	print(usage)
	print("Try 'frida.py --help' for more information.")
	exit()

def is_help(arguments):
	return "-h" in arguments or "--help" in arguments

def python_version_routine():
	if sys.version_info.major < 3 or sys.version_info.minor < 12:
		print("Frida requires Python 3.12 at least to run. Your python version: " + str(sys.version_info.major) + "." + str(sys.version_info.minor) + "." + str(sys.version_info.micro))
		exit()

def fetch_routine(cli_frida_root, name, obtain_fetch_config):
	dotfrida = f"{cli_frida_root}/.frida"
	fetch_config: ProjectConfig.Fetch = obtain_fetch_config()
	
	for dependency in fetch_config.dependencies:
		print(f"Fetching: \"{dependency}\"... ")
		path = dependency.get_path(dotfrida)
		if dependency.needs_download():
			if os.path.exists(path):
				
				def normabs(path):
					return os.path.normpath(os.path.abspath(path))
					
				assert os.path.commonpath([normabs(dotfrida), normabs(path)]) == normabs(dotfrida)
				shutil.rmtree(path)
			os.makedirs(path, exist_ok=True)
			try:
				zip_url = dependency.get_zip_url(cli_frida_root)
				urllib.request.urlretrieve(zip_url, f"{dotfrida}/tmp.zip")
				with zipfile.ZipFile(f"{dotfrida}/tmp.zip", "r") as f:
					f.extractall(path)
			except DependencyFetchException as e:
				print("Failed")
				print(f"Failed to fetch {dependency}: {e.message}")
				continue
			except Exception as e:
				print("Failed")
				print(f"Something went wrong while fetching {dependency}: {e}")
				
			try:
				os.remove(f"{dotfrida}/tmp.zip")
			except:
				pass
		
		if fetch_config.recursive:
			try:
				paths = dependency.get_frida_root_candidate_paths(path)
				frida_root = check_frida_root_candidates(paths)
				dependency_project_dict = get_project_dict(frida_root)
				dependency_project_config, issues = construct_project_config_with_issues(frida_root, dependency_project_dict)
				if (dependency_project_config is None or issues.has_critical_issues()):
					raise FridaException(issues.issues_as_string("frida-project-config.jsonc"))
				fetch_routine(cli_frida_root, f"{dependency}", obtain_fetch_config)
			except FridaException as e:
				e.add_unwind_action(f"While fetching dependencies of \"{name}\"")

if __name__ == "__main__":
	python_version_routine()
	# Let me Ctrl+C in peace
	signal.signal(signal.SIGINT, lambda a, b: exit())

	def all_valid_or_print_and_exit(project_config, project_issues, user_config, user_issues):
		if (project_config is None or user_config is None or project_issues.has_critical_issues() or user_issues.has_critical_issues()):
			if project_issues.has_critical_issues():
				project_issues.print_issues("frida-project-config.jsonc")
			elif project_config is None:
				print("Project config is missing!")
			if user_issues.has_critical_issues():
				user_issues.print_issues("frida-user-config.jsonc")
			elif user_config is None:
				print("User config is missing!")
			exit(1)

	parser = argparse.ArgumentParser(prog='frida.py', description='Build and package management tool for g3man projects', epilog
		=
		"""Run 'frida.py [ACTION] -h' to learn about a specific action's arguments.
		For more documentation: https://github.com/skirlez/frida/wiki"""
	)
	parser.add_argument("-v", "--verbose", action="store_true", help="Verbose output")
	subparsers = parser.add_subparsers(title="Actions list", metavar="")

	def init(_):
		if (os.path.exists("frida-project-config.jsonc")):
			print("Project config already exists, skipping...")
		else:
			with (open("frida-project-config.jsonc", "w") as f):
				f.write(project_config_template)
		if (os.path.exists("frida-user-config.jsonc")):
			print("User config already exists, skipping...")
		else:
			with (open("frida-user-config.jsonc", "w") as f):
				f.write(user_config_template)
		
	parser_init = subparsers.add_parser("init", help="Create blank user and project configs")
	parser_init.set_defaults(func=init)
	
	parser_fetch = subparsers.add_parser("fetch", help="Fetch this project's dependencies")

	def fetch(_):
		project_dict, cli_frida_root = get_project_dict(".")
		config, issues = construct_project_config_with_issues(cli_frida_root, project_dict)
		if (config is None or issues.has_critical_issues()):
			issues.print_issues("frida-project-config.jsonc")
			return
		fetch_routine(cli_frida_root, config.name, lambda: config.fetch)
	parser_fetch.set_defaults(func=fetch)
	
	parser_build = subparsers.add_parser("build", help="Build this project and dependencies")
	parser_build.add_argument("-f", "--force", action="store_true", help="Build regardless of last build's hash")

	def build(namespace : argparse.Namespace):
		project_dict, cli_frida_root = get_project_dict(".")
		user_dict = get_user_dict(cli_frida_root)
		project_config, project_issues = construct_project_config_with_issues(cli_frida_root, project_dict)
		user_config, user_issues = construct_user_config_with_issues(user_dict)
		all_valid_or_print_and_exit(project_config, project_issues, user_config, user_issues)
		assert project_config is not None
		assert user_config is not None

		graph = generate_dependency_graph(cli_frida_root, project_config)
		
		build_routine(cli_frida_root, cli_frida_root,
			project_config, 
			user_config,
			graph,
			should_build_dependencies=True, 
			force_build=namespace.force,
			verbose=namespace.verbose)
	parser_build.set_defaults(func=build)

	parser_package = subparsers.add_parser("pack", help="Pack this project and dependencies to a folder")
	def pack(namespace : argparse.Namespace):
		project_dict, cli_frida_root = get_project_dict(".")
		user_dict = get_user_dict(cli_frida_root)
		project_config, project_issues = construct_project_config_with_issues(cli_frida_root, project_dict)
		user_config, user_issues = construct_user_config_with_issues(user_dict)
		all_valid_or_print_and_exit(project_config, project_issues, user_config, user_issues)
		
		assert project_config is not None
		assert user_config is not None

		graph = generate_dependency_graph(cli_frida_root, project_config)
		
		build_routine(cli_frida_root, cli_frida_root,
		 	project_config, 
			user_config, 
			graph,
			should_build_dependencies=True,
			verbose=namespace.verbose)
			
		pack_routine(cli_frida_root, project_config, graph)

		
	#parser_package.add_argument("-z", "--zip", action="store_true", help="After creating the \"out\" folder, compress it into a ZIP (as \"out.zip\")")
	parser_package.set_defaults(func=pack)

	parser_publish = subparsers.add_parser("publish", help="Publish this project and dependencies as a .zip")
	
	def publish(_):
		project_dict, cli_frida_root = get_project_dict(".")
		user_dict = get_user_dict(cli_frida_root)
		project_config, project_issues = construct_project_config_with_issues(cli_frida_root, project_dict)
		user_config, user_issues = construct_user_config_with_issues(user_dict)
		all_valid_or_print_and_exit(project_config, project_issues, user_config, user_issues)
		
		assert project_config is not None
		assert user_config is not None

		graph = generate_dependency_graph(cli_frida_root, project_config)
		
		build_routine(cli_frida_root, cli_frida_root,
		 	project_config, 
			user_config, 
			graph,
			project_config.fetch.recursive)
			
		pack_routine(cli_frida_root, project_config, graph)

		print("Publishing...")
		relative_path = publish_as_zip(cli_frida_root, project_config)
		print(f"Done! Output file is: {relative_path}")
		
	parser_publish.set_defaults(func=publish)

	def apply(namespace : argparse.Namespace):
		project_dict, cli_frida_root = get_project_dict(".")
		user_dict = get_user_dict(cli_frida_root)
		project_config, project_issues = construct_project_config_with_issues(cli_frida_root, project_dict)
		user_config, user_issues = construct_user_config_with_issues(user_dict)
		all_valid_or_print_and_exit(project_config, project_issues, user_config, user_issues)
		
		assert project_config is not None
		assert user_config is not None

		if (user_config.apply is None):
			print("Cannot apply without \"apply\" being filled in the user config.")
			exit(1)

		graph = generate_dependency_graph(cli_frida_root, project_config)
		
		build_routine(cli_frida_root, cli_frida_root,
		 	project_config, 
			user_config, 
			graph,
			project_config.fetch.recursive)
			
		pack_routine(cli_frida_root, project_config, graph, linkbase=namespace.linkbase)
		
		apply_routine(cli_frida_root, user_config.apply, launch=namespace.startgame)

		
	parser_apply = subparsers.add_parser("apply", help="Apply this project and dependencies, and (optionally) launch the game")
	parser_apply.add_argument("-l", "--linkbase", action="store_true", help="Symbolically link files to the \"base\" folder instead of copying. On Windows, this uses hard links.")
	parser_apply.add_argument("-s", "--startgame", action="store_true", help="Start the game after applying.")
	parser_apply.set_defaults(func=apply)
	
	def validate(_):
		project_dict, cli_frida_root = get_project_dict(".")
		user_dict = get_user_dict(cli_frida_root)
		project_config, project_issues = construct_project_config_with_issues(cli_frida_root, project_dict)
		user_config, user_issues = construct_user_config_with_issues(user_dict)
		all_valid_or_print_and_exit(project_config, project_issues, user_config, user_issues)
		print("No issues found!")
	
	parser_validate = subparsers.add_parser("validate", help="Validate config files")
	parser_validate.set_defaults(func=validate)


	def check_updates():
		check_update(manual=True)
	parser_check_updates = subparsers.add_parser("check_updates", help="")
	parser_check_updates.set_defaults(func=check_update)
	
	try:
		args = parser.parse_args()
		args.func(args)	
	except FridaException as e:
		print("*Frida error!*")
		print(e.message)
		exit(1)
