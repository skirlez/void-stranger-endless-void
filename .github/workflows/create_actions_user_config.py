import os
from os.path import abspath
import json
import sys

if __name__ == "__main__":
	with open("g3man/frida-user-config.jsonc", "wt") as f:
		
		
		runtime_dir = sys.argv[1]
		cache_dir = abspath(f"{runtime_dir}/../..")

		# not needed anymore lol
		user_dir = sys.argv[2]

		json.dump({
			"gms2": {
				"cache_path": cache_dir,
			},		
			"apply": {
				"g3man_path": abspath("g3man/g3man-executable/g3man/g3man.exe"),
				"game_path": abspath("g3man/vs"),
				"clean_datafile_path": abspath("g3man/vs/data.win"),
				"output_datafile_name": "final_data.win",		
			},
			"check_for_updates": True,  
			"format_version": 1
		}, f, indent=4)
