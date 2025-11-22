import os
import shutil
import shared as options
import build

def package_mod():
	print("---Packaging the mod---")

	if os.path.isdir("./out"):
		print("Deleting previous out folder...")
		shutil.rmtree("./out")
	
	print("Creating out folder...")
	shutil.copytree("./base", "./out")
	if os.path.isfile("./igor/mod_data.win"):
		shutil.copy("./igor/mod_data.win", "./out/mod/mod_data.win")
	else:
		print("No datafile found in ./igor, so nothing was copied...")

	

if __name__ == "__main__":
	options.get_options()
	build.build_gamemaker_project()
	package_mod()
	print("Done! Your mod is in out/mod.")