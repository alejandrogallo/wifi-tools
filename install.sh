#!/usr/bin/env bash

if test -d $HOME/bin 
then 
	echo "Local bin directory found"
	echo "Changing mode of scripts to 0755"
	chmod 0755 ./tools/*
	echo "Moving scripts from tools into $HOME/bin"
	cp ./tools/* $HOME/bin/
else
	echo "Local bin directory not found, this only works locally" 
fi

