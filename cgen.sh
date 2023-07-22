#!/bin/bash

project_name=$1
mkdir "$project_name"
cd "$project_name" || exit

conan new "$project_name"/0.1.0 --template=cmake_exe
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1
