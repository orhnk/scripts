#!/bin/bash

# This script is used to generate a C++ project
# with conan and cmake.
# Written by: utfeight
# Date: 2023-07-23
# Version: 0.1.0
# License: MIT
#
# Usage: ./ctemp.sh <project_name>
# Example: ./ctemp.sh my_project
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
	# echo "Usage: ctemp <project_name>"
	# echo ""
	# echo "--install        : Install ctemp to /usr/local/bin"
	# echo "--install --force: Override ctemp to /usr/local/bin"

	# Colorized vibrantly:
	# with the same text above
	echo -e "\033[32mUsage: ctemp <project_name>\033[0m"
	echo ""
	echo -e "\033[32m\033[36m--install\033[0m        : Install ctemp to /usr/local/bin"
	echo -e "\033[32m\033[36m--install --force\033[0m: Override ctemp to /usr/local/bin"
	echo -e "\033[32m\033[36m-e --executable\033[0m  : Create project as an executable (default)"
	echo -e "\033[32m\033[36m-l --library\033[0m     : Create project as an library"
	exit 0

fi

# If you want to use this script anywhere, you can
# INSTALL (symlink) ctemp (this script) if not exists in /usr/local/bin
# when the first argument is --install
# Usage: ./ctemp.sh --install

if [ "$1" = "--install" ]; then
	if [ "$2" = "--force" ]; then
		echo -e "\033[36mForce installing ctemp to /usr/local/bin\033[0m"
		sudo ln -sf "$(pwd)/ctemp.sh" /usr/local/bin/ctemp || exit 1
		echo -e "\033[32m\033[32mSuccess!\033[0m"
		exit 0
	fi
	if [ ! -f "/usr/local/bin/ctemp" ]; then
		sudo cp "$(pwd)/ctemp.sh" /usr/local/bin/ctemp || exit 1
		exit 0
	else
		# Colorize the output with red, green and default
		echo -e "\033[31m/usr/local/bin/ctemp already exists.\033[0m use \033[32m--install --force\033[0m to override."
		exit 1
	fi

# Using --force with --install will override the existing ctemp in /usr/local/bin
elif [ "$1" = "--force" ] && [ "$2" = "--install" ]; then
	echo -e "\033[36mForce installing ctemp to /usr/local/bin\033[0m"
	sudo ln -sf "$(pwd)/ctemp.sh" /usr/local/bin/ctemp || exit 1
	echo -e "\033[32m\033[32mSuccess!\033[0m"
	exit 0
fi

project_name=$1
Project_name="$(tr '[:lower:]' '[:upper:]' <<<${project_name:0:1})${project_name:1}"
PROJECT_NAME="$(tr '[:lower:]' '[:upper:]' <<<$project_name)"

# If the first argument is empty, exit
if [ -z "$project_name" ]; then
	echo -e "\033[31mSpecify a project name\033[0m"
fi

# If the project name already exists, look whether --force is specified, if so, override it
# if not, exit
if [ -d "$project_name" ]; then
	if [ "$2" = "--force" ]; then
		echo -e "\033[36mOverriding $project_name\033[0m"
		rm -rf "$project_name"
	else
		echo -e "\033[31m$project_name already exists.\033[0m use \033[32m--force\033[0m to override."
		exit 1
	fi
fi

git clone https://github.com/UTFeight/Cpp-Cmake-Template "$project_name"
cd "$project_name" || exit 1
rm -rf ./.git

cd include || exit 1

cd project || exit 1
sed -i "s/project/$project_name/g" tmp.hpp
sed -i "s/tmp/$project_name/g" tmp.hpp
mv tmp.hpp "$project_name".hpp
cd .. || exit 1

mv project "$project_name"
cd .. || exit 1

cd src || exit 1

if [ "$2" != "--library" ] && [ "$2" != "-l" ]; then
	echo -e "\033[32mCreating main.cpp\033[0m"
	echo "#include <iostream>
  
  int main() {
    std::cout << \"Hello World!\" << std::endl;
    return 0;
  }" >>main.cpp
fi

sed -i "s/project/$project_name/g" tmp.cpp
sed -i "s/tmp/$project_name/g" tmp.cpp
mv tmp.cpp "$project_name".cpp
cd .. || exit 1

cd test || exit 1

cd src || exit 1
sed -i "s/project/$project_name/g" tmp_test.cpp
sed -i "s/tmp/$project_name/g" tmp_test.cpp
mv tmp_test.cpp "$project_name"_test.cpp # test_<file> is erroneous Some regex expect trailing _test postfix
cd .. || exit 1

# TODO

cd .. || exit 1

cd cmake || exit 1
sed -i "s/tmp/$project_name/g" SourcesAndHeaders.cmake
sed -i "s/project/$project_name/g" SourcesAndHeaders.cmake
mv ProjectConfig.cmake.in "$project_name"Config.cmake.in

if [ "$2" != "--library" ] && [ "$2" != "-l" ]; then
	sed -i "s/\"Build the project as an executable, rather than a library.\" OFF/\"Build the project as an executable, rather than a library.\" ON/g" StandardSettings.cmake
fi
cd .. || exit 1

cd .github/workflows || exit 1
sed -i "s/Project/$Project_name/g" ubuntu.yml
cd ../.. || exit 1

sed -i "s/\"Project\"/$project_name/g" CMakeLists.txt

# Allow cmake to generate compile_commands.json
echo -e "\033[36mCMake compile_commands.json\033[0m"
echo "set(CMAKE_EXPORT_COMPILE_COMMANDS ON)" >>CMakeLists.txt
echo -e "\033[32m\033[32mSuccess!\033[0m"

echo -e "\033[36mConfiguring clang-format\033[0m"
rm -rf ./.clang-format
echo "AccessModifierOffset: -2
AlignAfterOpenBracket: AlwaysBreak
AlignConsecutiveMacros: false
AlignConsecutiveAssignments: false
AlignConsecutiveDeclarations: false
AlignEscapedNewlines: DontAlign
AlignOperands: false
AlignTrailingComments: false
AllowAllArgumentsOnNextLine: false
AllowAllConstructorInitializersOnNextLine: false
AllowAllParametersOfDeclarationOnNextLine: false
AllowShortBlocksOnASingleLine: false
AllowShortCaseLabelsOnASingleLine: false
AllowShortFunctionsOnASingleLine: Empty
AllowShortIfStatementsOnASingleLine: Never
AllowShortLambdasOnASingleLine: All
AllowShortLoopsOnASingleLine: false
AlwaysBreakAfterReturnType: None
AlwaysBreakBeforeMultilineStrings: true
AlwaysBreakTemplateDeclarations: Yes
BinPackArguments: false
BinPackParameters: false
BreakBeforeBinaryOperators: NonAssignment
BreakBeforeBraces: Attach
BreakBeforeTernaryOperators: true
BreakConstructorInitializers: AfterColon
BreakInheritanceList: AfterColon
BreakStringLiterals: false
ColumnLimit: 80
CompactNamespaces: false
ConstructorInitializerAllOnOneLineOrOnePerLine: true
ConstructorInitializerIndentWidth: 4
ContinuationIndentWidth: 4
Cpp11BracedListStyle: true
DerivePointerAlignment: false
FixNamespaceComments: true
IncludeBlocks: Regroup
IncludeCategories:
  - Regex:           '^<ext/.*\.h>'
    Priority:        2
    SortPriority:    0
    CaseSensitive:   false
  - Regex:           '^<.*\.h>'
    Priority:        1
    SortPriority:    0
    CaseSensitive:   false
  - Regex:           '^<.*'
    Priority:        2
    SortPriority:    0
    CaseSensitive:   false
  - Regex:           '.*'
    Priority:        3
    SortPriority:    0
    CaseSensitive:   false
IncludeIsMainRegex: '([-_](test|unittest))?$'
IndentCaseLabels: true
IndentPPDirectives: BeforeHash
IndentWidth: 4
IndentWrappedFunctionNames: false
KeepEmptyLinesAtTheStartOfBlocks: false
MaxEmptyLinesToKeep: 1
NamespaceIndentation: Inner
PointerAlignment: Left
ReflowComments: false
SortIncludes: true
SortUsingDeclarations: true
SpaceAfterCStyleCast: false
SpaceAfterLogicalNot: false
SpaceAfterTemplateKeyword: false
SpaceBeforeAssignmentOperators: true
SpaceBeforeCpp11BracedList: true
SpaceBeforeCtorInitializerColon: true
SpaceBeforeInheritanceColon: false
SpaceBeforeParens: ControlStatements
SpaceBeforeRangeBasedForLoopColon: true
SpaceInEmptyParentheses: false
SpacesBeforeTrailingComments: 2
SpacesInAngles: false
SpacesInCStyleCastParentheses: false
SpacesInContainerLiterals: false
SpacesInParentheses: false
SpacesInSquareBrackets: false
Standard: Cpp11
TabWidth: 4
UseTab: Never
" >>.clang-format

echo -e "\033[36mCMake project\033[0m"
mkdir build/ && cd build/ || exit 1
cmake ..
make
echo -e "\033[32m\033[32mSuccess!\033[0m"

echo ""
echo ""

echo -e "\033[36mTo Build the $project_name\033[0m"
echo "cd build/
cmake .. -DCMAKE_INSTALL_PREFIX=/absolute/path/to/custom/install/directory
cmake --build . --target install"

echo ""

echo -e "\033[36mTo Test the $project_name\033[0m"
echo "cd build/"
echo "ctest -C Release"

echo ""

echo -e "\033[36mTo Install already build $project_name\033[0m"
printf "cmake --build build --target install --config Release
\033[33m\033[33m# a more general syntax for that command is:\033[0m
cmake --build <build_directory> --target install --config <desired_config>"

echo ""
echo ""

echo -e "\033[36mTo Build $project_name Docs\033[0m"
echo 'cd build/
cmake .. -D'"$project_name"'_ENABLE_DOXYGEN=1 -DCMAKE_INSTALL_PREFIX=/absolute/path/to/custom/install/directory
cmake --build . --target doxygen-docs'
