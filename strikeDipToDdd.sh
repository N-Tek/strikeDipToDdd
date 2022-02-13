#!/bin/bash

# strikeDipToDdd.sh - Script that converts dip/dip_direction measurements to strike/dip
# Copyright © 2022 Necib ÇAPAR <necipcapar@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

if [ $# -eq 0 ]; then
    printf "Usage: %s [-r] [-d DELIM] [-h] ((-a | -b | -A | -B)  (MEASUREMENT | MEASUREMENT_FILE))...\n" "$0"
    printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n" \
	"       -a    input in    RHR-azimuth format,  dip direction 90⁰ clockwise from strike" \
	"       -b    input in    RHR-bearing format,  dip direction 90⁰ clockwise from strike" \
	"       -A    input in UK-RHR-azimuth format,  dip direction 90⁰ counter-clockwise from strike" \
	"       -B    input in UK-RHR-bearing format,  dip direction 90⁰ counter-clockwise from strike" \
	"       -d DELIM   use DELIM instead of space as the delimiter of output values" \
	"       -r    print out number of converted and invalid measurements" \
	"       -h    Display help"
    exit 1
fi

converted_measurement=0
converted_infile_measurement=0
invalid_measurement=0
invalid_infile_measurement=0

# ----------------------------- FUNCTION DEFINITIONS ----------------------------- 

check_RHR_azimuth_measurement(){
    declare -i strike=$(( 10#$(echo $1 | cut -d '/' -f 1 -) ))    
    declare var=$(echo $1 | cut -d '/' -f 2)
    declare -i dip=$(( 10#${var%%[NSEW]*} ))
    declare direction_of_dip=${var##*[0-9]}

    if [[ "$1" =~ ^[[:digit:]]{3}/[[:digit:]]{1,2}[NSEW]{1}[EW]{0,1}$ ]]; then    # check strike/dip format - 3 digit / max 2 digit 1 direction [0 or 1 direction]
	if [ $strike -gt 360  -o  $dip -gt 90 ]; then                             # check max values of strike and dip
	    return 1
	elif [ $strike -eq 0  -a  $direction_of_dip != "E" ]; then        #check possible values of direction of dip
	    return 1
	elif [ $strike -gt 0  -a  $strike -lt 90  -a  $direction_of_dip != "SE" ]; then
	    return 1
	elif [ $strike -eq 90  -a  $direction_of_dip != "S" ]; then
	    return 1
	elif [ $strike -gt 90  -a  $strike -lt 180  -a  $direction_of_dip != "SW" ]; then
	    return 1
	elif [ $strike -eq 180  -a  $direction_of_dip != "W" ]; then
	    return 1
	elif [ $strike -gt 180  -a  $strike -lt 270  -a  $direction_of_dip != "NW" ]; then
	    return 1
	elif [ $strike -eq 270  -a  $direction_of_dip != "N" ]; then
	    return 1
	elif [ $strike -gt 270  -a  $strike -lt 360  -a  $direction_of_dip != "NE" ]; then
	    return 1
	elif [ $strike -eq 360  -a  $direction_of_dip != "E" ]; then
	    return 1
	else
	    return 0
	fi
    else
	return 1
    fi
}

check_UK_RHR_azimuth_measurement(){
    declare -i strike=$(( 10#$(echo $1 | cut -d '/' -f 1 -) ))    
    declare var=$(echo $1 | cut -d '/' -f 2)
    declare -i dip=$(( 10#${var%%[NSEW]*} ))
    declare direction_of_dip=${var##*[0-9]}

    if [[ "$1" =~ ^[[:digit:]]{3}/[[:digit:]]{1,2}[NSEW]{1}[EW]{0,1}$ ]]; then    # check strike/dip format - 3 digit / max 2 digit 1 direction [0 or 1 direction]
	if [ $strike -gt 360  -o  $dip -gt 90 ]; then                             # check max values of strike and dip
	    return 1
	elif [ $strike -eq 0  -a  $direction_of_dip != "W" ]; then        #check possible values of direction of dip
	    return 1
	elif [ $strike -gt 0  -a  $strike -lt 90  -a  $direction_of_dip != "NW" ]; then
	    return 1
	elif [ $strike -eq 90  -a  $direction_of_dip != "N" ]; then
	    return 1
	elif [ $strike -gt 90  -a  $strike -lt 180  -a  $direction_of_dip != "NE" ]; then
	    return 1
	elif [ $strike -eq 180  -a  $direction_of_dip != "E" ]; then
	    return 1
	elif [ $strike -gt 180  -a  $strike -lt 270  -a  $direction_of_dip != "SE" ]; then
	    return 1
	elif [ $strike -eq 270  -a  $direction_of_dip != "S" ]; then
	    return 1
	elif [ $strike -gt 270  -a  $strike -lt 360  -a  $direction_of_dip != "SW" ]; then
	    return 1
	elif [ $strike -eq 360  -a  $direction_of_dip != "W" ]; then
	    return 1
	else
	    return 0
	fi
    else
	return 1
    fi
}

check_RHR_bearing_measurement(){
    declare strike=$(echo $1 | cut -d '/' -f 1 -)
    declare strike_dir1=${strike%%[0-9]*}
    declare strike_dir2=${strike##*[0-9]}
    declare var=${strike%[EW]}
    declare -i strike_angle=$(( 10#${var#[NS]} ))

    var=$(echo $1 | cut -d '/' -f 2)
    declare -i dip=$(( 10#${var%%[NSEW]*} ))
    declare direction_of_dip=${var##*[0-9]}

    if [[ "$1" =~ ^[NS][[:digit:]]{1,2}[EW]/[[:digit:]]{1,2}[NSEW]{1}[EW]{0,1}$ ]]; then    # check strike/dip format 
	if [ $strike_angle -gt 90  -o  $dip -gt 90 ]; then                                  # check max values of strike_angle and dip
	    return 1
	elif [ $strike_dir1 == "N"  -a  $strike_angle -eq 0  -a  \( $strike_dir2 == "E"  -o  $strike_dir2 == "W" \)  -a  $direction_of_dip != "E" ]; then  # N0[EW]/10E
	    return 1
	elif [ $strike_dir1 == "N"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "E"  -a  $direction_of_dip != "SE" ]; then      # N45E/10SE
	    return 1
	elif [ \( $strike_dir1 == "N"  -o  $strike_dir1 == "S" \)  -a  $strike_angle -eq 90  -a  $strike_dir2 == "E"  -a  $direction_of_dip != "S" ]; then # [NS]90E/10S
	    return 1
	elif [ $strike_dir1 == "S"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "E"  -a  $direction_of_dip != "SW" ]; then      # S45E/10SW
	    return 1
	elif [ $strike_dir1 == "S"  -a  $strike_angle -eq 0  -a  \( $strike_dir2 == "E"  -o  $strike_dir2 == "W" \)  -a  $direction_of_dip != "W" ]; then  # S0[EW]/10W
	    return 1
	elif [ $strike_dir1 == "S"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "W"  -a  $direction_of_dip != "NW" ]; then      # S45W/10NW
	    return 1
	elif [ \( $strike_dir1 == "N"  -o  $strike_dir1 == "S" \)  -a  $strike_angle -eq 90  -a  $strike_dir2 == "W"  -a  $direction_of_dip != "N" ]; then # [NS]90W/10N
	    return 1
	elif [ $strike_dir1 == "N"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "W"  -a  $direction_of_dip != "NE" ]; then      # N45W/10NE
	    return 1
	else
	    return 0
	fi
    else
	return 1
    fi
}

check_UK_RHR_bearing_measurement(){
    declare strike=$(echo $1 | cut -d '/' -f 1 -)
    declare strike_dir1=${strike%%[0-9]*}
    declare strike_dir2=${strike##*[0-9]}
    declare var=${strike%[EW]}
    declare -i strike_angle=$(( 10#${var#[NS]} ))

    var=$(echo $1 | cut -d '/' -f 2)
    declare -i dip=$(( 10#${var%%[NSEW]*} ))
    declare direction_of_dip=${var##*[0-9]}

    if [[ "$1" =~ ^[NS][[:digit:]]{1,2}[EW]/[[:digit:]]{1,2}[NSEW]{1}[EW]{0,1}$ ]]; then    # check strike/dip format 
	if [ $strike_angle -gt 90  -o  $dip -gt 90 ]; then                                  # check max values of strike_angle and dip
	    return 1
	elif [ $strike_dir1 == "N"  -a  $strike_angle -eq 0  -a  \( $strike_dir2 == "E"  -o  $strike_dir2 == "W" \)  -a  $direction_of_dip != "W" ]; then  # N0[EW]/10W
	    return 1
	elif [ $strike_dir1 == "N"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "E"  -a  $direction_of_dip != "NW" ]; then      # N45E/10NW
	    return 1
	elif [ \( $strike_dir1 == "N"  -o  $strike_dir1 == "S" \)  -a  $strike_angle -eq 90  -a  $strike_dir2 == "E"  -a  $direction_of_dip != "N" ]; then # [NS]90E/10N
	    return 1
	elif [ $strike_dir1 == "S"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "E"  -a  $direction_of_dip != "NE" ]; then      # S45E/10NE
	    return 1
	elif [ $strike_dir1 == "S"  -a  $strike_angle -eq 0  -a  \( $strike_dir2 == "E"  -o  $strike_dir2 == "W" \)  -a  $direction_of_dip != "E" ]; then  # S0[EW]/10E
	    return 1
	elif [ $strike_dir1 == "S"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "W"  -a  $direction_of_dip != "SE" ]; then      # S45W/10SE
	    return 1
	elif [ \( $strike_dir1 == "N"  -o  $strike_dir1 == "S" \)  -a  $strike_angle -eq 90  -a  $strike_dir2 == "W"  -a  $direction_of_dip != "S" ]; then # [NS]90W/10S
	    return 1
	elif [ $strike_dir1 == "N"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "W"  -a  $direction_of_dip != "SW" ]; then      # N45W/10SW
	    return 1
	else
	    return 0
	fi
    else
	return 1
    fi
}

convert_RHR_azimuth_to_ddd(){
    declare -i strike=$(( 10#$(echo $1 | cut -d '/' -f 1 -) ))    
    declare var=$(echo $1 | cut -d '/' -f 2)
    declare -i dip=$(( 10#${var%%[NSEW]*} ))

    declare -i dip_direction=$(( ($strike + 90) % 360 ))

    if [ ! -z "$dflag" ]; then
	printf "%d/%03d%s" "$dip" "$dip_direction" "$dval"
    else
	printf "%d/%03d" "$dip" "$dip_direction"
    fi
}

convert_UK_RHR_azimuth_to_ddd(){
    declare -i strike=$(( 10#$(echo $1 | cut -d '/' -f 1 -) ))    
    declare var=$(echo $1 | cut -d '/' -f 2)
    declare -i dip=$(( 10#${var%%[NSEW]*} ))

    declare -i dip_direction=$(( ($strike - 90) < 0 ? ($strike - 90 + 360) : ($strike - 90) ))

    if [ ! -z "$dflag" ]; then
	printf "%d/%03d%s" "$dip" "$dip_direction" "$dval"
    else
	printf "%d/%03d" "$dip" "$dip_direction"
    fi
}

convert_RHR_bearing_to_ddd(){
    declare strike=$(echo $1 | cut -d '/' -f 1 -)
    declare strike_dir1=${strike%%[0-9]*}
    declare strike_dir2=${strike##*[0-9]}
    declare var=${strike%[EW]}
    declare -i strike_angle=$(( 10#${var#[NS]} ))

    var=$(echo $1 | cut -d '/' -f 2)
    declare -i dip=$(( 10#${var%%[NSEW]*} ))
    declare -i dip_direction=
    
    if [ $strike_dir1 == "N"  -a  $strike_angle -eq 0  -a  \( $strike_dir2 == "E"  -o  $strike_dir2 == "W" \) ]; then    # N0[EW]/10E  on +y
	dip_direction=$(( $strike_angle + 90 ))
    elif [ $strike_dir1 == "N"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "E" ]; then       # N45E/10SE   btw. +y & +x
	dip_direction=$(( $strike_angle + 90 ))
    elif [ \( $strike_dir1 == "N"  -o  $strike_dir1 == "S" \)  -a  $strike_angle -eq 90  -a  $strike_dir2 == "E" ]; then # N90E/10S    on +x
	dip_direction=$(( $strike_angle + 90 ))
    elif [ $strike_dir1 == "S"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "E" ]; then       # S45E/10SW   btw. +x & -y
	dip_direction=$(( 270 - $strike_angle ))
    elif [ $strike_dir1 == "S"  -a  $strike_angle -eq 0  -a  \( $strike_dir2 == "E"  -o  $strike_dir2 == "W" \) ]; then  # S0[EW]/10W  on -y
	dip_direction=$(( 270 - $strike_angle ))
    elif [ $strike_dir1 == "S"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "W" ]; then       # S45W/10NW   btw -y & -x
	dip_direction=$(( 270 + $strike_angle ))
    elif [ \( $strike_dir1 == "N"  -o  $strike_dir1 == "S" \)  -a  $strike_angle -eq 90  -a  $strike_dir2 == "W" ]; then # [NS]90W/10N on -x
	dip_direction=0
    elif [ $strike_dir1 == "N"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "W" ]; then       # N45W/10NE   btw -x & +y
	dip_direction=$(( 90 - $strike_angle ))
    fi

    if [ ! -z $dflag ]; then
	printf "%d/%03d%s" "$dip" "$dip_direction" "$dval"
    else
	printf "%d/%03d" "$dip" "$dip_direction"
    fi
}

convert_UK_RHR_bearing_to_ddd(){
    declare strike=$(echo $1 | cut -d '/' -f 1 -)
    declare strike_dir1=${strike%%[0-9]*}
    declare strike_dir2=${strike##*[0-9]}
    declare var=${strike%[EW]}
    declare -i strike_angle=$(( 10#${var#[NS]} ))

    var=$(echo $1 | cut -d '/' -f 2)
    declare -i dip=$(( 10#${var%%[NSEW]*} ))
    declare -i dip_direction=
    
    if [ $strike_dir1 == "N"  -a  $strike_angle -eq 0  -a  \( $strike_dir2 == "E"  -o  $strike_dir2 == "W" \) ]; then    # N0[EW]/10W  on +y
	dip_direction=$(( 270 + $strike_angle ))
    elif [ $strike_dir1 == "N"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "E" ]; then       # N45E/10NW   btw. +y & +x
	dip_direction=$(( 270 + $strike_angle ))
    elif [ \( $strike_dir1 == "N"  -o  $strike_dir1 == "S" \)  -a  $strike_angle -eq 90  -a  $strike_dir2 == "E" ]; then # N90E/10N    on +x
	dip_direction=0
    elif [ $strike_dir1 == "S"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "E" ]; then       # S45E/10NE   btw. +x & -y
	dip_direction=$(( 90 - $strike_angle ))
    elif [ $strike_dir1 == "S"  -a  $strike_angle -eq 0  -a  \( $strike_dir2 == "E"  -o  $strike_dir2 == "W" \) ]; then  # S0[EW]/10E  on -y
	dip_direction=$(( 90 - $strike_angle ))
    elif [ $strike_dir1 == "S"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "W" ]; then       # S45W/10SE   btw -y & -x
	dip_direction=$(( 90 + $strike_angle ))
    elif [ \( $strike_dir1 == "N"  -o  $strike_dir1 == "S" \)  -a  $strike_angle -eq 90  -a  $strike_dir2 == "W" ]; then # [NS]90W/10S on -x
	dip_direction=$(( 90 + $strike_angle ))
    elif [ $strike_dir1 == "N"  -a  $strike_angle -gt 0  -a  $strike_angle -lt 90  -a  $strike_dir2 == "W" ]; then       # N45W/10SW   btw -x & +y
	dip_direction=$(( 270 - $strike_angle ))
    fi

    if [ ! -z $dflag ]; then
	printf "%d/%03d%s" "$dip" "$dip_direction" "$dval"
    else
	printf "%d/%03d" "$dip" "$dip_direction"
    fi
}

read_RHR_azimuth_input(){
    if [ -f "$1" ]; then
	while read line
	do
	    check_RHR_azimuth_measurement "$line"
	    if [ $? -eq 0 ]; then
		convert_RHR_azimuth_to_ddd "$line"
		(( converted_infile_measurement++ ))
	    else
		(( invalid_infile_measurement++ ))
	    fi
	    printf "\n"
	done < "$1"
    else
	check_RHR_azimuth_measurement "$1"
	if [ $? -eq 0 ]; then
	    convert_RHR_azimuth_to_ddd "$1"
	    (( converted_measurement++ ))
	else
	    (( invalid_measurement++ ))
	fi
	printf "\n"
    fi
}

read_RHR_bearing_input(){
    if [ -f "$1" ]; then
	while read line
	do
	    check_RHR_bearing_measurement "$line"
	    if [ $? -eq 0 ]; then
		convert_RHR_bearing_to_ddd "$line"
		(( converted_infile_measurement++ ))
	    else
		(( invalid_infile_measurement++ ))
	    fi
	    printf "\n"
	done < "$1"
    else
	check_RHR_bearing_measurement "$1"
	if [ $? -eq 0 ]; then
	    convert_RHR_bearing_to_ddd "$1"
	    (( converted_measurement++ ))
	else
	    (( invalid_measurement++ ))
	fi
	printf "\n"
    fi
}

read_UK_RHR_azimuth_input(){
    if [ -f "$1" ]; then
	while read line
	do
	    check_UK_RHR_azimuth_measurement "$line"
	    if [ $? -eq 0 ]; then
		convert_UK_RHR_azimuth_to_ddd "$line"
		(( converted_infile_measurement++ ))
	    else
		(( invalid_infile_measurement++ ))
	    fi
	    printf "\n"
	done < "$1"
    else
	check_UK_RHR_azimuth_measurement "$1"
	if [ $? -eq 0 ]; then
	    convert_UK_RHR_azimuth_to_ddd "$1"
	    (( converted_measurement++ ))
	else
	    (( invalid_measurement++ ))
	fi
	printf "\n"
    fi
}

read_UK_RHR_bearing_input(){
    if [ -f "$1" ]; then
	while read line
	do
	    check_UK_RHR_bearing_measurement "$line"
	    if [ $? -eq 0 ]; then
		convert_UK_RHR_bearing_to_ddd "$line"
		(( converted_infile_measurement++ ))
	    else
		(( invalid_infile_measurement++ ))
	    fi
	    printf "\n"
	done < "$1"
    else
	check_UK_RHR_bearing_measurement "$1"
	if [ $? -eq 0 ]; then
	    convert_UK_RHR_bearing_to_ddd "$1"
	    (( converted_measurement++ ))
	else
	    (( invalid_measurement++ ))
	fi
	printf "\n"
    fi
}

print_conversion_report(){
    printf "%s%d\n%s%d\n%s%d\n%s%d\n" \
	"Converted Infile : " "$converted_infile_measurement" \
	"Invalid   Infile : " "$invalid_infile_measurement" \
	"Converted        : " "$converted_measurement" \
	"Invalid          : " "$invalid_measurement"
}

is_next_a_measurement_option(){
    if [ "$1" == "-a"  -o  "$1" == "-A"  -o  "$1" == "-b"  -o "$1" == "-B" ]; then
	return 0
    else
	return 1
    fi
}

# -------------------------------------------------------------------------------- 
declare dval=

while getopts ":a:A:b:B:d:rh" name
do
    case "$name" in
	d) dflag=1
	    dval="$OPTARG" ;;
	a) is_next_a_measurement_option "$OPTARG"
	    if [ $? -ne 0 ]; then
		read_RHR_azimuth_input "$OPTARG"
	    else
		echo "[ERROR] : Invalid argument for option -$OPTARG" 1>&2
		exit 3
	    fi ;;
	b) is_next_a_measurement_option "$OPTARG"
	    if [ $? -ne 0 ]; then
		read_RHR_bearing_input "$OPTARG"
	    else
		echo "[ERROR] : Invalid argument for option -$OPTARG" 1>&2
		exit 3
	    fi ;;
	A) is_next_a_measurement_option "$OPTARG"
	    if [ $? -ne 0 ]; then
		read_UK_RHR_azimuth_input "$OPTARG"
	    else
		echo "[ERROR] : Invalid argument for option -$OPTARG" 1>&2
		exit 3
	    fi ;;
	B) is_next_a_measurement_option "$OPTARG"
	    if [ $? -ne 0 ]; then
		read_UK_RHR_bearing_input "$OPTARG"
	    else
		echo "[ERROR] : Invalid argument for option -$OPTARG" 1>&2
		exit 3
	    fi ;;
	:) echo "[ERROR] : Missing argument for option -$OPTARG" 1>&2
		exit 3 ;;
	r) rflag=1 ;;
	\?) echo "[ERROR] : Unknown option -$OPTARG" 1>&2
	    printf "Usage: %s [-r] [-d DELIM] [-h] ((-a | -b | -A | -B)  (MEASUREMENT | MEASUREMENT_FILE))...\n" "$0"
	    printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n" \
		"                 -a    input in    RHR-azimuth format,  dip direction 90⁰ clockwise from strike" \
		"                 -b    input in    RHR-bearing format,  dip direction 90⁰ clockwise from strike" \
		"                 -A    input in UK-RHR-azimuth format,  dip direction 90⁰ counter-clockwise from strike" \
		"                 -B    input in UK-RHR-bearing format,  dip direction 90⁰ counter-clockwise from strike" \
		"                 -d DELIM   use DELIM instead of space as the delimiter of output values" \
		"                 -r    print out number of converted and invalid measurements" \
		"                 -h    Display help"
	    exit 2 ;;
	h|*) printf "Usage: %s [-r] [-d DELIM] [-h] ((-a | -b | -A | -B)  (MEASUREMENT | MEASUREMENT_FILE))...\n" "$0"
	    printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n" \
		"       -a    input in    RHR-azimuth format,  dip direction 90⁰ clockwise from strike" \
		"       -b    input in    RHR-bearing format,  dip direction 90⁰ clockwise from strike" \
		"       -A    input in UK-RHR-azimuth format,  dip direction 90⁰ counter-clockwise from strike" \
		"       -B    input in UK-RHR-bearing format,  dip direction 90⁰ counter-clockwise from strike" \
		"       -d DELIM   use DELIM instead of space as the delimiter of output values" \
		"       -r    print out number of converted and invalid measurements" \
		"       -h    Display help"
	    exit 0 ;;
    esac
done
shift $((OPTIND - 1))

if [ ! -z "$rflag" ]; then
    print_conversion_report
fi
