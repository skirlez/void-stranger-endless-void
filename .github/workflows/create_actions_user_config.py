import os
from os.path import abspath
import json
import sys

if __name__ == "__main__":
	with open("g3man/frida-user-config.jsonc", "wt") as f:
		
		
		runtime_dir = sys.argv[1]
		cache_dir = abspath(f"{runtime_dir}/../..")
		
		user_dir = sys.argv[2]

		json.dump({
			# this is amazing i think
			"g3man_path" : abspath("g3man/g3man-executable/g3man/g3man.exe"),
			
			"clean_datafile_path" : abspath("g3man/vs/data.win"),
			"game_path": abspath("g3man/vs"),
			"game_datafile_name" : "final_data.win",
			"start_game_command" : "",
			
			"gamemaker_cache_path" : cache_dir,
			"gamemaker_user_directory_path" : user_dir,
			"check_for_updates" : False,
			"format_version" : 1
		}, f, indent=4)
