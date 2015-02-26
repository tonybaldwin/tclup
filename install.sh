#!/bin/bash

# installation script for TclUP
# moves tclup.tcl to ~/bin/tclup
# creates a dir for config files
# this is free software according to the Gnu Public License, v. 2 or later

echo "Installing TclUP"

name=$(whoami)

if [ ! -d $HOME/bin/ ]; then
 	mkdir $HOME/bin/
 	$PATH=$PATH:/$HOME/bin/
 	export PATH
fi

# make config dir
mkdir /home/$name/.tclup

cp tclup.tcl $HOME/bin/tclup
chmod +x $HOME/bin/tclup

echo "Installation of TclUP is complete"
echo "To run TclUP, in terminal type tclup, or make an icon/menu item/short cut to $HOME/bin/tclup"

exit

#####
# tony baldwin / http://tonybaldwin.me
#####
