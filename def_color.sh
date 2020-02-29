# Source this in your script to use the colors as follows:
# echo -e "Hello ${BLUE}World${NC}!"
# or, printf "Hello ${RED}World${$NC}!\n"

# Should work on most *nix with a bash compatible shell

# The ANSI color definitions are:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

BLACK='\033[0;30m'
BLUE='\033[0;34m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
DARK_GRAY='\033[1;30m'
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
LIGHT_CYAN='\033[1;36m'
LIGHT_GRAY='\033[0;37m'
LIGHT_GREEN='\033[1;32m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_RED='\033[1;31m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'

NC='\033[0m' # No Color

