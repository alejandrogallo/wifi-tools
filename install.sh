#!/usr/bin/env bash

if test -d $HOME/bin 
then 
	echo "Local bin directory found"
	chmod 0755 ./tools/*
	cp ./tools/* $HOME/bin/
else
	echo "Local bin directory not found, this only works locally" 
fi

