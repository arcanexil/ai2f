#!/bin/bash
# test if we could display the installation on X
if [ -z $DISPLAY ]
   then
      DIALOG_CHECKED=dialog
   else
      DIALOG_CHECKED=Xdialog
fi


ANSWER="/tmp/.setup"
TITLE=$"ArchLinux Installation Framework Fork"

lang(){
    LOCALES = 
    for i in $(localectl list-keymaps | grep '^..$'); do
        LOCALES="${LOCALES} ${i} -"
    done
	$DIALOG_CHECKED ${DEFAULT} --backtitle "${TITLE}" --title $" MAIN MENU " \
		    --menu $"Use the UP and DOWN arrows to navigate menus.\nUse TAB to switch between buttons and ENTER to select." 17 58 13 \
            ${LOCALES} 2>${ANSWER}
            locale=$(cat ${ANSWER})
            loadkeys $locale;
}

install(){
    while [[ "${_result}" != 'Done, package Installation Complete' ]];do
        ( \
            echo "Please wait during the examination of mirrors latency" >/tmp/unzip.log ; \
            echo >>/tmp/unzip.log ; \
            touch /tmp/unzip-running ; \

                echo "Progress ..." >> /tmp/unzip.log; echo >> /tmp/unzip.log ; \
                if [[ ! -f /usr/bin/unzip ]]; then 
                    pacman -Sy unzip --noconfirm --noprogressbar >> /tmp/unzip.log ; 
                fi 
                if [[ ! -f ai2f.zip ]]; then 
                    wget http://192.168.1.24:8000/ai2f.zip 2>> /tmp/unzip.log ; 
                fi 
                if [[ ! -f ai2f/ai2f.sh ]]; then 
                    unzip ai2f.zip >> /tmp/unzip.log ; 
                else 
                    echo "Nothing to do. Package is already here." >>/tmp/unzip.log ; 
                fi 
            

            echo $? > /tmp/.unzip-retcode ; \
            if [[ $(cat /tmp/.unzip-retcode) -ne 0 ]]; then
                echo -e "\nThe script FAILED. So please retry." >>/tmp/unzip.log
            else
                echo -e "" >>/tmp/unzip.log
                echo -e "\nDone, package Installation Complete" >>/tmp/unzip.log
                echo -e "" >>/tmp/unzip.log
                echo -e "\nPlease press Enter to continue" >>/tmp/unzip.log
                echo -e "" >>/tmp/unzip.log
            fi
            rm /tmp/unzip-running
        ) &

        # display output while it's running
        sleep 2
        $DIALOG_CHECKED --backtitle "${TITLE}" --title $" Processing.. Please Wait " \
            --no-kill --tailboxbg "/tmp/unzip.log" 18 70 2>${ANSWER}
        while [[ -f /tmp/unzip-running ]]; do
            /bin/true
        done
        kill $(cat ${ANSWER})

        # dl finished, display scrollable output
        local _result=''
        local _check=''
        if [[ $(cat /tmp/.unzip-retcode) -ne 0 ]]; then
            _result=$"Failed to download dependencies."
        else
            _result=$"Done, package Installation Complete"
            _check='success'
        fi
        rm /tmp/.unzip-retcode

        if [[ "${_check}" = 'success' ]];then
            $DIALOG_CHECKED --msgbox "${_result}" 0 0 || return 1
        else
            $DIALOG_CHECKED --msgbox "${_result}" 0 0 || return 1
        fi
    done

}

exitt(){
    if [[ -n $(cat /tmp/unzip.log | grep 'Done') ]]; then
        exit_text = "thx for use this installator, plz go ai2f directory then lauch it";
    else
        exit_text = "Abord the Installation ?";
    fi
	$DIALOG_CHECKED --yesno $"${exit_text}" 6 40 && [[ -e /tmp/unzip.log ]]  && clear && exit 0
}

mainmenu() {
    $DIALOG_CHECKED ${DEFAULT} --backtitle "${TITLE}" --title $" MAIN MENU " \
    --menu $"Use the UP and DOWN arrows to navigate menus.\nUse TAB to switch between buttons and ENTER to select." 17 58 13 \
    "0" $"Set Keyboard Language" \
    "1" $"Get the installator" \
    "2" $"Exit" 2>${ANSWER} 
    # NEXTITEM="$(cat ${ANSWER})"
    case $(cat ${ANSWER}) in
        "0") lang;;
        "1") install;;
		"2") exitt;;
        *) exitt;;
    esac
}

# Looking for network connection. Otherway could not start
$DIALOG_CHECKED --backtitle "${TITLE}" --aspect 15 --infobox $"Checking your connection..." 4 35
while [[ "$NETWORK_ALIVE" != "" ]];do
    $DIALOG_CHECKED --msgbox $"The network seems not to be working \n\nYou have to configure your Internet connection before. \n\nThen press 'OK'" 8 50
    NETWORK_ALIVE=`ping -c1 google.com 2>&1 | grep unknown`
done

if [[ "$NETWORK_ALIVE" = "" ]];then

    : >/tmp/.setup-running
    : >/tmp/.setup


    ##########################
    ###### Welcome Menu ######
    ##########################

    $DIALOG_CHECKED --title "[ Welcome ]" --clear --msgbox \
    "installation iz coming plz prepare urself" 20 75 \


    ################################################
    ###### Executing Rankmirror script or not ######
    ################################################

    if [[ -e /tmp/.rkm ]]; then
            $DIALOG_CHECKED --infobox $"Processing..." 0 0
            $DIALOG_CHECKED --yesno --default-no $"Your mirrorlist has been already ranked.\nWould you like to regenerate it before continuing ?" 0 0
                case $? in
                    0) #YES
                        run_rkm ;;
                    1) #NO 
                        # Nothing to do                        
                        $DIALOG_CHECKED --infobox $"You pressed no." 0 0
                        ;;
                esac
        else
            $DIALOG_CHECKED --msgbox $"We highly recommand you to rankmirroring 5 mirrors before launching the installation.\n\
            It will improve the download speed to get the needed packages during the installation.\n\
            Therefore this program will Rankmirroring 5 mirrors before entering Main menu.\n\n\
            This process could be rapid or not, depending on your connection" 0 0
            $DIALOG_CHECKED --infobox $"Processing..." 0 0
            run_rkm
    fi
    
    while true; do
        mainmenu
    done

fi

clear
exit 0