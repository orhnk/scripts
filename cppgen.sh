#!/bin/bash

# This script generates a C++ project from modern-cpp-template
#
# project name is the first argument passed:
# ./cppgen.sh project_name

project_name=$1

git clone https://github.com/filipdutescu/modern-cpp-template/ "$project_name/"
cd "$project_name" || exit

rm -rf .git

cd include || exit
mv project "$project_name"

cd .. || exit

cd cmake || exit
mv ProjectConfig.cmake.in "$project_name"Config.cmake.in

cd .. || exit

cd .github/workflows || exit

sed -i "s/Project/$project_name/g" ubuntu.yml

cd ../.. || exit

sed -i "s/\"Project\"/$project_name/g" CMakeLists.txt
