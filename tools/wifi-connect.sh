#!/usr/bin/env bash

__ScriptVersion="0.0.1"

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
    -s|ssid	  SSID of the network to connect to 
    -q|quiet   	  Quiet mode, less verbose"

}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
function connect() {
	vprint "Trying to connect"
	if test -n $1; then	
		check_ssid $1
	else
		check_wifi		
	fi
	connect_wpa
}

function connect_wpa() {
	if test -n $CONF_FILE; then
		sudo wpa_supplicant -B -i $INTERFACE -D wext -c $CONF_FILE
		dhclient $INTERFACE
	fi
	
}

function check_ssid() {
	ssid=$1
	for my_ssid in /etc/wpa_supplicant/*.conf; do 
		if [[ "$ssid.conf" = "$(basename $my_ssid)" ]]; then
			echo "Detected a saved configuration file for network $ssid"
			CONF_FILE=$my_ssid
		fi
	done
}

function check_wifi() {
	for ssid in $( sudo iwlist scan | grep ESSID | sed -e "s/ESSID://" -e "s/\"//g" | cat); do 
		check_ssid $ssid
	done
}


while getopts ":hvqs:" opt
do
  case $opt in

	h|help     )  usage; exit 0   ;;

	v|version  )  echo "$0 -- Version $__ScriptVersion"; exit 0   ;;

	q|quiet  )  VERBOSE=""   ;;

	s|ssid  )  
		echo $OPTARG
		#connect $OPTARG	
	;;

	\? )  echo -e "\n  Option does not exist : $OPTARG\n"; usage; exit 1   ;;
	: )  echo -e "Option -$OPTARG requires an argument";  exit 1 ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))
