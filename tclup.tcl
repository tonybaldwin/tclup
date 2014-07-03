#!/usr/bin/env wish8.5

##########################################################
# tclup copyright tony baldwin - tony@baldwinsoftware.com
# quick-n-dirty ftp upload/download tool

#########
# load necessary packages
package require ftp

bind . <Escape> {exit}

global filename
global rfile
global fname
global host
global path
global username
global password
global url
global dlay
global file_types
global list
global dldir
global novar
global browz

set browz "no browser"

set novar "cows"
set filename "local file"
set allvars [list host path username password browz novar]
set rfile "enter remote file here"


set file_types {
{"All Files" * }
{"Text Files" { .txt .TXT}}
{"LaTex" {.tex}}
{"PDF" {.pdf}}
{"Xml" {.xml}}
{"Html" {.html}}
{"CSS" {.css}}
{"Image" {.jpg .jpeg .gif .png}}
{"Zipped" {.gz .zip .rar}}
{"Music" {.ogg .mp3 .wav .wma}}
{"Video" {.mpg .mov .avi .wmv}}
}



wm title . "TickleUP"

########
# gui
########


frame .notes

grid [ttk::label .notes.lab -text "TclUP - FTP client"]

pack .notes -in . -fill x

frame .fields

grid [ttk::button .fields.op -text "Load Profile" -command {openprofile}]\
[ttk::button .fields.spro -text "Save Profile" -command {sapro}]\
[ttk::button .fields.out -text "QUIT" -command {exit}]\
[ttk::button .fields.help -text "Help" -command {help}]

pack .fields -in . -fill x

frame .fields2
grid [ttk::label .fields2.ll -text "PROFILE:"]
grid [ttk::label .fields2.hq -text "Host:"]\
[ttk::entry .fields2.host -textvariable host]\
[ttk::label .fields2.pathq -text "Directory: "]\
[ttk::entry .fields2.path -textvariable path]


grid [ttk::label .fields2.unam -text "Username: "]\
[ttk::entry .fields2.uname -textvariable username]\
[ttk::label .fields2.pwrd -text "Password: "]\
[ttk::entry .fields2.pswrd -show * -textvariable password]
grid [ttk::button .fields2.browz -text "Set Browser" -command {setbro}]\
[ttk::entry .fields2.bpx -textvariable browz]\


pack .fields2 -in . -fill x

frame .ubtns

grid [ttk::label .ubtns.lbl -text "UPLOADS:"]
grid [ttk::button .ubtns.filename -text "Select local file:" -command grabfile]\
[ttk::entry .ubtns.locfile -textvariable filename]\
[ttk::button .ubtns.send -text "Upload" -command {upload}]\


pack .ubtns -in . -fill x

frame .dbtns

grid [ttk::label .dbtns.lbl -text "DOWNLOADS:"]
grid [ttk::button .dbtns.dlfilen -text "Remote File List" -command {dlist}]\
[ttk::entry .dbtns.file -textvariable rfile]\
[ttk::button .dbtns.ddn -text "Download" -command {down}]\
[ttk::button .dbtns.del -text "Delete" -command {deletefile}]\

pack .dbtns -in . -fill x

frame .btns

grid [ttk::label .btns.l3 -text "-----"]
grid [ttk::label .btns.pl -text "Progress:"]\
[ttk::progressbar .btns.prog -mode indeterminate -length 200]\


pack .btns -in . -fill x

#########
# procs
#########



proc dlist {} {
	.btns.prog start
    set handle [::ftp::Open $::host $::username $::password -mode passive]
    set list [::ftp::NList $handle $::path]
    set flist [list $list]
	.btns.prog stop
frame .list
# wm title .list "Remote File List"

frame .list.t
text .list.t.l -width 80 -height 40 -wrap word -yscrollcommand ".list.t.ys set"
scrollbar .list.t.ys -command ".list.t.l yview" 
   
pack .list.t.l -in .list.t -side left -fill both
pack .list.t.ys -in .list.t  -side left -fill y

.list.t.l insert end "REMOTE FILE LIST\n\n"

.list.t.l insert end "Copy the file name you wish to download or delete and paste to the entry field.\nThen click \'download\' and choose the directory where to save it.\n\n"

foreach i $list {.list.t.l insert end $i\n}

frame .list.b
grid [ttk::button .list.b.b -text "close list" -command {destroy .list}]\
[ttk::button .list.b.r -text "refresh list" -command {reflist}]

pack .list.t -in .list
pack .list.b -in .list
pack .list -in .
	
}

proc reflist {} {
	destroy .list
	dlist
	}

proc down {} {
	.btns.prog start
    global dldir
    set dldir [tk_chooseDirectory]
    set handle [::ftp::Open $::host $::username $::password]
    ::ftp::Cd $handle $::path
    ::ftp::Get $handle $::rfile $::dldir/$::rfile
    ::ftp::Close $handle
    .btns.prog stop
    
    toplevel .down
    wm title .down "Success!"
    tk::message .down.loaded -text "Your file has been downloaded to $::dldir/$::rfile"
    tk::button .down.out -text "Okay" -command {destroy .down}
    pack .down.loaded -in .down -side top
    pack .down.out -in .down -side top
    
}

proc deletefile {} {
    set handle [::ftp::Open $::host $::username $::password]
    ::ftp::Cd $handle $::path
    ::ftp::Delete $handle $::rfile 
    ::ftp::Close $handle
    
    toplevel .mdel
    tk::message .mdel.done -text "File deleted from remote server"
    tk::button .mdel.ok -text "okay" -command {destroy .mdel}
    pack .mdel.done -in .mdel -side top
    pack .mdel.ok -in .mdel -side top
  
    
}
    
    
proc upload {} {
	.btns.prog start
    global fname
   set fname [file tail $::filename]
   
   set handle [::ftp::Open $::host $::username $::password]
   
   ::ftp::Cd $handle $::path
  
   ::ftp::Put $handle $::filename $::fname

   ::ftp::Close $handle
   .btns.prog stop


toplevel .url

frame .url.t
text .url.t.lbl -height 2 -width 80
.url.t.lbl insert end "Your file is at http://www.$::host/$::path/$::fname"

frame .url.b
grid [ttk::button .url.b.btn -text "open in browser" -command {browse}]\
[ttk::button .url.b.out -text "close" -command {destroy .url}]

pack .url.t.lbl -in .url.t
pack .url.t -in .url
pack .url.b -in .url
}

proc grabfile {} {
	global filename
	set filename [tk_getOpenFile -filetypes $::file_types -initialdir ~]
	wm title . "Now Tickling: $::filename"	
}

proc setbro {} {
set filetypes " "
set ::browz [tk_getOpenFile -filetypes $filetypes -initialdir "/usr/bin"]
}

proc browse {} {
    if {$::browz eq "no browser"} {
	set filetypes " "
	tk_messageBox -message "You have not chosen a browser for this session.\
Let's set the browser now." -type ok -title "Set browser"
	set ::browz [tk_getOpenFile -filetypes $filetypes initialdir "/usr/bin"]
	exec $::browz www.$::host/$::path/$::fname &} else {
	    exec $::browz www.$::host/$::path/$::fname &
	    }
}


proc sapro {} {
    
    set xanswer [tk_messageBox -message "This will save your server settings, including your password, unless you clear the field first.\n  Choose yes to change the password to 0000 and save, or no to save as is."\
 -title "Save Profile" -type yesno -icon question]
 	if {$xanswer eq "yes"} {
	set novar "cows"
	set password "0000"
	set header "#!/usr/bin/env wish8.5 "
   		set file_types {
     		{".profile" {.tprof}}
    		}
   set filename [tk_getSaveFile -filetypes $file_types]
   set fileid [open $filename w]
   puts $fileid $header
   foreach var $::allvars {puts $fileid [list set $var [set ::$var]]}
   close $fileid
   
  } else {
 	if {$xanswer eq "no"} {
	set novar "cows"
	set header "#!/usr/bin/env wish8.5 "
   		set file_types {
     		{"profile" {.prof}}
    		}
   set filename [tk_getSaveFile -filetypes $file_types]
   set fileid [open $filename w]
   puts $fileid $header
   foreach var $::allvars {puts $fileid [list set $var [set ::$var]]}
   close $fileid
   	}
	}   
} 


proc openprofile {} {

     set file_types {
     {"profile" {.prof}}
    }
set project [tk_getOpenFile -filetypes $file_types -initialdir ~/.tclup]
uplevel #0 [list source $project]
}

proc help {} {
toplevel .help
wm title .help "About TclUP"
text .help.inf -width 120 -height 35
.help.inf insert end "TclUP: A ticklish, quick-n-dirty FTP client\nwritten by Tony Baldwin <tony@baldwinsoftware.com>\n\nThis software is released under the Gnu Public License v. 2 or later\n\nProfile: (this is the information for your remote host)\nLoad profile:  load a saved profile (ie. server info & browser choice)\nSave profile:  save a profile (you can have as many as you like, handy if you use multilpe servers)\nhost:  enter the url for your ftp server (ie: the ip address, or, domain, such as myserver.com)\ndirectory: the path to the directory to/from which you wish to upload/download files\nusername:  your username for your ftp account\npassword:  the password for your ftp account\n\nButtons:\n\n-Uploads:\nLocal file:  opens a file selection dialog to choose a file on your local file system.\nupload: \ninitiates upload to the server\nBrowser:  choose a browser to preview files once they've been uploaded\n\n-Downloads:\nList: will show a list of files on the remote host\nRefresh the list (ie. to verify a deletion or upload) with the refresh list button.\n(empty field):  enter the name of the file on the remote host (you can copy/paste from the list using ctrl-c and ctrl-v)\nDownload: initiates download\nDelete: will delete the file from the remote host\n(Progress bar):  uselessly slides back and forth during upload/download...looks cool, no?\nQuit:  closes TclUP\n\nFeel free to e-mail me if you have any questions.\n\nThanks for using TclUP,\nTony Baldwin"
tk::button .help.out -text "Okay" -command {destroy .help}
pack .help.out -in .help -side top
pack .help.inf -in .help -side top
}
#########################################################################
# This program was written by tony baldwin - tony@baldwinsoftware.com
# This program is free software; you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by 
# the Free Software Foundation; either version 2 of the License, or 
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
########################################################################
