#!/bin/bash
TITLE=$"ArchLinux Installation Framework Fork"
ANSWER="/tmp/.setup"
# test if we could display the installation on X
DISCLAIMER="Note that despite our careful coding and proper testing there may still be bugs in this software.\nWhen you are doing this installation on a system where some data must be preserved, we suggest you make a backup first"

# DIALOG()
# an el-cheapo dialog wrapper
#
# parameters: see dialog(1)
# returns: whatever dialog did
DIALOG() {
	if [ -z $DISPLAY ]
		then
	    	dialog --backtitle "${TITLE}" --aspect 15 "$@"
    		return $?
		else
			Xdialog --backtitle "${TITLE}" --aspect 15 "$@"
    		return $?
	fi
}
# DIALOG() {
#     dialog --backtitle "${TITLE}" --aspect 15 "$@"
#     return $?
# }
# DIALOG() {
#     $DIALOG_CHECKED --backtitle "${TITLE}" --msgbox "lol" 0 0
# }
DIALOG --title "[ Welcome ]" --clear --msgbox \
"Please read this note before continuing :\n\n\
Welcome to an Arch Linux Installation program.\nThe install process is fairly straightforward,\
and you should run through the options in the order they are presented.\
If you are unfamiliar with partitioning/making filesystems, you may want to consult some documentation before continuing.\
You can view all output from commands by viewing your tty console (ALT-F6).\
ALT-F1 will bring you back here.\n\n$DISCLAIMER" 20 75 \

run() {
	rm /tmp/rkm.log
	 ( \
    touch /tmp/rkm-running
    echo "Progress ..." > /tmp/rkm.log; echo >> /tmp/rkm.log
    yaourt -Sy >>/tmp/rkm.log 2>&1
    echo >> /tmp/rkm.log
    echo "Done ranking" >> /tmp/rkm.log
    echo >> /tmp/rkm.log
    echo "Please press Enter to continue" >> /tmp/rkm.log
    rm -f /tmp/rkm-running
    ) &
    sleep 2
    DIALOG --title $" Processing... Please Wait " --no-kill --tailbox "/tmp/rkm.log" 18 70 2>${ANSWER} 
    # while [[ -f /tmp/rkm-running ]]; do
    #     /bin/true
    # done
}
run