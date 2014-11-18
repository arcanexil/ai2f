#!/bin/bash

#  ai2f.sh
#  
#  Copyright 2013 arcanexil <lucas.ranc@gmail.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  

# Changelog v1.1:
# 2013-05-30  arcanexil  <lucas.ranc@gmail.com>
#   
# * All scripts are complete
# * Some bugs need to be fixed
#

# Changelog v1.0:
# 2013-05-27  arcanexil  <lucas.ranc@gmail.com>
#  
# * Blendering old aif scripts and Antergos scripts (Special remerciement for Antergos scripts)
# * Establishing mainmenu() procedure scripts 
# * Creating installation procedures tree on hdd
#

# Table of content : (line number)
# 
# I) Etablishing the first necessary variables ............................. 38
#   1) Main menu arch ...................................................... 130
#       A) Procedures ...................................................... 150
#           a) Set Language ................................................ 159
#           b) Set Time And Date ........................................... 166
#           c) Prepare Hard Drive .......................................... 173
#           d) Install System .............................................. 176
#           e) Configure System ............................................ 180
# II) Executing safe instructions and goto the mainmenu() .................. 210
#       A) Safe instructions ...............................................
#       B) Welcome Menu ....................................................
#       C) Rankmirror script ...............................................
        

##################################################
## I/ Etablishing the first necessary variables ##
##################################################

INSTALLER_VERSION=1.1
DISCLAIMER="Note that despite our careful coding and proper testing there may still be bugs in this software.\nWhen you are doing this installation on a system where some data must be preserved, we suggest you to ake a backup first."

TEXTDOMAIN=cli_installer
# we rely on some output which is parsed in english!
#unset LANG
source features/functions
source features/fonctions

ANSWER="/tmp/.setup"
TITLE=$"ArchLinux Installation Framework Fork - v$INSTALLER_VERSION"

# test if we could display the installation on X
if [ -z $DISPLAY ]
   then
      DIALOG_CHECKED=dialog
   else
      DIALOG_CHECKED=Xdialog
fi

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
# DIALOG() taken from aif installer
# an el-cheapo dialog wrapper
#
# parameters: see dialog(1)
# returns: whatever dialog did
_checklist_dialog()
{
    $DIALOG_CHECKED --backtitle "$TITLE" --aspect 15 "$@" 3>&1 1>&2 2>&3 3>&-
}
run_rkm() {
    if [[ -f /tmp/rkm.log ]]; then
        rm /tmp/rkm.log
    fi
    ( \
    touch /tmp/rkm-running
    echo "Please wait during the examination of mirrors latency" >/tmp/rkm.log
    echo "Progress ..." >> /tmp/rkm.log; echo >> /tmp/rkm.log
    sh procedure/rankmirrors-script >>/tmp/rkm.log 2>&1
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

#######################
## 1) Main menu arch ##
#######################

mainmenu() {
    if [[ -n "${NEXTITEM}" ]]; then
        DEFAULT="--default-item ${NEXTITEM}"
    else
        DEFAULT=""
    fi
    $DIALOG_CHECKED ${DEFAULT} --backtitle "${TITLE}" --title $" MAIN MENU " \
    --menu $"Use the UP and DOWN arrows to navigate menus.\nUse TAB to switch between buttons and ENTER to select." 17 58 13 \
    "0" $"Set Language" \
    "1" $"Set Time And Date" \
    "2" $"Prepare Hard Drive" \
    "3" $"Install System" \
    "4" $"Configure System" \
    "5" $"Exit Install" 2>${ANSWER}
    NEXTITEM="$(cat ${ANSWER})"

##################
## A) Procdures ##
##################
    case $(cat ${ANSWER}) in
        "0") ## a) Set Language ##
            if [[ -e procedure/Set_Language/lg ]]; then
                sh procedure/Set_Language/lg --setup && NEXTITEM="1"
            else
                DIALOG --msgbox $"Error:\nlanguage script not found, aborting language setting" 0 0
            fi
            ;;
        "1") ## b) Set Time And Date ##
            if [[ -e procedure/Set_Time_And_Date/tz ]]; then
                sh procedure/Set_Time_And_Date/tz --setup && NEXTITEM="2"
            else
                DIALOG --msgbox $"Error:\ntime zone script not found, aborting clock setting" 0 0
            fi
            ;;
        "2") ## c) Prepare Hard Drive ##
            if [[ -e procedure/Prepare_Hard_Drive/prepare_harddrive ]]; then
                sh procedure/Prepare_Hard_Drive/prepare_harddrive --setup && NEXTITEM="3"
            else
                DIALOG --msgbox $"Error:\nscript not found, aborting Hard Drive Preparation" 0 0
            fi
            ;;
        "3") ## d) Install System ##
            if [[ -e procedure/Install_System/installation ]]; then
                sh procedure/Install_System/installation --setup && NEXTITEM="4"
            else
                DIALOG --msgbox $"Error:\nscript not found, aborting System Installation" 0 0
            fi
            ### !!!!!!!!!!!! INSTALL BOOTLOADER !!!!!!!!!!!!!
            ;;
        "4") ## e) Configure System ##
            if [[ -e procedure/Configure_System/configure_system ]]; then
                sh procedure/Configure_System/configure_system --setup && NEXTITEM="4"
            else
                DIALOG --msgbox $"Error:\nscript not found, aborting System Installation" 0 0
            fi
            DIALOG --yesno $"The installation is now complete. \nDo you want to restart to your new system?" 0 0 && RESTART_CHECK='S'
            if [[ "${RESTART_CHECK}" == 'S' ]];then
                reboot
            fi
            ;;
        "5")
            if [[ "${S_SRC}" = "1" && "${MODE}" = "media" ]]; then
                umount "${_MEDIA}" >/dev/null 2>&1
            fi
            [[ -e /tmp/.setup-running ]] && rm /tmp/.setup-running
            clear
            echo ""
            echo "If the install finished successfully, you can type 'reboot'"
            echo "to restart the system."
            echo ""
            exit 0 ;;
        *)
            DIALOG --yesno $"Abort Installation?" 6 40 && [[ -e /tmp/.setup-running ]] && rm /tmp/.setup-running && clear && exit 0
            
            ;;

    esac

}

#############################################################
## II/ Executing safe instructions and goto the mainmenu() ##
#############################################################

# detect systemd running
[[ "$(cat /proc/cmdline | grep -w init=/bin/systemd)" ]] && SYSTEMD="0"

# Looking if you are root on the system
[[ $EUID -ne 0 ]] && die_error "You must have root privileges to run AI2F"

# Script already running ? Or had been cut unproperly ?
if [[ -e /tmp/.setup-running ]]; then
    DIALOG --yesno $"Wait! \n\nIt's looks like the installer is already running somewhere else! \n\nDo you want to start from the beginning?" 0 0 && rm /tmp/.setup-running /tmp/.km-running /tmp/setup-pacman-running /tmp/setup-mkinitcpio-running /tmp/.tz-running /tmp/.setup
    if [[ -e /tmp/.setup-running ]]; then
        exit 1
    fi
fi

# Looking for network connection. Otherway could not start
$DIALOG_CHECKED --backtitle "${TITLE}" --aspect 15 --infobox $"Checking your connection..." 4 35
while [[ "$NETWORK_ALIVE" != "" ]];do
    DIALOG --msgbox $"The network seems not to be working \n\nYou have to configure your Internet connection before proceed. \n\nThen press 'OK'" 8 50
    NETWORK_ALIVE=`ping -c1 google.com 2>&1 | grep unknown`
done

if [[ "$NETWORK_ALIVE" = "" ]];then

    : >/tmp/.setup-running
    : >/tmp/.setup



    # ##! Need to be created !##
    # DIALOG --infobox $"Checking for Updates..." 6 50
    # INSTALLER_VERSION_NET=`curl http://192.168.1.101:8001/version 2>/dev/null`

    # if [[ ${INSTALLER_VERSION} < ${INSTALLER_VERSION_NET} ]];then
    #         if [[ ${INSTALLER_VERSION} < 0.9 ]];then
    #             DIALOG --msgbox $"Your version is too old. \n\nPlease, download the last version" 7 50
    #         else

    #             ${DLPROG} -O /install http://192.168.1.101:8001/* 2>/dev/null
            
    #             DIALOG --msgbox $"Successfully updated. \n\nPlease, restart Installer" 7 50

    #         fi

    #         rm /tmp/.setup-running
    #         exit 1
    # fi


    ###### Welcome Menu ######
DIALOG --title "[ Welcome ]" --clear --msgbox \
"Please read this note before continuing :\n\n\
Welcome to an Arch Linux Installation program.\nThe install process is fairly straightforward, \
and you should run through the options in the order they are presented. \
If you are unfamiliar with partitioning/making filesystems, you may want to consult some documentation before continuing. \
You can view all output from commands by viewing your tty6 console (ALT-F6). \
ALT-F1 will bring you back here.\n\n$DISCLAIMER" 20 75 \

    ###### Executing Rankmirror script or not ######

    if [[ -e /tmp/.rkm ]]; then
            DIALOG --infobox $"Processing..." 0 0
            DIALOG --yesno --default-no $"Your mirrorlist is already ranked.\nWould you like to regenerate it before continuing ?" 0 0
                case $? in
                    0) #YES
                        run_rkm ;;
                    1) #NO 
                        # Nothing to do                        
                        DIALOG --infobox $"You pressed no." 0 0
                        ;;
                esac
        else
            DIALOG --msgbox $"We highly recommand you to improuve the rapidity of downloading packages during the installation.\n\
So this program will Rankmirroring 5 mirrors before entering Main menu.\n\n\
This process could be rapid or not, depending on your connection" 0 0
            DIALOG --infobox $"Processing..." 0 0
            run_rkm
            # sh procedure/rankmirrors-script &
            # DIALOG --infobox $"Processing..." 0 0
            # sleep 1
            # DIALOG --infobox $"Please wait during the examination of mirrors latency" 0 0
            # sleep 5
            # DIALOG --infobox $"Done" 0 0
            # sleep 1
    fi
    
    while true; do
        mainmenu
    done

fi


clear
exit 0
