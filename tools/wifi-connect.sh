#!/usr/bin/env bash

__ScriptVersion="0.0.2"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
VERBOSE="true"
CONF_FILE=""
INTERFACE="eth1"



function vprint (){
	if test -n $VERBOSE; then
		echo $@
	fi
}

function usage ()
{
	echo "Usage :  $0 [options] [--]

    Options:
    -h|help       Display this message
    -v|version    Display script version
    -s        	  SSID of the network to connect to 
    -l|list       List saved configuration files
    -q|quiet   	  Quiet mode, less verbose"

}    # ----------  end of function usage  ----------

list_configuration_files() {
  for file in /etc/wpa_supplicant/*.conf; do
    echo $file
  done
}

function connect() {
	vprint "Trying to connect"
	if test -n "$1"; then	
		check_ssid $1
	else
		check_wifi		
	fi
	connect_wpa
}

function connect_wpa() {
	if test -n "$CONF_FILE"; then
		sudo wpa_supplicant -B -i $INTERFACE -D wext -c $CONF_FILE
		sudo dhclient $INTERFACE
	else
		echo "Configuration file not found"
		exit 1
	fi
}

function check_ssid() {
	vprint "Checking the config file for network $1 is already in the system"
	ssid=$1
	for my_ssid in /etc/wpa_supplicant/*.conf; do 
		if [[ "$ssid.conf" = "$(basename $my_ssid)" ]]; then
			vprint "Detected a saved configuration file for network $ssid"
			CONF_FILE=$my_ssid
		fi
	done
}

function check_wifi() {
	vprint "Checking if a config file for current networks exists"
	for ssid in $( sudo iwlist scan | grep ESSID | sed -e "s/ESSID://" -e "s/\"//g" | cat); do 
		check_ssid $ssid
	done
}


#######################################################################
#                    HANDLE COMMAND LINE ARGUMENTS                    #
#######################################################################

while getopts ":hvqs:l" opt
do
  case $opt in

	h|help     )  usage; exit 0   ;;

	v|version  )  echo "$0 -- Version $__ScriptVersion"; exit 0   ;;

	q|quiet  )  VERBOSE=""   ;;

	l|list  )  list_configuration_files  ;;

	s|ssid  )  
		echo $OPTARG
		connect $OPTARG	
	;;

	\? )  echo -e "\n  Option does not exist : $OPTARG\n"; usage; exit 1   ;;
	: )  echo -e "Option -$OPTARG requires an argument";  exit 1 ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))
