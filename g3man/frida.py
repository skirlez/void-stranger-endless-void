#!/usr/bin/env python3

import os
import sys
import time
import json
import shutil
import signal
import hashlib
import subprocess
import urllib.request

### options ### 

options = {}

def get_options():
	if not os.path.isfile("frida-config.ini"):
		shutil.copy(".frida-config-template.ini", "frida-config.ini")
		print("frida-config.ini has been created! Open it up in a text editor, and fill in the variables according to the comments.")
		exit()

	with open("frida-config.ini") as f:
		for line in f:
			line = line.strip()
			if line.startswith('#'):
				continue
			if not '=' in line:
				continue
			(varname, value) = line.split('=', 2)
			value = value.strip().removeprefix('"').removesuffix('"')
			options[varname] = value


# set later by the user's chosen operation.
opname = "any"

def demand(name, can_be_empty=False):
	msg = f"\"{opname}\" requires {name} to be set, but it is not set. Please set it in frida-config.ini."
	if not name in options:
		print(msg)
		exit()
	value = options[name]
	if value == "" and not can_be_empty:
		print(msg)
		exit()
	return value

### building project ### 

def hash_file(full_path, relative_path, hash_func):
	hash_func.update(relative_path.encode())
	with open(full_path, 'rb') as f:
		for chunk in iter(lambda: f.read(4096), b''):
			hash_func.update(chunk)

def hash_project():
	project_folder = os.path.abspath("..")
	listdir = sorted(os.listdir(project_folder))

	ignored_items = ["g3man", ".gitattributes", ".git", ".gitignore"]
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
	
	if os.path.isdir("./igor/output"):
		print("Deleting ./igor/output...")
		shutil.rmtree("./igor/output", ignore_errors=True)
	if os.path.isdir("./igor/included_files"):
		print("Deleting ./igor/included_files...")
		shutil.rmtree("./igor/included_files", ignore_errors=True)
	try:
		os.remove("./igor/artifact.zip")
	except:
		pass
def build_gamemaker_project(force = False):
	if not force:
		SHOULD_BUILD_PROJECT = demand("SHOULD_BUILD_PROJECT", "build")
		if (SHOULD_BUILD_PROJECT == "0"):
			print("SHOULD_BUILD_PROJECT is set to 0, skipping build...")
			return

	SHOULD_HASH = demand("SHOULD_HASH")
	
	if (SHOULD_HASH != "0" and not force):
		project_hash = ""
		previous_hash = ""
		if (os.path.isfile("./igor/hash.txt")):
			with open("./igor/hash.txt", 'r') as f:
				previous_hash = f.read()

			if previous_hash != "":
				project_hash = hash_project()
				if project_hash == previous_hash:
					print("Previous build hash matches, skipping build...")
					return

	cleanup()
	print("---Building the mod's GameMaker project---")

	
	PROJECT_NAME = demand("PROJECT_NAME", __file__)
	GAMEMAKER_CONFIGURATION = demand("GAMEMAKER_CONFIGURATION", __file__)
	RUNTIME_VERSION = demand("RUNTIME_VERSION", __file__)
	GAMEMAKER_CACHE_PATH = demand("GAMEMAKER_CACHE_PATH", __file__)
	USER_DIRECTORY_PATH = demand("USER_DIRECTORY_PATH", __file__)

	PROJECT_YYP = os.path.abspath(f"../{PROJECT_NAME}.yyp")

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
		IGOR_ASSETS_FILTER=["options.ini", "igor.output.manifest", f"{PROJECT_NAME}.exe"]

	IGOR_PATH=f"{GAMEMAKER_CACHE_PATH}/runtimes/runtime-{RUNTIME_VERSION}/bin/igor/{IGOR_OS_SUBFOLDER}/x64/Igor"
	RUNTIME_PATH=f"{GAMEMAKER_CACHE_PATH}/runtimes/runtime-{RUNTIME_VERSION}"
	try:
		if not os.path.isdir("./igor"):
			os.mkdir("./igor")
		status = subprocess.run(
			[IGOR_PATH, 
			"-j=8",
			f"--user={USER_DIRECTORY_PATH}",
			f"--project={PROJECT_YYP}",
			f"--config={GAMEMAKER_CONFIGURATION}",
			f"--runtimePath={RUNTIME_PATH}",
			"-v",
			"--tf=artifact.zip",

			IGOR_TARGETS[0],
			IGOR_TARGETS[1],
			],
			cwd = "./igor")
	except Exception as e:
		print("Failed to launch igor. Do you have all your variables set correctly?\n" + str(e))
		cleanup()
		exit()

	if (status.returncode != 0):
		print("Something went wrong during building, aborting")
		cleanup()
		exit()

	try:
		os.replace(f"./igor/output/{PROJECT_NAME}/{IGOR_OUTPUT_PATH}", "./igor/mod_data.win")
		os.makedirs("./igor/included_files", exist_ok=True)

		included_files_path = f"./igor/output/{PROJECT_NAME}/{IGOR_ASSETS_FOLDER}"
		for root, directories, files in os.walk(included_files_path):
			relative_root = os.path.relpath(root, included_files_path)
			for directory in directories:
				os.makedirs(f"./igor/included_files/{relative_root}/{directory}", exist_ok=True)
			for file in files:
				if file in IGOR_ASSETS_FILTER:
					continue
				os.replace(f"{root}/{file}", f"./igor/included_files/{relative_root}/{file}")
	except Exception as e:
		print("Failed to copy output datafile/included files from igor. Please report this bug!")
		print(e)
		exit()

	cleanup()

	if (SHOULD_HASH != "0"):
		new_hash = hash_project()
		with open("./igor/hash.txt", 'w') as f:
			f.write(new_hash)


def symlink(target, output):
	if os.name == "nt":
		os.link(target, output)
	else:
		os.symlink(target, output)

### packaging mod
MOD_NAME = ""
def package_mod(linkbase=False):
	global MOD_NAME

	print("---Packaging the mod---")
	if not os.path.isdir("./base/mod"):
		print("base/mod wasn't found. Please create the base/mod folders, and place your mod there.")
		exit()
	if not os.path.isfile("./base/mod/mod.json"):
		print("No mod.json found in base/mod. Please put it there.")
		exit()
	try:
		with open('./base/mod/mod.json') as f:
			mod = json.loads(f.read())
			MOD_NAME = mod["mod_id"]
	except:
		print("Failed to load mod.json, or it was missing the \"mod_id\" field, which is required.")

	if os.path.isdir(f"./base/{MOD_NAME}"):
		print(f"You can't have a folder named \"{MOD_NAME}\" in base, as it would conflict with your mod's own folder!")
		print("(your mod needs to be in base/mod. When packaging, base/mod is copied to out/(mod id))")
		exit()

	if os.path.isdir("./out"):
		print("Deleting previous out folder...")
		shutil.rmtree("./out")
	
	print("Creating out folder...")
	if not linkbase:
		shutil.copytree("./base", "./out")
		if os.path.isdir("./igor/included_files"):
			shutil.copytree("./igor/included_files", "./out/mod", dirs_exist_ok=True)
	else:
		for target in ("./base", "./igor/included_files"):
			for root, directories, files in os.walk(os.path.abspath(target), followlinks=True):
				relative_root = os.path.relpath(root, target)
				for directory in directories:
					os.makedirs(f"./out/{relative_root}/{directory}", exist_ok=True)
				for file in files:
					symlink(f"{root}/{file}",f"./out/{relative_root}/{file}")
			
	if os.path.isfile("./igor/mod_data.win"):
		shutil.copy("./igor/mod_data.win", f"./out/mod/mod_data.win")
	else:
		print("No datafile found in ./igor, so nothing was copied...")

	


	os.rename("./out/mod", f"./out/{MOD_NAME}")

### applying mod ###

def apply_mod():
	print("---Applying the mod---")
	GAME_PATH = demand("GAME_PATH", __file__)
	CLEAN_DATAFILE_PATH = demand("CLEAN_DATAFILE_PATH", __file__)
	GAME_DATAFILE_NAME = demand("GAME_DATAFILE_NAME", __file__)
	G3MAN_PATH = demand("G3MAN_PATH", __file__)
	try:
		status = subprocess.run(
			[G3MAN_PATH, "apply",
				"--path", "out",
				"--datafile", CLEAN_DATAFILE_PATH,
				"--out", GAME_PATH,
				"--outname", GAME_DATAFILE_NAME
			],
			cwd = ".")
	except Exception as e:
		print("Failed to launch g3man. Do you have all your variables set correctly?\n" + str(e))
		return
	if (status.returncode != 0):
		print("Something failed in g3man. Aborting.")
		exit()

timestamp_filename = "frida-timestamp.txt"

def should_check_for_update():
	if not os.path.isfile(timestamp_filename):
		return True
	try:
		with open(timestamp_filename, 'r') as f:
			timestamp = int(f.read())
	except:
		return True

	difference = time.time() - timestamp
	return difference > 0

def save_update_timestamp(offset):
	try:
		with open(timestamp_filename, 'w') as f:
			f.write(str(int(time.time() + offset)))
	except:
		return True

frida_version = 3
def check_update():
	print("Checking for updates...")
	print("Remember that you can disable this by setting CHECK_FOR_UPDATES=0 in frida-config.ini")
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
	else:
		print("You are on the latest version.")
	
	print("See you next week!")
	save_update_timestamp(604800)
	

usage = "Usage: frida.py [ACTION] [OPTIONS]..."
def bad_usage():
	print(usage)
	print("Try 'frida.py --help' for more information.")
	exit()

def is_help(arguments):
	return "-h" in arguments or "--help" in arguments

if __name__ == "__main__":
	# Let me Ctrl+C in peace
	signal.signal(signal.SIGINT, lambda a, b: exit())

	get_options()

	CHECK_FOR_UPDATES = demand("CHECK_FOR_UPDATES")
	
	if (len(sys.argv) < 2):
		bad_usage()
	argument = sys.argv[1]
	if argument == '--help' or argument == 'h':
		print(usage)
		print("Perform ACTION in accordance to frida-config.ini in the same directory.")
		print()
		print("Actions list:")
		print("    build")
		print("    package")
		print("    apply [--linkbase]")
		print("    check_updates")
		print()
		print("You can use '--help' on each of the actions to learn more about them and their options.")
		exit()

	subarguments = sys.argv[2:]
	opname = argument
	if argument == "build":
		if is_help(subarguments):
			print("frida.py build - Builds the mod's GameMaker project.")
			print()
			print("This action will attempt to build the project,")
			print("regardless of the previous build's hash or the SHOULD_BUILD_PROJECT variable.")
			print()
			print("The output datafile will be in igor/mod_data.win.")
			print("Output included files, including streamed music, will be in igor/included_files.")
			exit()
		build_gamemaker_project(force=True)
		print("Done!")
		if (should_check_for_update()):
			check_update()
		exit()
	if argument == "package":
		if is_help(subarguments):
			print("frida.py package - Packages this mod.")
			print()
			print("This action will build the GameMaker project if necessary, and package it into a folder,")
			print("for distribution or application.")
			print()
			print("The output mod folder will be in out/(mod's ID)")
			print("The mod ID is defined in base/mod/mod.json.")
			exit()
		build_gamemaker_project()
		package_mod()
		print(f"Done! Your mod is in out/{MOD_NAME}.")
		if (should_check_for_update()):
			check_update()
		exit()
	if argument == "apply":
		if is_help(subarguments):
			print("frida.py apply [ARGUMENTS] - Applies this mod.")
			print()
			print("This action will build the GameMaker project if necessary, package it into a folder,")
			print("And then call g3man to apply it on a GameMaker game.")
			print()
			print("Arguments:")
			
			print("  -l, --linkbase     When packaging, link files in \"out\" to \"base\" instead of copying")
			indent = "                       "
			print(f"{indent}This is useful if your mod has included files it reads from at runtime,")
			print(f"{indent}as this argument effectively makes it so any changes to files in \"base\"")
			print(f"{indent}are visible to the modded game immediately.")
			print(f"{indent}Note: This argument uses hard links on Windows")
			print(f"{indent}and symlinks everywhere else.")
			exit()
		linkbase = "-l" in subarguments or "--linkbase" in subarguments 

		build_gamemaker_project()
		package_mod(linkbase)
		apply_mod()
		print("Done! Your mod has been applied.")
		if (should_check_for_update()):
			check_update()
		exit()
	if argument == "check_updates":
		if is_help(subarguments):
			print("frida.py check_updates - Checks for updates to Frida.")
			print()
			print("This action will check https://github.com/skirlez/frida/releases,")
			print("And print a message if there's a newer version.")
			print()
			print("This action works regardless of CHECK_FOR_UPDATES.")
			print("That option only controls if the other actions occassionally perform the update check.")
			exit()
		check_update()
		exit()


	bad_usage()
	