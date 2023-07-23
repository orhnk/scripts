#!/bin/bash

# This script is used to generate a C++ project
# with conan and cmake.
# Written by: utfeight
# Date: 2023-07-23
# Version: 0.1.0
# License: MIT
#
# Usage: ./ctemplate.sh <project_name>
# Example: ./ctemplate.sh my_project
#
# This will generate a project named my_project
# with a conanfile.py and a CMakeLists.txt.
# You can use conan to install dependencies and
# cmake to build the project.
#
# Credits:
#   - cpp-templat       : https://github.com/filipdutescu/modern-cpp-template/
#   - readme-template   : https://github.com/othneildrew/Best-README-Template/

# If not argument specified, exit
if [ -z "$1" ]; then
  echo -e "\033[31mSpecify a project name\033[0m"
  exit 1
fi

# Help message
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	# Non colorized:
	# echo "Usage: ctemplate <project_name>"
	# echo ""
	# echo "--install        : Install ctemplate to /usr/local/bin"
	# echo "--install --force: Override ctemplate to /usr/local/bin"

	# Colorized vibrantly:
	# with the same text above
	echo -e "\033[32mUsage: ctemplate <project_name>\033[0m"
	echo ""
	echo -e "\033[32m\033[36m--install\033[0m        : Install ctemplate to /usr/local/bin"
	echo -e "\033[32m\033[36m--install --force\033[0m: Override ctemplate to /usr/local/bin"
	exit 0

fi

# If you want to use this script anywhere, you can
# INSTALL (symlink) ctemplate (this script) if not exists in /usr/local/bin
# when the first argument is --install
# Usage: ./ctemplate.sh --install

if [ "$1" = "--install" ]; then
	if [ "$2" = "--force" ]; then
		echo -e "\033[36mForce installing ctemplate to /usr/local/bin\033[0m"
		sudo ln -sf "$(pwd)/ctemplate.sh" /usr/local/bin/ctemplate || exit 1
		echo -e "\033[32m\033[32mSuccess!\033[0m"
		exit 0
	fi
	if [ ! -f "/usr/local/bin/ctemplate" ]; then
		sudo cp "$(pwd)/ctemplate.sh" /usr/local/bin/ctemplate || exit 1
		exit 0
	else
		# Colorize the output with red, green and default
		echo -e "\033[31m/usr/local/bin/ctemplate already exists.\033[0m use \033[32m--install --force\033[0m to override."
		exit 1
	fi

# Using --force with --install will override the existing ctemplate in /usr/local/bin
elif [ "$1" = "--force" ] && [ "$2" = "--install" ]; then
	echo -e "\033[36mForce installing ctemplate to /usr/local/bin\033[0m"
	sudo ln -sf "$(pwd)/ctemplate.sh" /usr/local/bin/ctemplate || exit 1
	echo -e "\033[32m\033[32mSuccess!\033[0m"
	exit 0
fi

project_name=$1

# If the first argument is empty, exit
if [ -z "$project_name" ]; then
	echo -e "\033[31mSpecify a project name\033[0m"
fi

# If the project name already exists, look whether --force is specified, if so, override it
# if not, exit
if [ -d "$project_name" ]; then
  if [ "$2" = "--force" ]; then
    echo -e "\033[36mForce overriding $project_name\033[0m"
    rm -rf "$project_name"
  else
    echo -e "\033[31m$project_name already exists.\033[0m use \033[32m--force\033[0m to override."
    exit 1
  fi
fi

git clone	https://github.com/kigster/cmake-project-template	"$project_name"
cd "$project_name" || exit
bash build-and-run

# Allow cmake to generate compile_commands.json
echo -e "\033[36mCMake compile_commands.json\033[0m"
echo "set(CMAKE_EXPORT_COMPILE_COMMANDS ON)" >> CMakeLists.txt
echo -e "\033[32m\033[32mSuccess!\033[0m"

# Allow conan to generate conanbuildinfo.cmake
echo -e "\033[36mCMake project\033[0m"
cmake .
echo -e "\033[32m\033[32mSuccess!\033[0m"
