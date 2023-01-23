#!/usr/bin/env bash
#
# @ds9-tech github.com

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

connect(){
	sudo wg-quick up helpdesk 2&>/dev/null
	ping -c1 10.14.13.1 2&>/dev/null
	echo -e "$GREEN Your remote connection has been established.$NC"
	echo -e ""
}

disconnect(){
	sudo wg-quick down helpdesk 2&>/dev/null
	echo -e "$RED Your remote connection has been terminated.$NC"
	echo -e ""
}

quit(){
	echo -e "$RED Disconnecting from the remote HelpDesk.$NC"
	sudo wg-quick down helpdesk 2&>/dev/null
	echo -e ""
	read -n1 -r -p "The program is ready to exit. Press any key to continue..."
}

cat << "EOF"

   __          __         _                                       _
   \ \        / /        | |                                     | |
    \ \  /\  / /    ___  | |   ___    ___    _ __ ___     ___    | |_    ___
     \ \/  \/ /    / _ \ | |  / __|  / _ \  | '_ ` _ \   / _ \   | __|  / _ \
      \  /\  /    |  __/ | | | (__  | (_) | | | | | | | |  __/   | |_  | (_) |
       \/  \/      \___| |_|  \___|  \___/  |_| |_| |_|  \___|    \__|  \___/

		  
    _     _                _    _          _           _____                 _    
   | |   | |              | |  | |        | |         |  __ \               | |   
   | |_  | |__     ___    | |__| |   ___  | |  _ __   | |  | |   ___   ___  | | __
   | __| | '_ \   / _ \   |  __  |  / _ \ | | | '_ \  | |  | |  / _ \ / __| | |/ /
   | |_  | | | | |  __/   | |  | | |  __/ | | | |_) | | |__| | |  __/ \__ \ |   < 
    \__| |_| |_|  \___|   |_|  |_|  \___| |_| | .__/  |_____/   \___| |___/ |_|\_\
                                              | |                                 
                                              |_|                                 

					      
EOF

#echo -e "\nWelcome to the HelpDesk tool. \n"
echo -e " This tool will create a remote connection to the HelpDesk."
echo -e " Once connected, your administrator can access your system for support. \n"
echo -e ""
echo -e " When you want to end the remote session hit the $RED'q'$NC key, the connection will terminate,"
echo -e " and the administrator will no longer be able to connect to your computer."
echo -e " Feel free to quit the program at any time by hitting the $RED'x'$NC key."
echo -e ""

echo -e "$GREEN c$NC |$GREEN C$NC - Start remote connection to the HelpDesk."
echo -e "$GREEN q$NC |$GREEN Q$NC - Terminate the remote connection to the HelpDesk."
echo -e "$GREEN x$NC |$GREEN X$NC - This will terminate remote connections and exit this tool."
echo -e ""

while true; do
        read -p " Please Select from one of the following options: " choice
		echo -e  ""
		echo -e "$GREEN c$NC |$GREEN C$NC - Start remote connection to the HelpDesk."
		echo -e "$GREEN q$NC |$GREEN Q$NC - Terminate the remote connection to the HelpDesk."
		echo -e "$GREEN x$NC |$GREEN X$NC - This will terminate remote connections and exit this tool."
		echo -e ""

        case "$choice" in
			c|C ) connect ;;
			q|Q ) disconnect ;;
			x|X ) quit; break ;;
            * ) echo -e "\n That is an invalid selection.\n" ;;
        esac
    done

