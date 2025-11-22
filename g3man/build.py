import subprocess
import os
import shutil
import shared as options
import hashlib

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
		for root, _, files in os.walk(full_item_path):
			for file_path in sorted(files):
				full_path = os.path.join(root, file_path)
				relative_path = os.path.relpath(full_path, project_folder)
				hash_file(full_path, relative_path, hash_func)


	return hash_func.hexdigest()

def cleanup():
	if os.path.isdir("./igor/output"):
		print("Deleting igor output...")
		shutil.rmtree("./igor/output", ignore_errors=True)
	try:
		os.remove("./igor/output/artifact.zip")
	except:
		pass
def build_gamemaker_project():
	SHOULD_BUILD_PROJECT = options.demand("SHOULD_BUILD_PROJECT", __file__)
	if (SHOULD_BUILD_PROJECT == "0"):
		print("SHOULD_BUILD_PROJECT is set to 0, skipping build...")
		return

	SHOULD_HASH = options.demand("SHOULD_HASH", __file__)
	if (SHOULD_HASH != "0"):
		previous_hash = ""
		project_hash = ""
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

	
	PROJECT_NAME = options.demand("PROJECT_NAME", __file__)
	GAMEMAKER_CONFIGURATION = options.demand("GAMEMAKER_CONFIGURATION", __file__)
	RUNTIME_VERSION = options.demand("RUNTIME_VERSION", __file__)
	GAMEMAKER_CACHE_PATH = options.demand("GAMEMAKER_CACHE_PATH", __file__)
	USER_DIRECTORY_PATH = options.demand("USER_DIRECTORY_PATH", __file__)

	PROJECT_YYP = os.path.abspath(f"../{PROJECT_NAME}.yyp")

	if os.name == "posix":
		IGOR_OS_SUBFOLDER="linux"
		IGOR_TARGETS=["Linux", "Package"]
		IGOR_OUTPUT_PATH="package/assets/game.unx"
	elif os.name == "nt":
		IGOR_OS_SUBFOLDER="windows"
		IGOR_OUTPUT_PATH="data.win"
		IGOR_TARGETS=["Windows" "PackageZip"]

	IGOR_PATH=f"{GAMEMAKER_CACHE_PATH}/runtimes/runtime-{RUNTIME_VERSION}/bin/igor/{IGOR_OS_SUBFOLDER}/x64/Igor"
	RUNTIME_PATH=f"{GAMEMAKER_CACHE_PATH}/runtimes/runtime-{RUNTIME_VERSION}"
	try:
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
		return

	if (status.returncode != 0):
		print("Something went wrong during building, aborting")
		cleanup()
		exit()

	try:
		os.replace(f"./igor/output/{PROJECT_NAME}/{IGOR_OUTPUT_PATH}", "./igor/mod_data.win")
	except:
		print("Failed to find output datafile from igor. Please report this bug!")

	cleanup()

	if (SHOULD_HASH != "0"):
		if project_hash == "":
			project_hash = hash_project()
		with open("./igor/hash.txt", 'w') as f:
			f.write(project_hash)



if __name__ == "__main__":
	options.get_options()
	build_gamemaker_project()
	print("Done!")