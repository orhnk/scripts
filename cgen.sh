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

project_name=$1
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
