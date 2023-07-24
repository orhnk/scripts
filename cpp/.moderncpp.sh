#!/bin/bash
# COPYRIGHT (c) 2023 UTFeight MIT License (MIT)
#
# NOTE: This script is incomplete! Do not use it!
#
# This script is a wrapper for the filipdutescu/modern-cpp-template on github..
# It will create a new project based on the template.
# Renames are done automatically.
#
# Usage:
#  moderncpp.sh --install  # installs the script
#  moderncpp.sh --uninstall  # uninstalls the script
#  moderncpp.sh --help  # prints help
#  moderncpp.sh --install --force  # force install
#               --force --install  # force install
#
# vibrantly colorized stdout

$colored_help_message <<~HEREDOC
  \e[1mNAME\e[0m
    moderncpp.sh -- create a modern C++ project with CMake and CTest
  \e[1mSYNOPSIS\e[0m
    \e[1mmoderncpp.sh\e[0m [\e[4mOPTIONS\e[0m] [\e[4mARGUMENTS\e[0m]
  \e[1mDESCRIPTION\e[0m
    \e[1mmoderncpp.sh\e[0m creates a modern C++ project with CMake and CTest
    \e[4mARGUMENTS\e[0m
      \e[1m--install\e[0m
        installs the script
      \e[1m--uninstall\e[0m
        uninstalls the script
      \e[1m--help\e[0m
        prints help
      \e[1m--install --force\e[0m
        force install
      \e[1m--force --install\e[0m
        force install
  \e[1mAUTHOR\e[0m
    \e[1mmoderncpp.sh\e[0m was written by \e[4mUTFeight\e[0m.
  \e[1mCOPYRIGHT\e[0m
    \e[1mmoderncpp.sh\e[0m is licensed under the MIT License.
  \e[1mSEE ALSO\e[0m
    \e[1mmoderncpp.sh\e[0m is available at UTFeight/Scripts on GitHub. (Inside the cpp/ dir)
~HEREDOC

# ANSI escape codes
$bold="\e[1m"
$underline="\e[4m"
$reset="\e[0m"
$red="\e[31m"
$green="\e[32m"
$yellow="\e[33m"
$blue="\e[34m"
$magenta="\e[35m"
$cyan="\e[36m"
$white="\e[37m"

$black="\e[30m"
$bg_red="\e[41m"
$bg_green="\e[42m"
$bg_yellow="\e[43m"
$bg_blue="\e[44m"
$bg_magenta="\e[45m"
$bg_cyan="\e[46m"
$bg_white="\e[47m"
$bg_black="\e[40m"

# ANSI escape codes for bold
$bold_red="\e[1;31m"
$bold_green="\e[1;32m"
$bold_yellow="\e[1;33m"
$bold_blue="\e[1;34m"
$bold_magenta="\e[1;35m"
$bold_cyan="\e[1;36m"
$bold_white="\e[1;37m"

# ANSI escape codes for underline
$underline_red="\e[4;31m"
$underline_green="\e[4;32m"
$underline_yellow="\e[4;33m"
$underline_blue="\e[4;34m"
$underline_magenta="\e[4;35m"
$underline_cyan="\e[4;36m"
$underline_white="\e[4;37m"
$underline_black="\e[4;30m"

# Script variables
$script_name="moderncpp.sh"
$script_path=File.expand_path(File.dirname(__FILE__) )
$script_full_path=File.expand_path(__FILE__)
$script_version="1.0.0"
$script_author="UTFeight"
$script_license="MIT"
$script_description="create a modern C++ project with CMake and CTest"
$script_url=""
$script_help_message=$colored_help_message
$script_help_message.gsub!("\e[1m", $bold)
$script_help_message.gsub!("\e[4m", $underline)
$script_help_message.gsub!("\e[0m", $reset)
$script_help_message.gsub!("\e[31m", $red)
$script_help_message.gsub!("\e[32m", $green)
$script_help_message.gsub!("\e[33m", $yellow)
$script_help_message.gsub!("\e[34m", $blue)
$script_help_message.gsub!("\e[35m", $magenta)
$script_help_message.gsub!("\e[36m", $cyan)
$script_help_message.gsub!("\e[37m", $white)
$script_help_message.gsub!("\e[40m", $bg_black)
$script_help_message.gsub!("\e[41m", $bg_red)
$script_help_message.gsub!("\e[42m", $bg_green)
$script_help_message.gsub!("\e[43m", $bg_yellow)
$script_help_message.gsub!("\e[44m", $bg_blue)
$script_help_message.gsub!("\e[45m", $bg_magenta)
$script_help_message.gsub!("\e[46m", $bg_cyan)
$script_help_message.gsub!("\e[47m", $bg_white)
$script_help_message.gsub!("\e[1;31m", $bold_red)
$script_help_message.gsub!("\e[1;32m", $bold_green)
$script_help_message.gsub!("\e[1;33m", $bold_yellow)
$script_help_message.gsub!("\e[1;34m", $bold_blue)
$script_help_message.gsub!("\e[1;35m", $bold_magenta)
$script_help_message.gsub!("\e[1;36m", $bold_cyan)
$script_help_message.gsub!("\e[1;37m", $bold_white)
$script_help_message.gsub!("\e[4;31m", $underline_red)
$script_help_message.gsub!("\e[4;32m", $underline_green)
$script_help_message.gsub!("\e[4;33m", $underline_yellow)
$script_help_message.gsub!("\e[4;34m", $underline_blue)
$script_help_message.gsub!("\e[4;35m", $underline_magenta)
$script_help_message.gsub!("\e[4;36m", $underline_cyan)
$script_help_message.gsub!("\e[4;37m", $underline_white)
$script_help_message.gsub!("\e[4;30m", $underline_black)

# Script functions
def print_help
  puts $script_help_message
end

def print_version
  puts "#{$script_name} #{$script_version}"
end


# Script main

# Check if the script is being run as root

if Process.uid == 0
  puts "#{$script_name}: #{$bold_red}error: #{$reset}#{$bold}this script must not be run as root#{$reset}"
  exit 1
end
