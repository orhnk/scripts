#!/bin/bash

# This script is used to generate a C++ project
# with conan and cmake.
# Written by: utfeight
# Date: 2023-07-23
# Version: 0.1.0
# License: MIT
#
# Usage: ./cgen.sh <project_name>
# Example: ./cgen.sh my_project
#
# This will generate a project named my_project
# with a conanfile.py and a CMakeLists.txt.
# You can use conan to install dependencies and
# cmake to build the project.

# Help message
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	# Non colorized:
	# echo "Usage: cgen <project_name>"
	# echo ""
	# echo "--install        : Install cgen to /usr/local/bin"
	# echo "--install --force: Override cgen to /usr/local/bin"

	# Colorized vibrantly:
	# with the same text above
	echo -e "\033[32mUsage: cgen <project_name>\033[0m"
	echo ""
	echo -e "\033[32m\033[31m--install\033[0m        : Install cgen to /usr/local/bin"
	echo -e "\033[32m\033[31m--install --force\033[0m: Override cgen to /usr/local/bin"
	exit 0

fi

# If you want to use this script anywhere, you can
# INSTALL (symlink) cgen (this script) if not exists in /usr/local/bin
# when the first argument is --install
# Usage: ./cgen.sh --install

if [ "$1" = "--install" ]; then
	if [ "$2" = "--force" ]; then
    sudo ln -sf "$(pwd)/cgen.sh" /usr/local/bin/cgen || exit 1
		echo -e "\033[32m\033[31mForce\033[0m installed cgen to /usr/local/bin.\033[0m"
		exit 0
	fi
	if [ ! -f "/usr/local/bin/cgen" ]; then
		sudo cp "$(pwd)/cgen.sh" /usr/local/bin/cgen || exit 1
		exit 0
	else
		# Colorize the output with red, green and default
		echo -e "\033[31m/usr/local/bin/cgen already exists.\033[0m use \033[32m--install --force\033[0m to override."
		exit 1
	fi

# Using --force with --install will override the existing cgen in /usr/local/bin
elif [ "$1" = "--force" ] && [ "$2" = "--install" ]; then
  sudo ln -sf "$(pwd)/cgen.sh" /usr/local/bin/cgen || exit 1
	echo -e "\033[32m\033[31mForce\033[0m installed cgen to /usr/local/bin.\033[0m"
	exit 0
fi

project_name=$1

# If the first argument is empty, exit
if [ -z "$project_name" ]; then
	echo "Please specify a project name." && exit 1
fi

mkdir "$project_name"
cd "$project_name" || exit

conan new "$project_name"/0.1.0 --template=cmake_exe

mkdir build || exit
cd build || exit
conan install .. --build=missing

cd .. || exit

# LICENSE of the $project_name in one line
echo -n "LICENSE for $project_name: "
read -r license
sed -i 's/<Put the package license here>/'"$license"'/g' conanfile.py

# Author of the $project_name
echo -n "Author of $project_name: "
read -r author
sed -i 's/<Put your name here>/'"$author"'/g' conanfile.py

# Gmail of the $author
echo -n "Gmail of the $author (Enter to pass): "
read -r gmail
if [ -n "$gmail" ]; then
	sed -i 's/<And your email here>/'"$gmail"'/g' conanfile.py
fi

# URL of the $project_name
echo -n "URL of $project_name (Enter to pass): "
read -r url
if [ -n "$url" ]; then
	sed -i 's/<Package recipe repository url here, for issues about the package>/'"$url"'/g' conanfile.py
fi

# Description of the $project_name
echo -n "Description of $project_name: "
read -r description
sed -i -e "s/<Description of $project_name here>/""$description"'/gi' conanfile.py

# Topics of the $project_name
echo -n "Topics of $project_name (Seperate by spaces, Enter to pass): "
read -r topics
# split spaces
IFS=' ' read -r -a array <<<"$topics"

# Print the array, seperated with commas
topics_str=""
for element in "${array[@]}"; do
	topics_str+="\"$element\", "
done
topics_str=${topics_str::-2} # remove the last comma and space
echo "$topics_str"

sed -i 's/\"<Put some tag here>\", \"<here>\", \"<and here>\"/'"$topics_str"'/g' conanfile.py

# os, copiler, build_type, arch
echo -n "OS: "
read -r os
sed -i 's/"os"/'\""$os"\"'/g' conanfile.py

echo -n "Compiler: "
read -r compiler
sed -i 's/"compiler"/'\""$compiler"\"'/g' conanfile.py

echo -n "Build type: "
read -r build_type
sed -i 's/"build_type"/'\""$build_type"\"'/g' conanfile.py

echo -n "Arch: "
read -r arch
sed -i 's/"arch"/'\""$arch"\"'/g' conanfile.py

# I use neovim with clangd lsp, this is used to
# generate compile_commands.json which makes sure
# lsp knows where to look for header files.
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1
