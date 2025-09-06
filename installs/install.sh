#!/bin/bash

declare -a PkgArray=("git-core" "git" "wiringPi")

# Check ob Programm als root ausgefuehrt wird
user_check() {
	if [ $(id -u) -ne 0 ]; then
		printf "Script muss mit root ausgefuehrt werden. Versuche 'sudo ./install.sh'\n"
		exit 1				# Beende Programm
	fi
}

# Bestaetige Installation
confirm() {
	# Einlesen der Commandozeile
	read -r -p "Sind Sie sicher? [y/n]" response < /dev/tty

	# Vergleich ob bestaetigt wurde
	if [[ $response =~ ^(yes|Y|y|ja|j|J)$ ]]; then
		printf "Installation wird ausgefuehrt\n"
	else
		printf "Abbruch der Installation\n"
		exit 1	# Installation abbrechen
	fi

	# Zusaetzliche Zeile
	echo
}

user_check
printf "Installation vom AudiPi wird gestartet\n"

confirm

#apt update && apt upgrade

for val in ${PkgArray[@]}; do
	dpkg -s "$val" &> /dev/null
        if [ $? -eq 0 ]; then
                echo "Package $val is installed!"
        else
                echo "Package $val is NOT installed!"
#               apt install $val
        fi
done

# Eintraege fuer /boot/config vornehmen
echo 'dtoverlay=gpio-fan,gpiopin=26,temp=60000' >> /boot/config.txt
echo 'enable_uart=0' >> /boot/config.txt

# Clone git Repository
git clone https://github.com/Diveturtle93/Raspi-Auto.git

# Wechsel in Verzeichnis und compiliere C-Programme
cd Raspi-Auto
gcc -o auto_shutdown auto_shutdown.c -lwiringPi
gcc -o can_log can_log.c -lwiringPi
gcc -o lufter lufter.c -lwiringPi
cd cpu
gcc -o cpu_temp_influx cpu_temp_influx.c

cd ..
cd ..

# Loeschen der letzten Zeile von rc.local
head -n -1 /etc/rc.local > temp.txt
mv temp.txt /etc/rc.local

# Zum Ausfuehren der Programme schreibe Eintraege in rc.local und crontab
echo 'su pi -c /home/pi/Raspi-Auto/auto_shutdown &' >> /etc/rc.local
echo '/home/pi/Raspi-Auto/can_log &' >> /etc/rc.local
echo 'su pi -c /home/pi/Raspi-Auto/lufter &' >> /etc/rc.local
echo '' >> /etc/rc.local
echo 'exit 0' >> /etc/rc.local
echo '/1 *	* * *	pi	/home/pi/Raspi-Auto/cpu/cpu_temp_influx' >> /etc/crontab

printf "\nFertig!\n"
printf "Wenn das die erste Installation der Software ist sollte der Raspberry Pi rebootet werden\n\n"
