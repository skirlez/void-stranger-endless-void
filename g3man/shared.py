import os
import shutil

options = {}
def get_options():
	if not os.path.isfile("user-config.ini"):
		shutil.copy(".user-config-template.ini", "user-config.ini")
		print("user-config.ini has been created! Open it up in a text editor, and fill in the variables according to the comments.")
		exit()


	with open("user-config.ini") as f:
		for line in f:
			line = line.strip()
			if line.startswith('#'):
				continue
			if not '=' in line:
				continue
			(varname, value) = line.split('=', 2)
			value = value.strip().removeprefix('"').removesuffix('"')
			options[varname] = value

def demand(name, filename, can_be_empty=False):
	msg = f"{filename} requires {name} to be set, but it is not set. Please set it in user-config.ini."
	if not name in options:
		print(msg)
		exit()
	value = options[name]
	if value == "" and not can_be_empty:
		print(msg)
		exit()
	return value



if __name__ == "__main__":
	print("This file just holds some shared code between the Python scripts, so it doesn't have anything useful to execute on its own...")