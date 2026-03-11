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
import subprocess
from typing import *
import urllib.request


frida_version = 4

class FridaException(Exception):
	def __init__(self, message: str):
		self.message = message

### global state ###

user_dict: dict[str, Any] = {}
cli_frida_root: str = "."
dotfrida = ".frida"

### dependency management ### 

def lockfile_set(dependency: str, value: str):
	print(f"Locking {dependency}: {value}")
	if not os.path.isfile(f"{cli_frida_root}/frida.lock"):
		lock = dict()
	else:
		with open(f"{cli_frida_root}/frida.lock", "r") as f:
			lock = json.load(f)
	lock[dependency] = value
	with open(f"{cli_frida_root}/frida.lock", "w") as f:
		json.dump(lock, f)

def lockfile_get(dependency: str):
	if os.path.isfile(f"{cli_frida_root}/frida.lock"):
		with open(f"{cli_frida_root}/frida.lock", "r") as f:
			lock = json.load(f)
		if dependency in lock:
			return lock[dependency]
	return None

def path_explore_downwards(path: str, amount: int) -> str:
	if amount <= 0:
		return path
	ls = os.listdir(path)
	if len(ls) == 1 and os.path.isdir(ls[0]):
		return path_explore_downwards(f"{path}/{ls[0]}", amount - 1)
	# not sure what to do in this case
	return path
		
class Dependency():
	def __init__(self):
		self.frida_root = ""
		pass
	def get_path(self) -> str:
		return ""
	def needs_download(self) -> bool:
		return True
	def get_zip_url(self) -> str:
		return ""
	def get_zip_wrappers(self) -> int:
		return 0
	def get_frida_root_candidate_paths(self, path: str) -> list[str]:
		path = path_explore_downwards(path, self.get_zip_wrappers())
		if self.frida_root != "":
			return [f"{path}/{self.frida_root}"]
		else:
			return [path, f"{path}/g3man"]
		
class PathDependency(Dependency):
	def __init__(self, path):
		self.path = path
		self.frida_root = ""
	def get_path(self) -> str:
		return self.path
	def needs_download(self) -> bool:
		return False
	def __str__(self):
		return f"path:{self.path}"

class GitHubTagDependency(Dependency):
	def __init__(self, user: str, repo: str, frida_root : str, tag: Optional[str]):
		self.user = user
		self.repo = repo
		self.tag = tag
		self.frida_root = frida_root
	def get_path(self) -> str:
		return f"{dotfrida}/deps/github-{self.user}-{self.repo}"

	def get_zip_url(self) -> str:
		if self.tag == None:
			early = lockfile_get(str(self))
			if early is not None:
				tag_name = early
			else:
				url = f"https://api.github.com/repos/{self.user}/{self.repo}/releases/latest"
				try:
					with urllib.request.urlopen(url) as response:
						content = json.loads(response.read().decode('utf-8'))
						tag_name = content["tag_name"]
				except Exception as e:
					raise FridaException(f"Failed to fetch latest release of {self}")
				lockfile_set(str(self), tag_name)
		else:
			tag_name = self.tag
		return f"https://api.github.com/repos/{self.user}/{self.repo}/zipball/{tag_name}"
	def get_zip_wrappers(self) -> int:
		return 1
	def __str__(self):
		return f"github-tag:{self.user}/{self.repo}"
		
class GitHubCommitDependency(Dependency):
	def __init__(self, user: str, repo: str, branch: str, frida_root : str, commit: Optional[str]):
		self.user = user
		self.repo = repo
		self.branch = branch
		self.commit = commit
		self.frida_root = frida_root
	def get_path(self) -> str:
		return f"{dotfrida}/deps/github-{self.user}-{self.repo}-{self.branch}"
	def get_zip_url(self) -> str:
		if self.commit == None:
			early = lockfile_get(str(self))
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
				lockfile_set(str(self), sha)
		else:
			sha = self.commit
			
		return f"http://api.github.com/repos/{self.user}/{self.repo}/zipball/{sha}"
	def get_zip_wrappers(self) -> int:
		return 1
	def __str__(self):
		return f"github:{self.user}/{self.repo}/{self.branch}"

class ProjectConfig:
	def __init__(self, config: dict[str, Any], dependencies: list[Dependency]):
		self.gamemaker_project_path = config["gamemaker_project_path"]
		self.gamemaker_runtime_version = config["gamemaker_runtime_version"]
		self.gamemaker_configuration = config["gamemaker_configuration"]
		self.gamemaker_datafile_export_path = config["gamemaker_datafile_export_path"]
		self.gamemaker_included_files_export_path = config["gamemaker_included_files_export_path"]
		self.dependencies = dependencies
		self.recursive_dependencies: bool = config["recursive_dependencies"]
		self.zip_exclude = config["zip_exclude"]
		self.mod_order = config["mod_order"]
		self.modded_save_name = config["modded_save_name"]

### building project ### 

def hash_file(full_path: str, relative_path: str, hash_func):
	hash_func.update(relative_path.encode())
	with open(full_path, 'rb') as f:
		for chunk in iter(lambda: f.read(4096), b''):
			hash_func.update(chunk)

def hash_gamemaker_project(path: str):
	project_folder = os.path.abspath(path)
	listdir = sorted(os.listdir(project_folder))

	ignored_items = ["g3man", ".gitattributes", ".git", ".gitignore", ".frida"]
	for ignored in ignored_items:
		if ignored in listdir:
			listdir.remove(ignored)

	hash_func = hashlib.md5()
	for item in listdir:
		full_item_path = os.path.join(project_folder, item)
		if (os.path.isfile(full_item_path)):
			hash_file(full_item_path, item, hash_func)
			continue
		for root, _, files in os.walk(full_item_path, followlinks=True):
			for file_path in sorted(files):
				full_path = os.path.join(root, file_path)
				relative_path = os.path.relpath(full_path, project_folder)
				hash_file(full_path, relative_path, hash_func)

	return hash_func.hexdigest()

def cleanup():
	if os.path.isdir(f"{dotfrida}/igor/output"):
		print("Deleting .frida/igor/output...")
		shutil.rmtree(f"{dotfrida}/igor/output", ignore_errors=True)

def get_yyp_filename(path):
	for filename in os.listdir(path):
		if filename.endswith(".yyp"):
			return filename
			
	return ""

def build_routine(frida_root: str, project_config: ProjectConfig, should_build_dependencies = True, force_build = False):
	project_path = project_config.gamemaker_project_path
	if project_path != "":
		build_gamemaker_project(frida_root, project_config,
								force_build=force_build)
	
	if not should_build_dependencies:
		return
	for dependency in project_config.dependencies:
		path = dependency.get_path()
		if not os.path.exists(path):
			print(f"Dependency \"{dependency}\" has not yet been fetched. Please fetch it using \"frida.py fetch\".")
			exit()
			
		paths = dependency.get_frida_root_candidate_paths(path)
		dependency_frida_root = check_frida_root_candidates(paths)
		dependency_project_dict = get_project_config(dependency_frida_root)
		dependency_project_config = validation_routine(dependency_frida_root, dependency_project_dict)
		build_routine(dependency_frida_root, dependency_project_config, project_config.recursive_dependencies, force_build=force_build)

def build_gamemaker_project(mod_path: str, project_config: ProjectConfig, force_build = False):
	gamemaker_project_path = f"{mod_path}/{project_config.gamemaker_project_path}"
	yyp_filename = get_yyp_filename(gamemaker_project_path)
	if yyp_filename == "":
		raise FridaException("Provided folder has no .yyp file")
	
	project_hash = hash_gamemaker_project(gamemaker_project_path)
	project_name = yyp_filename.removesuffix(".yyp")
	yyp_path = os.path.abspath(f"{gamemaker_project_path}/{yyp_filename}")
	
	if (not force_build):
		previous_hash = ""
		if (os.path.isfile(f"{dotfrida}/igor/results/{project_name}/hash.txt")):
			with open(f"{dotfrida}/igor/results/{project_name}/hash.txt", 'r') as f:
				previous_hash = f.read()
			if previous_hash != "":
				if project_hash == previous_hash:
					print(f"Previous build hash matches, skipping build for {project_name}...")
					return

	cleanup()
	print(f"---Building GameMaker project: \"{project_name}\"---")
	
	if os.name == "posix":
		IGOR_OS_SUBFOLDER="linux"
		IGOR_TARGETS=["Linux", "Package"]
		IGOR_OUTPUT_PATH="package/assets/game.unx"
		IGOR_ASSETS_FOLDER="package/assets"
		IGOR_ASSETS_FILTER=["options.ini", "icon.png"]
	elif os.name == "nt":
		IGOR_OS_SUBFOLDER="windows"
		IGOR_OUTPUT_PATH="data.win"
		IGOR_TARGETS=["Windows", "PackageZip"]
		IGOR_ASSETS_FOLDER=""
		IGOR_ASSETS_FILTER=["options.ini", "igor.output.manifest", f"{project_name}.exe"]

	runtime_path = f"{user_dict["gamemaker_cache_path"]}/runtimes/runtime-{project_config.gamemaker_runtime_version}"
	igor_path = f"{runtime_path}/bin/igor/{IGOR_OS_SUBFOLDER}/x64/Igor"
	
	try:
		if not os.path.isdir(f"{dotfrida}/igor"):
			os.makedirs(f"{dotfrida}/igor")
		status = subprocess.run(
			[igor_path, 
			"-j=8",
			f"--user={user_dict["gamemaker_user_directory_path"]}",
			f"--project={yyp_path}",
			f"--config={project_config.gamemaker_configuration}",
			f"--runtimePath={runtime_path}",
			"-v",
			"--tf=artifact.zip",

			IGOR_TARGETS[0],
			IGOR_TARGETS[1],
			],
			cwd = f"{dotfrida}/igor")
	except Exception as e:
		print("Failed to launch igor. Do you have all your variables set correctly?\n" + str(e))
		cleanup()
		exit()

	if (status.returncode != 0):
		cleanup()
		raise FridaException("Something went wrong during building, aborting. If it's a normal issue with the project (e.g. a syntax error) it should be somewhere in the output above.")

	# I don't think there's a way to make igor not output this.
	try:
		os.remove(f"{dotfrida}/igor/artifact.zip")
	except:
		pass

	try:
		igor_output = f"{dotfrida}/igor/output/{project_name}"
		igor_results = f"{dotfrida}/igor/results/{project_name}"
		if os.path.exists(f"{igor_results}/included_files"):
			shutil.rmtree(f"{igor_results}/included_files")
		os.makedirs(igor_results, exist_ok=True)
		os.replace(f"{igor_output}/{IGOR_OUTPUT_PATH}", f"{igor_results}/datafile")
		
		included_files_path = f"{igor_output}/{IGOR_ASSETS_FOLDER}"
		new_included_files_path = f"{igor_results}/included_files"
		
				
		included_files_top_level = [file for file in os.listdir(included_files_path) if file not in IGOR_ASSETS_FILTER]
		print(included_files_top_level)
		if (len(included_files_top_level) != 0):
			os.mkdir(new_included_files_path)
			for root, directories, files in os.walk(included_files_path):
				relative_root = os.path.relpath(root, included_files_path)
				for directory in directories:
					os.makedirs(f"{new_included_files_path}/{relative_root}/{directory}", exist_ok=True)
				for file in files:
					if file in IGOR_ASSETS_FILTER and root == included_files_path:
						continue
					shutil.copy(f"{root}/{file}", f"{new_included_files_path}/{relative_root}/{file}")
		
		with open(f"{dotfrida}/igor/results/{project_name}/hash.txt", 'w') as f:
			f.write(project_hash)
		
	except Exception as e:
		print("Failed to copy igor results. Please report this bug!")
		print(e)
		exit()


		



def make_profile_json_dict(project_config: ProjectConfig):
	p = {}
	p["format_version"] = 2
	p["name"] = "Testing Profile"
	p["id"] = "out"
	p["separate_modded_save"] = (project_config.modded_save_name != "")
	p["modded_save_name"] = project_config.modded_save_name
	p["mod_order"] = project_config.mod_order
	p["mods_disabled"] = []
	p["description"] = ""
	p["version"] = ""
	p["credits"] = []
	p["links"] = []
	return p



		


### packaging mod
def package_mod(frida_root: str, project_config: ProjectConfig, linkbase=False):
	profile_json = make_profile_json_dict(project_config)
	if not os.path.exists(f"{cli_frida_root}/base/profile.json"):
		with open(f"{cli_frida_root}/out/profile.json", "wt") as f:
			json.dump(profile_json, f)
	
	if project_config.gamemaker_project_path == "":
		gamemaker_project_name = ""
	else:
		gamemaker_project_name = get_yyp_filename(f"{frida_root}/{project_config.gamemaker_project_path}").removesuffix(".yyp")
	
	igor_results = f"{dotfrida}/igor/results/{gamemaker_project_name}"
	
	def symlink(target: str, output: str):
		if os.name == "nt":
			os.link(target, output)
		else:
			os.symlink(target, output)
	
	copy_function = shutil.copy2 if not linkbase else symlink
	shutil.copytree(f"{os.path.abspath(frida_root)}/base", f"{cli_frida_root}/out", dirs_exist_ok=True, copy_function=copy_function)

	if os.path.isfile(f"{igor_results}/datafile"):
		export_path = project_config.gamemaker_datafile_export_path
		if os.path.isdir(export_path):
			export_path += "/mod_data.win"
		shutil.copy(f"{igor_results}/datafile", export_path)
	if project_config.gamemaker_included_files_export_path != "" and os.path.isdir(f"{igor_results}/included_files"):
		export_path = project_config.gamemaker_included_files_export_path
		shutil.copytree(f"{igor_results}/included_files", f"{frida_root}/out/{export_path}", dirs_exist_ok=True, copy_function=copy_function)

def recreate_out_folder(frida_root: str):
	if os.path.isdir(f"{frida_root}/out"):
		print("Deleting previous out folder...")
		shutil.rmtree(f"{frida_root}/out")
	print("Creating out folder...")
	os.mkdir(f"{frida_root}/out")
	
def package_routine(frida_root: str, project_config: ProjectConfig, should_package_dependencies = True, linkbase=False, name = ""):
	if name == "":
		print(f"Packaging...")
	else:
		print(f"Packaging: {name}")

	package_mod(frida_root, project_config, linkbase=linkbase)

	if not should_package_dependencies:
		return
	for dependency in project_config.dependencies:
		path = dependency.get_path()
		paths = dependency.get_frida_root_candidate_paths(path)
		dependency_frida_root = check_frida_root_candidates(paths)
		dependency_project_dict = get_project_config(dependency_frida_root)
		dependency_project_config = validation_routine(dependency_frida_root, dependency_project_dict)
		package_routine(dependency_frida_root, dependency_project_config, project_config.recursive_dependencies, linkbase=linkbase, name = str(dependency))
		

def zip_out_folder(frida_root, project_config: ProjectConfig):
	if os.path.exists(f"{frida_root}/out.zip"):
		os.remove(f"{frida_root}/out.zip")
	
	normalized_zip_exclude = [os.path.normpath(path) for path in project_config.zip_exclude]
	
	zip_filename = "out"
	root_folder_name = ""
	out_folder = f"{frida_root}/out"
	if os.path.normpath("profile.json") not in normalized_zip_exclude:
		with open(f"{out_folder}/profile.json", "rt") as f:
			profile_json = json.load(f)
			if "id" not in profile_json:
				print("profile.json in \"base\" folder does not contain \"id\" field - this is probably because it's on format version 1. Change the format version to 2, and add an \"id\" field.")
				print("An \"id\" field is necessary to determine the name of the root folder of the ZIP. If you don't care about that, you can just delete the profile.json from the \"base\" folder and use Frida's autogenerated one.")
			else:
				root_folder_name = profile_json["id"] 
				zip_filename = profile_json["id"]
	
	with zipfile.ZipFile(f"{frida_root}/{zip_filename}.zip", "w") as f:
		for root, directories, files in os.walk(out_folder, followlinks=True):
			archive_root = os.path.relpath(root, out_folder)

			# TODO: does not handle folders correctly
			if root == out_folder:
				length = len(directories)
				i = 0
				while (i < length):
					if os.path.normpath(directories[i]) in normalized_zip_exclude:
						del directories[i]
						i -= 1
						length -= 1
					i += 1
			
			for file in files:
				archive_path = f"{archive_root}/{file}"
				if os.path.normpath(archive_path) not in normalized_zip_exclude:
					f.write(f"{root}/{file}", f"{archive_root}/{file}")


### applying mod ###

def apply_mod(frida_root, user_config):
	print("---Applying the mod---")
	try:
		status = subprocess.run(
			[user_config["g3man_path"], "apply",
				"--path", "out",
				"--datafile", user_config["clean_datafile_path"],
				"--out", user_config["game_path"],
				"--outname", user_config["game_datafile_name"]
			],
			cwd = ".")
	except Exception as e:
		print("Failed to launch g3man. Do you have all your variables set correctly?\n" + str(e))
		return
	if (status.returncode != 0):
		print("Something failed in g3man. Aborting.")
		exit()

### cli

def is_executable(path: str):
	if os.name == "nt":
		return path.endswith(".exe") or path.endswith(".bat")
	elif os.access(path, os.X_OK): # this ends up being true for almost every file for me, but i don't know any better way to check
		return path

def try_starting_game():
	game_path = user_dict["game_path"]
	executables = []
	for file in os.listdir(game_path):
		if is_executable(f"{game_path}/{file}"):
			executables.append(f"{game_path}/{file}")
	start_game_command = user_dict["start_game_command"]
	
	if len(executables) != 1:
		if start_game_command == "":
			print("Couldn't determine which file is the executable. Please supply \"start_game_command\" in the user config to tell Frida what to do to launch the game.")
			return
		
	else:
		cmd = executables[0]
	
	if start_game_command != "":
		cmd = start_game_command.split(" ") # not correct ! TODO
		
	
	print(f"Launching game. Running command: {cmd}")
	try:
		status = subprocess.run(
			cmd,
			cwd = game_path)
	except Exception as e:
		print(e)
		pass

def strip_comments(str: str):
	build = ""
	state = 0
	for i in range(len(str) - 1):
		if state == 0:
			if str[i] == '/' and str[i + 1] == '/':
				state = 1
			elif str[i] == '/' and str[i + 1] == '*':
				state = 2
			elif str[i] == '"':
				build += '"'
				state = 3
			else:
				build += str[i]
		elif state == 1:
			if str[i + 1] == '\n':
				state = 0
		elif state == 2:
			if str[i] == '*' and str[i + 1] == '/':
				state = 0
				i += 1
		elif state == 3:
			build += str[i]
			if str[i] == '"':
				state = 0
	return build

def fixup_paths_user_config(dict: dict[str, Any]):
	for key in ["g3man_path", "game_path", "gamemaker_cache_path", "gamemaker_user_directory_path"]:
		if key in dict and dict[key] != "":
			dict[key] = os.path.normpath(dict[key]).replace('\\', '/')
			
def fixup_paths_project_config(dict: dict[str, Any]):
	for key in ["gamemaker_project_path", "gamemaker_datafile_export_path", "gamemaker_datafile_export_path"]:
		if key in dict and dict[key] != "":
			dict[key] = os.path.normpath(dict[key]).replace('\\', '/').removesuffix('/')

def check_frida_root_candidates(paths: list[str]) -> str:
	for path in paths:
		if os.path.exists(f"{path}/frida-project-config.jsonc"):
			return path
	raise FridaException(f"No project config exists in any candidate path: {paths}")

def get_project_config(path: str):
	try:
		with open(f"{path}/frida-project-config.jsonc") as f:
			config = json.loads(strip_comments(f.read()))
			fixup_paths_project_config(config)
			return config
	except Exception as e:
		raise FridaException(f"Couldn't load project config: {e}")
		
def project_config_routine(create: bool):
	try:
		frida_root = check_frida_root_candidates([".", "./g3man"])
	except:
		print("No project config found.")
		if create:
			print("Creating...")
			try:
				with open(f"./frida-project-config.jsonc", "wt") as f:
					f.write(frida_template_project_config)
			except Exception as e:
				print(f"Could not create frida-project-config.jsonc: {e}")
				exit()
		return None, "."
	try:
		return get_project_config(cli_frida_root), frida_root
	except FridaException as e:
		print(e.message)
		exit()

def user_config_routine(create):
	if not os.path.isfile(f"{cli_frida_root}/frida-user-config.jsonc"):
		print("No user config found.")
		if create:
			print("Creating...")
			try:
				with open(f"{cli_frida_root}/frida-user-config.jsonc", "wt") as f:
					f.write(frida_template_user_config)
			except Exception as e:
				print(f"Could not create frida-user-config.jsonc: {e}")
				exit()
		return None
	try:
		with open(f"{cli_frida_root}/frida-user-config.jsonc") as f:
			dict = json.loads(strip_comments(f.read()))
			fixup_paths_user_config(dict)
			return dict
	except Exception as e:
		print(f"Couldn't read from frida-user-config.jsonc! {e}")
		exit()


	
	return

def convert_to_new_setup():
	files = ["base/mod/profile.json", "frida-timestamp.txt", ".frida-config-template.ini", "frida-config.ini"]
	for file in files:
		print(f"Removing {file}")
		if os.path.exists(file):
			try:
				os.remove(file)
			except Exception as e:
				print(f"Couldn't remove {file}, Error: {e}")
				return
	
	if os.path.exists("./igor"):
		print(f"Removing ./igor folder")
		try:
			shutil.rmtree("./igor")
		except Exception as e:
			print(f"Couldn't remove ./igor. Error: {e}")
			return
			
	if os.path.exists("./base/mod/mod.json"):
		print(f"Renaming ./base/mod")
		try:
			with open("./base/mod/mod.json") as f:
				mod_json = json.load(f)
				if "mod_id" not in mod_json:
					print("Invalid mod.json in \"base\", couldn't determine mod ID, so the folder cannot be renamed")
					return
		except Exception as e:
			print(f"Failed to read ./base/mod/mod.json, Error: {e}")
			return
		print(f"Mod ID is {mod_json["mod_id"]}")
		try:
			shutil.move("./base/mod", f"./base/{mod_json["mod_id"]}")
		except Exception as e:
			print(f"Renaming failed. Error: {e}")
			return

def old_setup_routine():
	if os.path.isfile("frida-config.ini") and not os.path.isfile("frida-project-config.jsonc"):
		print("Old setup detected. In order for this dialogue to go away, delete frida-config.ini, or read the text below.")
		print()
		print("Frida's setup has been completely changed for version 4.")
		print("Would you like your current setup to be automatically converted?")
		print()
		print("This will:")
		print("1. Remove \"base/mod/profile.json\" (back it up and copy it back if you're distributing your mod as a profile)")
		print("2. Remove \"igor\", \"frida-timestamp.txt\", and \".frida-config-template.ini\"")
		print("3. Rename \"base/mod\" to \"base/(your mod's ID)\"")
		print("4. frida-config.ini will be removed, and you will need to create the two new config files and fill them again. So you should probably back it up to make this part easier.")
		print()
		print("With the renaming of \"base/mod\", make sure to update your .gitignore file as well.")
		print("You can find info on that on Frida's wiki: https://github.com/skirlez/frida/wiki/gitignore")
		print()
		print("y/Y - Convert and Continue")
		print("Anything else - Exit")
		print()
		choice = input("Input your choice: ")
		if choice.lower() != "y":
			exit()
		convert_to_new_setup()
  		# in case user double clicked
		input()
		exit()


def compare_dict_to_contract_assign_if_missing(dict, contract, issues):
	for key in contract:
		if key not in dict:
			dict[key] = contract[key]
		elif type(contract[key]) != type(dict[key]):
			issues.append(f"\"{key}\" is of the wrong type: It should be {type(contract[key])}, but it's {type(dict[key])}")


def compare_dict_to_contract(dict, contract, issues):
	for key in contract:
		if key not in dict:
			issues.append(f"\"{key}\" is missing")
		elif type(contract[key]) != type(dict[key]):
			issues.append(f"\"{key}\" is of the wrong type: It should be {type(contract[key])}, but it's {type(dict[key])}")



		
frida_template_project_config = """
// This file is the project config. This file isn't personal to any user and should be shared by everyone working on this mod.
// 
// You *can* use backslashes when filling out paths, but they must be escaped, i.e. you have to write "\\" instead of "\" every time.
// Save yourself the hassle and use forward slashes.
//
// Frida wiki entry: https://github.com/skirlez/frida/wiki/Project-Config
{
	// Path to the folder with this mod's GameMaker project.
	// If this mod has no GameMaker project, leaving this as blank
	// will disable GameMaker project building.
	// This path should be a relative path.
	// Relative paths, e.g. "src" means "the src folder present inside this folder", or
	// ".." meaning "the folder above this one"
	"gamemaker_project_path": "",
	
	// The GameMaker runtime the project should be built for.
	// Example: "2023.4.0.113"
	"gamemaker_runtime_version": "",
	
	// The GameMaker configuration to use. If you don't know what this is, leave as "Default".
	"gamemaker_configuration": "Default",
	
	// Where Frida should place the GameMaker project's output datafile when packaging.
	// For example: to make it place the datafile in your mod's folder,
	// set this to: out/(your mod's ID)/mod_data.win.
	// If you don't use a GameMaker project, leave as blank.
	"gamemaker_datafile_export_path": "",
	
	// Dependencies that frida should fetch and build.
	// These can be local paths if you start the string with \"path:\"
	// or a link to a GitHub repository (with "github:user/repo/branch" or "github-tag:user/repo")
	// For more information, see https://github.com/skirlez/frida/wiki/Dependency-Management
	"dependencies": [],
	
	// Evaluate dependencies of dependencies
	// If this is disabled, you have to manually specify all the dependencies of your dependencies.
	"recursive_dependencies" : true,
	
	// Mod priority for the testing profile (in the "out" folder, used by "frida.py apply".). 
	// You should put the ID of your mod and its dependencies here.
	// Earlier in the list means higher priority.
	// 
	// If you have a "profile.json" file in the "base" folder,
	// this setting will not override it.
	"mod_order" : [],
	
	// Modded save name for the testing profile (in the "out" folder, used by "frida.py apply".).
	// Leaving this as blank will use the same save folder as the vanilla game,
	// Changing this will change the save folder. (Meaning you will have completely isolated save files).
	//
	// If you have a "profile.json" file in the "base" folder,
	// this setting will not override it.
	"modded_save_name" : "",
	
	// Which files and folders inside "out" should not be zipped when using `frida.py package --zip`.
	"zip_exclude" : [],
	
	// This number is used for potential auto-upgrading of this file,
	// and you shouldn't change it.
	"format_version": 1
}
"""
project_config_optional_contract = {
	"gamemaker_included_files_export_path" : "",
}
project_config_contract = json.loads(strip_comments(frida_template_project_config))


def parse_project_dependencies(config: dict[str, str]):
	issues = []
	parsed_dependencies = []
	for dependency in config["dependencies"]:
		if dependency.strip() == "":
			continue
		parts = dependency.split(':', 1)
		if len(parts) == 1:
			issues.append(f"Dependency {dependency} does not have a prefix. You need to specify a prefix, like \"path:\", or \"github-tag:\".")
			continue
		
		arg_parts = parts[1].rsplit('?', 1)
		args = dict()
		if len(arg_parts) == 2:
			assignments = arg_parts[1].split('&')
			for assignment in assignments:
				lr = dependency.split('=', 1)
				if len(lr) != 2:
					issues.append(f"Dependency {dependency} has invalid argument assignment: {assignment}")
					continue
				args[lr[0]] = lr[1]
		
		
		prefix = parts[0]
		if prefix == "path":
			path = parts[1]
			parsed_dependencies.append(PathDependency(path))
		if prefix == "github-tag":
			subparts = parts[1].split('/')
			
			if len(subparts) == 2:
				user = subparts[0]
				repo = subparts[1]
				parsed_dependencies.append(GitHubTagDependency(user, repo, args.get("frida_root", ""), args.get("tag")))
			else:
				issues.append(f"Dependency {dependency}'s content should be of the form \"user/repo\"")
				continue
		if prefix == "github":
			subparts = parts[1].split('/')
			if len(subparts) == 3:
				user = subparts[0]
				repo = subparts[1]
				branch = subparts[2]

				parsed_dependencies.append(GitHubCommitDependency(user, repo, branch, args.get("frida_root", ""), args.get("commit")))
			else:
				issues.append(f"Dependency {dependency}'s content should be of the form \"user/repo/branch\"")
				continue
	return parsed_dependencies, issues

def validate_project_dict(frida_root, dict):
	issues = []
	compare_dict_to_contract(dict, project_config_contract, issues)
	compare_dict_to_contract_assign_if_missing(dict, project_config_optional_contract, issues)
	
	if len(issues) != 0:
		return (issues, [])
	warnings = []
	gamemaker_project_path = dict["gamemaker_project_path"]
	if os.path.isabs(gamemaker_project_path):
		absolute_gamemaker_project_path = gamemaker_project_path
	else:
		absolute_gamemaker_project_path = os.path.abspath(f"{frida_root}/{gamemaker_project_path}")
	
	if gamemaker_project_path != "":
		if not os.path.exists(gamemaker_project_path):
			issues.append(f"The provided folder path \"gamemaker_project_path\" (\"{gamemaker_project_path}\") does not exist")
		else:
			yyp_filename = get_yyp_filename(absolute_gamemaker_project_path)
			if yyp_filename == "":
				issues.append(f"Could not find any .yyp file in \"gamemaker_project_path\" (value: \"{gamemaker_project_path}\")")
		
		
		for field in ["gamemaker_runtime_version", "gamemaker_configuration", "gamemaker_datafile_export_path"]:
			if dict[field] == "":
				issues.append(f"\"gamemaker_project_path\" is set, but \"{field}\" is blank")
	if os.path.isabs(gamemaker_project_path):
		warnings.append(f"gamemaker_project_path is currently set to \"{gamemaker_project_path}\", which is NOT a relative path!"
					+ f"\nFrida suggests: use \"{os.path.relpath(start=".", path=gamemaker_project_path)}\" instead")

	if os.path.exists(f"{frida_root}/base") and not (os.path.exists(f"{frida_root}/base/profile.json") and "profile.json" not in dict["zip_exclude"]):
		unaccounted = [dir for dir in os.listdir(f"{frida_root}/base") if dir not in dict["mod_order"] and os.path.isdir(f"{frida_root}/base/{dir}")]
		if len(unaccounted) != 0:
			warnings.append(f"\"mod_order\" is missing some mods that exist in the \"base\" folder: {unaccounted}. g3man will go over these last.")
	return (issues, warnings)
	


frida_template_user_config = """
// This file is the user config. This file is personal to your computer, and shouldn't be shared.
// 
// You *can* use backslashes when filling out paths, but they must be escaped, i.e. you have to write "\\\\" instead of "\\" every time.
// Save yourself the hassle and use forward slashes.

{
	// The path to g3man's executable file.
	// https://github.com/skirlez/g3man/releases
	"g3man_path": "",
	
	// Path to the game's clean/unmodified/vanilla datafile.
	// You can't just put the path to the game's datafile here. It needs to be a separate copy,
	// because the game's datafile gets overridden after applying your mod.
	"clean_datafile_path": "",
	
	// Path to the folder of the game this project is modding
	"game_path": "",
	
	// This'll be data.win for windows, or game.unx for example on Linux.
	// Note that if you are using Proton on Steam for example, this will use the windows name.
	"game_datafile_name": "",
	
	// Using an argument, you can tell Frida to launch the game after applying your mod.
	// In case Frida cannot manage to do so automatically, you can instead have frida execute
	// this field as a command.
	"start_game_command": "",
	
	// (REQUIRED FOR BUILDING GAMEMAKER PROJECTS ONLY)
	// Linux: Likely is /home/USER/.local/share/GameMakerStudio-Beta/Cache
	// Windows: Likely is C:/ProgramData/GameMakerStudio2/Cache
	"gamemaker_cache_path": "",
	
	// (REQUIRED FOR BUILDING GAMEMAKER PROJECTS ONLY)
	// The user directory contains your license file, which is required to build GameMaker projects.
	// Linux: Likely is /home/USER/.config/GameMakerStudio2-Beta/user_somenumbers
	// Windows: Likely is C:/Users/USER/AppData/Roaming/GameMakerStudio2/user_somenumbers
	"gamemaker_user_directory_path": "",
	
	// Whether or not this script should check for updates every once in a while.
	// If set to true, it will occasionally do this after the operation you've chosen.
	"check_for_updates": true,
	
	// This number is used for potential auto-upgrading of this file,
	// and you shouldn't change it.
	"format_version": 1
}
"""
frida_user_config_optional = {
	"gamemaker_hash_ignore" : ["g3man", ".gitattributes", ".git", ".gitignore", ".frida"]
}
user_config_contract = json.loads(strip_comments(frida_template_user_config))

def validate_user_dict(dict):
	issues = []
	compare_dict_to_contract(dict, user_config_contract, issues)
	if len(issues) != 0:
		return (issues, [])
	
	file_paths = ["g3man_path", "clean_datafile_path"]
	for path in file_paths:
		if not os.path.isfile(dict[path]):
			issues.append(f"The provided file path \"{path}\" (\"{dict[path]}\") does not exist")

	folderpaths = ["gamemaker_cache_path", "gamemaker_user_directory_path", "game_path"]
	for path in folderpaths:
		if not os.path.exists(dict[path]):
			issues.append(f"The provided folder path \"{path}\" (\"{dict[path]}\") does not exist")
	
	if os.path.exists(dict["gamemaker_cache_path"]) and not os.path.exists(f"{dict["gamemaker_cache_path"]}/runtimes"):
		issues.append(f"\"gamemaker_cache_path\" is set to \"{dict["gamemaker_cache_path"]}\", but that folder does not have a \"runtime\" subfolder.")
	
	if os.path.exists(dict["game_path"]) and not os.path.isfile(f"{dict["game_path"]}/{dict["game_datafile_name"]}"):
		valid_suffixes = [".win", ".unx", ".ios", ".droid"]
		valid_datafile_names = []
		for filename in os.listdir(dict["game_path"]):
			if any(filename.endswith(suffix) for suffix in valid_suffixes):
				valid_datafile_names.append(filename)
				
		issue = f"\"game_path\" seems to be a folder, but no file with name \"game_datafile_name\" {dict["game_datafile_name"]} was found there."

		if len(valid_datafile_names) == 0:
			issue += "\nNo valid datafile files were found in that folder as well. Are you sure this is the game folder?"
		else:
			issue += f"\nValid datafile names found in that folder: {valid_datafile_names}"
	return (issues, [])

def validate_combination(user_dict, project_dict):
	issues = []
	if (project_dict["gamemaker_runtime_version"] != ""
		and os.path.exists(f"{user_dict["gamemaker_cache_path"]}/runtimes") 
		and not os.path.exists(f"{user_dict["gamemaker_cache_path"]}/runtimes/runtime-{project_dict["gamemaker_runtime_version"]}")):
		print(f"{user_dict["gamemaker_cache_path"]}/runtimes/runtime-{project_dict["gamemaker_runtime_version"]}")
		issues.append(f"You are missing the \"{project_dict["gamemaker_runtime_version"]}\" runtime, which is required by one of the projects. Please download it from the IDE.")
	return (issues, [])
		
def validation_routine(frida_root, project_dict, validate_user = False) -> ProjectConfig:
	if validate_user:
		user_issues, user_warnings = validate_user_dict(user_dict)
	project_issues, project_warnings = validate_project_dict(frida_root, project_dict)
	combination_issues, combination_warnings = validate_combination(user_dict, project_dict)
	
	parsed_dependencies, dependency_issues = parse_project_dependencies(project_dict)
	project_issues += dependency_issues
	
	printed = False
	leave = False
	def print_issues_found():
		nonlocal printed
		if not printed:
			print("Configuration issue(s) found!")
			printed = True
	def set_leave():
		nonlocal leave
		if not leave:
			leave = True
	
	if len(project_issues) != 0:
		print_issues_found()
		set_leave()
		print_issues(project_issues + project_warnings, "frida-project-config.jsonc")
	elif len(project_warnings) != 0:
		print_issues_found()
		print_issues(project_warnings, "frida-project-config.jsonc")
	
	if validate_user:
		if len(user_issues) != 0:
			print_issues_found()
			set_leave()
			print_issues(user_issues + user_warnings, "frida-user-config.jsonc")
		elif len(user_warnings) != 0:
			print_issues_found()
			print_issues(user_warnings, "frida-user-config.jsonc")
		
	if len(combination_issues) != 0:
		print_issues_found()
		set_leave()
		print_issues(combination_issues + combination_warnings, "Combination of user and project configs")
	elif len(combination_warnings) != 0:
		print_issues_found()
		print_issues(combination_warnings, "Combination of user and project configs")
	
	if leave:
		print("Irreconcilable issues encountered.")
		exit()
	if printed:
		print("Issues are not critical. Proceeding.")
	
	return ProjectConfig(project_dict, parsed_dependencies)


timestamp_filename = "update-timestamp.txt"

def should_check_for_update():
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
	except Exception as e:
		print("Error occured while checking for updates. You should probably check manually. See you tomorrow!")
		save_update_timestamp(86400)
		return

	if tag_number > frida_version:
		print(f"Update found! You are on version {frida_version}, and the latest version is {tag_name}.")
		print("You can update by going to https://github.com/skirlez/frida/releases/latest, downloading the script, and replacing this script with the downloaded one.")
	elif tag_number < frida_version:
		print(f"You are on a future version: Current is version {frida_version}, and the latest version is {tag_name}.")
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
	if sys.version_info.major < 3 or sys.version_info.minor < 6:
		print("Frida requires Python 3.6 at least to run. Your python version: " + str(sys.version_info.major) + "." + str(sys.version_info.minor) + "." + str(sys.version_info.micro))
		exit()

def print_issues(issues, filename):
	if len(issues) == 0:
		print(f"{filename} is valid")
	else:
		print(f"{filename}:")
		for i in range(len(issues)):
			print(f"{i + 1}. {issues[i]}")
		print()




				

def fetch_dependencies(frida_root, project_config: ProjectConfig):
	for dependency in project_config.dependencies:
		path = dependency.get_path()
		os.makedirs(path, exist_ok=True)
		if dependency.needs_download():
			zip_url = dependency.get_zip_url()
			urllib.request.urlretrieve(zip_url, f"{dotfrida}/tmp.zip")
			with zipfile.ZipFile(f"{dotfrida}/tmp.zip", "r") as f:
				f.extractall(path)
			os.remove(f"{dotfrida}/tmp.zip")
			
		if project_config.recursive_dependencies:
			paths = dependency.get_frida_root_candidate_paths(path)
			frida_root = check_frida_root_candidates(paths)
			dependency_project_dict = get_project_config(frida_root)
			print(f"Fetching: \"{dependency}\"")
			dependency_project_config = validation_routine(frida_root, dependency_project_dict)
			fetch_dependencies(frida_root, dependency_project_config)

if __name__ == "__main__":
	python_version_routine()
	# Let me Ctrl+C in peace
	signal.signal(signal.SIGINT, lambda a, b: exit())
	
	old_setup_routine()
	
	create = "--createconfig" in sys.argv
	
	project_dict, cli_frida_root = project_config_routine(create)
	dotfrida = f"{cli_frida_root}/.frida"
	user_dict = user_config_routine(create)
	
	if project_dict is None or user_dict is None:
		if not create:
			print("Configuration files are missing in this directory. You can run \"frida.py --createconfig\" to create them.")
			exit()
		print("Configuration file(s) have been created.")
		print("You can run \"frida.py validate\" in order to validate your config(s), after filling them.")
		exit()
	
	if (len(sys.argv) < 2):
		bad_usage()
	argument = sys.argv[1]
	if argument == "--version" or argument == "-v":
		print(f"Frida version {frida_version}")
		exit()
	if argument == "--help" or argument == "-h":
		print(usage)
		print("Perform ACTION in accordance to frida-project-config.jsonc and frida-user-config.jsonc in the same directory.")
		print()
		print("Actions list:")
		print("    fetch")
		print("    build")
		print("    package [--zip]")
		print("    apply [--linkbase] [--startgame]")
		print("    validate")
		print("    check_updates")
		print()
		print("You can use '--help' on each of the actions to learn more about them and their options.")
		exit()

	subarguments = sys.argv[2:]
	opname = argument
	if argument == "fetch":
		if is_help(subarguments):
			print("frida.py fetch - Fetches the mod's dependencies.")
			exit()
		project_config = validation_routine(cli_frida_root, project_dict, validate_user=True)
		fetch_dependencies(cli_frida_root, project_config)
		exit()
	if argument == "build":
		if is_help(subarguments):
			print("frida.py build - Builds the mod's and dependencies' GameMaker projects.")
			print()
			print("This action will attempt to build the projects regardless of the previous builds' hashes.")
			print()
			print("The output artifacts will be in .frida/igor.")
			print()
			exit()
		project_config = validation_routine(cli_frida_root, project_dict, validate_user=True)
		build_routine(cli_frida_root, project_config, force_build=True)
		
		if (should_check_for_update()):
			check_update()
		exit()
	if argument == "package":
		if is_help(subarguments):
			print("frida.py package - Packages this mod.")
			print()
			print("This action will build the GameMaker project(s) if necessary, and package this")
			print("mod and its dependencies as a profile folder \"out\", for distribution or application.")
			print()
			print("Arguments:")
			
			print("  -z, --zip      After creating the \"out\" folder, compress it into a ZIP (as \"out.zip\")")
			indent = "                   "
			print(f"{indent}This will exclude any files found in the project config's \"zip_exclude\" field.")
			print(f"{indent}Additionally, if \"profile.json\" isn't excluded, the ZIP will have a root folder,")
			print(f"{indent}with the same name as the profile's ID.")
			exit()
		project_config = validation_routine(cli_frida_root, project_dict, validate_user=True)
		build_routine(cli_frida_root, project_config)
		recreate_out_folder(cli_frida_root)
		package_routine(cli_frida_root, project_config, linkbase=False)
		zip = "-z" in subarguments or "--zip" in subarguments 
		if zip:
			zip_out_folder(cli_frida_root, project_config)
		print(f"Done!")
		if (should_check_for_update()):
			check_update()
		exit()
	if argument == "apply":
		if is_help(subarguments):
			print("frida.py apply [ARGUMENTS] - Applies this mod.")
			print()
			print("This action will build the GameMaker project(s) if necessary, package the mod and its dependencies,")
			print("And then call g3man to apply it on a GameMaker game.")
			print()
			print("Arguments:")
			
			print("  -l, --linkbase      When packaging, link files in \"out\" to \"base\" instead of copying")
			indent = "                        "
			print(f"{indent}This is useful if your mod has included files it reads from at runtime,")
			print(f"{indent}as this argument effectively makes it so any changes to files in \"base\"")
			print(f"{indent}are visible to the modded game immediately.")
			print(f"{indent}Note: This argument uses hard links on Windows")
			print(f"{indent}and symlinks everywhere else.")
			print()
			print("  -s, --startgame     After applying, attempt to launch the game")
			
			print(f"{indent}Frida will try to open any executable found in the game's folder.")
			print(f"{indent}If Frida cannot determine which executable to launch,")
			print(f"{indent}you must set \"start_game_command\" in frida-user-config.jsonc")
			print(f"{indent}which Frida will execute in the game's folder.")
			exit()
		linkbase = "-l" in subarguments or "--linkbase" in subarguments 
		project_config = validation_routine(cli_frida_root, project_dict, validate_user=True)
		build_routine(cli_frida_root, project_config)
		recreate_out_folder(cli_frida_root)
		package_routine(cli_frida_root, project_config, linkbase=linkbase)
		apply_mod(cli_frida_root, user_dict)
		
		startgame = "-s" in subarguments or "--startgame" in subarguments 
		if startgame:
			try_starting_game()
		print("Done! Your mod has been applied.")
		if (should_check_for_update()):
			check_update()
		exit()
	if argument == "validate":
		if is_help(subarguments):
			print("frida.py validate - Validates config files in the current directory.")
			print()
			print("This action will go over some of the fields in frida-user-config.jsonc and frida-project-config.jsonc,")
			print("and will let you know if there's anything wrong with them.")
			exit()
		project_issues, project_warnings = validate_project_dict(cli_frida_root, project_dict)
		user_issues, user_warnings = validate_user_dict(user_dict)
		combination_issues, combination_warnings = validate_combination(user_dict, project_dict)
		
		_, dependency_issues = parse_project_dependencies(project_dict)
		project_issues += dependency_issues
		
		print_issues(project_issues + project_warnings, "frida-project-config.jsonc")
		print_issues(user_issues + user_warnings, "frida-user-config.jsonc")
		print_issues(combination_issues + combination_warnings, "Combination of user and project configs")
		exit()
	if argument == "check_updates":
		if is_help(subarguments):
			print("frida.py check_updates - Checks for updates to Frida.")
			print()
			print("This action will check https://github.com/skirlez/frida/releases,")
			print("And print a message if there's a newer version.")
			exit()
		check_update(manual=True)
		exit()


	bad_usage()
