#! /bin/bash
sudo iwlist eth1 scan | grep -e ESSID -e Quality | sed -e "s/\"//g" -e "s/ESSID:/\n\t/" 
