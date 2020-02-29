#!/bin/bash

# SAM Helper script; Written by Furquan Ahmad
# Will run under any Linux/Unix(s) running any kind of bash
# compatible shell.

# Global Variables/Constants:
source def_color.sh # load color constants

std_in=""
count=0

LOOKUP_PATH_1="/dev/sda2" # <-- is the lookup path by default
LOOKUP_PATH_2="/dev/sda3"
LOOKUP_PATH_3="/dev/sda4"
LOOKUP_PATH_X="/dev/sda1"
LOOKUP_DEFAULT=$LOOKUP_PATH_1 # stores the default lookup path
MOUNT_DEFAULT="/mnt/sda"

# Functions:
exit_normal() {
	echo -e "
${LIGHT_CYAN}Thank you for using sam-helper!${NC}"
	exit
}

readln() {
	echo -n "$1"
	read -r std_in
}

readlne() {
	echo -ne "$1"
	read -r std_in
}

check_root() {
	if [ ! "$EUID" = 0 ]; then
		echo -e "${RED}User is not root${NC}. Stop."
		exit_normal
	fi
}

check_chntpw() {
	if [ ! $(command -v chntpw) ]; then
		echo -e "${CYAN}chntpw${NC} ${RED}does not exist${NC}. Stop."
		exit_normal
	fi
}

check_system32() {
	echo -e "\tRunning mount commands..."
	mkdir $MOUNT_DEFAULT
	mount "$1" $MOUNT_DEFAULT
	echo -e "\tChecking for System32..."
	if [ ! -d "$MOUNT_DEFAULT/Windows" ]; then
		echo -e "\tSystem32 not found."
		echo -e "\tUnmounting..."
		umount "$1"
		rmdir $MOUNT_DEFAULT
		return 1
	else
		echo -e "\t${GREEN}System32 found${NC} in $1."
		echo -e "Using ${YELLOW}$1${NC} as lookup path."
		LOOKUP_DEFAULT="$1"
		return 0
	fi
}

run_diagnosis() {
	echo -e "${CYAN}Running detailed diagnosis...${NC}
"
	for path in $LOOKUP_PATH_1 $LOOKUP_PATH_2 $LOOKUP_PATH_3 $LOOKUP_PATH_X; do
		echo -e "Running mount commands...
Mounting at $MOUNT_DEFAULT...
Lookup path $path"
		mkdir $MOUNT_DEFAULT
		mount $path $MOUNT_DEFAULT
		echo "Listing directory..."
		ls --color=auto $MOUNT_DEFAULT
		echo "Dumping hierarchy..."
		echo -e "\n\t\t---$path---\n" > HIERDUMP
		find $MOUNT_DEFAULT -maxdepth 2 -type d -not -path '*/\.*' >> HIERDUMP
		echo -e "Unmount $path..."
		umount "$path"
	done

	echo "Finishing up..."
	rmdir "$MOUNT_DEFAULT"
	echo -e "File hierarchy dumped to ${LIGHT_GREEN}./HIERDUMP${NC}."
}



# Errors
err_sys32_missing() {
	echo -e "${RED}System32 not found on system${NC}. Stop."
	readln "
Do you wish to see a detailed diagnosis? (Y/N) "
	if [ "$std_in" = "Y" ]; then
		run_diagnosis
	fi
	echo -e "\nExitting...
"
	exit_normal
}

# Main code
clear
readlne "+----------------------------------------------------------------------------+
|${RED}WARNING${NC}: Improper usage of this script may damage your system or render it  |
|unusable. Proceed with caution. The author(s) of this script will NOT be    |
|liable for any damages incurred through the use of this script.             |
|                                                                            |
|Are you sure you want to run this script?                                   |
|                          ${LIGHT_BLUE}[YES]${NC}                ${LIGHT_RED}[NO]${NC}                         |
+----------------------------------------------------------------------------+

> "

if [ "$std_in" != "YES" ]; then
	exit_normal
fi

clear
echo "chntpw/interactive-mount and helper script
Written April 17 2016; Ahmad, Furquan
Revised Nov 22 2018 by Furquan Ahmad
"

check_root
#check_chntpw

echo "Available lookup-paths are:"
count=1
for path in $LOOKUP_PATH_1 $LOOKUP_PATH_2 $LOOKUP_PATH_3 $LOOKUP_PATH_X; do
	echo -e "$count.${WHITE}$path${NC}"
	check_system32 $path
	count=$((count+1))
done

#echo -e "Available lookup-paths are:
#1. ${WHITE}$LOOKUP_PATH_1${NC}"
#check_system32 $LOOKUP_PATH_1
#echo -e "2. ${WHITE}$LOOKUP_PATH_2${NC}"
#check_system32 $LOOKUP_PATH_2
#echo -e "3. ${WHITE}$LOOKUP_PATH_3${NC}"
#check_system32 $LOOKUP_PATH_3
#echo -e "4. ${WHITE}$LOOKUP_PATH_X${NC}"
#check_system32 $LOOKUP_PATH_X

if [ "$?" = 1 ]; then
	readln "System32 was not found in any of the lookup devices. Enter one manually? (Y/N) "
	if [ "$std_in" = "Y" ]; then
		readln "Enter the device path (/dev/xxx): "
		check_system32 "$std_in"
		if [ "$?" = 1 ]; then
			err_sys32_missing
		fi
	else
		err_sys32_missing
	fi
fi

readln "Do you wish to proceed? (Y/N) "

if [ "$std_in" = "Y" ]; then
	echo "
Changing to %WINDIR%/System32 in mount directory..."
	cd "$MOUNT_DEFAULT/Windows/System32"
else
	echo -e "Okay then.

Unmount $LOOKUP_DEFAULT.."
	umount "$LOOKUP_DEFAULT"
	echo "Finishing up..."
	rmdir "$MOUNT_DEFAULT"	
	echo -e "Exitting..."
	exit_normal
fi

if cd config > /dev/null; then
	pwd
	echo "
Error: We were unable to find the config directory."
	ls --color=auto -d */
	readln "Please enter the correct name for the config directory: "
	cd "$std_in"
fi
if [ ! -f "SAM" ]; then
	echo "
Error: We were unable to find the SAM file. The SAM file is a single file without any extension and is usually named sam, Sam, SAM, etc."
	ls --color=auto
	readln "Please enter the correct name for the SAM file: "
	echo "Running chntpw...
"
	chntpw -i $std_in
else
	echo -e "${LIGHT_GREEN}SAM file found${NC} at ${LIGHT_BLUE}$(pwd)/SAM${NC}."
	echo "Running chntpw...
"
	chntpw -i SAM
fi
cd ~
echo "Unmounting $LOOKUP_DEFAULT..."
umount "$LOOKUP_DEFAULT"
rmdir $MOUNT_DEFAULT

exit_normal
