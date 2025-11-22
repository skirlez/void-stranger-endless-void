import os
import shutil
import subprocess
import shared as options
import build
import package


def apply_mod():
	print("---Applying the mod---")
	GAME_PATH = options.demand("GAME_PATH", __file__)
	CLEAN_DATAFILE_PATH = options.demand("CLEAN_DATAFILE_PATH", __file__)
	GAME_DATAFILE_NAME = options.demand("GAME_DATAFILE_NAME", __file__)
	G3MAN_PATH = options.demand("G3MAN_PATH", __file__)
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

if __name__ == "__main__":
	options.get_options()
	build.build_gamemaker_project()
	package.package_mod()
	apply_mod()
	print("Done! Your mod has been applied")