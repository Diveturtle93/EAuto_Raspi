#!/bin/bash

declare -a PkgArray=("dnsmasq" "hostapd" "iptables")

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
	read -r -p "Sind Sie sicher? Am Ende wird ein Reboot durchgefuehrt [y/n]" response < /dev/tty

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

# Schleife um Programme zu installieren
for val in ${PkgArray[@]}; do
	dpkg -s "$val" &> /dev/null
        if [ $? -eq 0 ]; then
                echo "Package $val is installed!"
        else
                echo "Package $val is NOT installed!"
#               apt install $val
        fi
done

# dhcpcd.conf mit Daten beschreiben
echo 'interface wlan0' >> /etc/dhcpcd.conf
echo 'static ip_address=192.168.4.1/24' >> /etc/dhcpcd.conf
echo 'nohook wpa_supplicant' >> /etc/dhcpcd.conf

# dhcpcd Dienst neustarten
systemclt restart dhcpcd

# DNS Masq einstellen
echo '# DHCP-Server aktiv fuer WLAN-Interface' >> /etc/dnsmasq.conf
echo 'interface=wlan0' >> /etc/dnsmasq.conf
echo '' >> /etc/dnsmasq.conf
echo '# DHCP-Server nicht aktiv fuer bestehendes Netzwerk' >> /etc/dnsmasq.conf
echo 'no-dhcp-interface=eth0' >> /etc/dnsmasq.conf
echo '' >> /etc/dnsmasq.conf
echo '# IPv4-Adressbereich und Lease-Time' >> /etc/dnsmasq.conf
echo 'dhcp-range=192.168.4.100,192.168.4.200,255.255.255.0,24h' >> /etc/dnsmasq.conf
echo '' >> /etc/dnsmasq.conf
echo '# DNS' >> /etc/dnsmasq.conf
echo 'dhcp-option=option:dns-server,192.168.4.1' >> /etc/dnsmasq.conf
echo '' >> /etc/dnsmasq.conf

# WLAN-Router einstellen, Hostapd setzen
echo '# WLAN-Router-Betrieb' > /etc/hostapd/hostapd.conf
echo '' >> /etc/hostapd/hostapd.conf
echo '# Schnittstelle und Treiber' >> /etc/hostapd/hostapd.conf
echo 'interface=wlan0' >> /etc/hostapd/hostapd.conf
echo '#driver=nl80211' >> /etc/hostapd/hostapd.conf
echo '' >> /etc/hostapd/hostapd.conf
echo '# WLAN-Konfiguration' >> /etc/hostapd/hostapd.conf
echo 'ssid=AudiPi' >> /etc/hostapd/hostapd.conf
echo 'channel=1' >> /etc/hostapd/hostapd.conf
echo 'hw_mode=g' >> /etc/hostapd/hostapd.conf
echo 'ieee80211n=1' >> /etc/hostapd/hostapd.conf
echo 'ieee80211d=1' >> /etc/hostapd/hostapd.conf
echo 'country_code=DE' >> /etc/hostapd/hostapd.conf
echo 'wmm_enabled=1' >> /etc/hostapd/hostapd.conf
echo '' >> /etc/hostapd/hostapd.conf
echo '# WLAN-Verschluesselung' >> /etc/hostapd/hostapd.conf
echo 'auth_algs=1' >> /etc/hostapd/hostapd.conf
echo 'wpa=2' >> /etc/hostapd/hostapd.conf
echo 'wpa_key_mgmt=WPA-PSK' >> /etc/hostapd/hostapd.conf
echo 'rsn_pairwise=CCMP' >> /etc/hostapd/hostapd.conf
echo 'wpa_passphrase=@udiPi!&' >> /etc/hostapd/hostapd.conf

# Leseberechtigungen fuer Root setzen
chmod 600 /etc/hostapd/hostapd.conf

# Hostapd starten bei Systemstart
echo 'RUN_DAEMON=yes' >> /etc/default/hostapd
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd

# Einschalten des Dienstes hostapd
systemctl unmask hostapd
systemctl start hostapd
systemctl enable hostapd

# IP-forwarding einschalten
IP=net.ipv4.ip_forward=1; sed -i "/^#$IP/ c$IP" /etc/sysctl.conf

# NAT aktivieren und speichern
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sh -c "iptables-save > /etc/iptables.ipv4.nat"

# Loeschen der letzten Zeile von rc.local
head -n -1 /etc/rc.local > temp.txt
mv temp.txt /etc/rc.local

# Laden der NAT bei Systemstart
echo 'iptables-restore < /etc/iptables.ipv4.nat' >> /etc/rc.local
echo '' >> /etc/rc.local
echo 'exit 0' >> /etc/rc.local

printf "\nFertig!\n"
printf "Der Raspberry Pi muss jetzt rebootet werden\n\n"

sleep(20)
reboot