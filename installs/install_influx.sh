#!/bin/bash

# Check ob Programm als root ausgefuehrt wird
user_check() {
	if [ $(id -u) -ne 0 ]; then
		printf "Script muss mit root ausgefuehrt werden. Versuche 'sudo ./install_influx.sh'\n"
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

# Influx intallieren
sudo dpkg -i ./InfluxTelegrafGrafana/influxdb_1.5.1_armhf.deb  
sudo systemctl enable influxdb  
sudo systemctl start influxdb

# Telegraf installieren
sudo dpkg -i ./InfluxTelegrafGrafana/telegraf_1.2.1_armhf.deb

# Konfiguration verschieben
sudo mv ../telegraf/telegraf_own.conf /etc/telegraf/telegraf.conf

# Telegraf Skripte verschieben
sudo mv ../telegraf/telegrag_pi_gpios.sh /usr/local/bin/telegrag_pi_gpios.sh
sudo mv ../telegraf/telegrag_pi_temp.sh /usr/local/bin/telegrag_pi_temp.sh

# Telegraf Skripte ausfuehrbar machen
sudo chmod +x /usr/local/bin/telegrag_pi_temp.sh
sudo chmod +x /usr/local/bin/telegrag_pi_gpios.sh

# Grafana installieren
sudo dpkg -i ./InfluxTelegrafGrafana/grafana_4.6.3_armhf.deb  
sudo systemctl enable grafana-server  
sudo systemctl start grafana-server