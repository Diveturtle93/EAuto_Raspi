# Raspi-Auto

## GPS

Der Raspberry Pi kann über eine serielle Schnittstelle die GPS Daten empfangen und einlesen.
Diese werden dann wie alle anderen Daten auch in die InfluxDB geschrieben. Dafür ruft
Telegraf ein Python-Skript auf, dass sich die empfangenen Daten ansieht und diese bearbeitet.
Danach werden die Daten an Telegraf übergeben und in die Influx-Datenbank geschrieben.

Der GPS-Sensor ist ein Mikroe-1032. Es kann aber auch jeder andere Sensor mit einer
seriellen Schnittstelle verwendet werden.

### Installation

Um die serielle Schnittstelle zu aktivieren, muss im System unter `Einstellungen ->
Raspberry Pi-Konfiguration -> Schnittstelle` der Serielle Anschluss mit ausgewählt werden.
Alternativ kann dies auch unter `raspi-config` gemacht werden. Dann muss man aber die Shell
deaktivieren.

Über den Befehl `ls -l /dev/ser*` in der Commandozeile kann sich danach angesehen werden,
welche Schnittstellen alle verfügbar sind. Im folgenden könnte dann die Ausgabe aussehen.

```
lrwxrwxrwx 1 root root 5 28. Sep 06:32 /dev/serial0 -> ttyS0
lrwxrwxrwx 1 root root 7 28. Sep 06:32 /dev/serial1 -> ttyAMA
```

Beim Raspberr Pi 3b ist standardmäßig auf den `ttyS0` das Bluetooth Modul gelegt. Ist diese
ausgeschaltet ist keine weitere Anpassung notwendig. Sollte es eingeschaltet sein, so muss
der richtige Kanal im Skript gewählt werden.

### Pakete

- gpsd-clients
- gpsd
- python-gps
- minicom

### Test

Mit dem folgende Befehl kann getestet werden, ob auf der seriellen Schnittstelle auch Daten
vom GPS-Sensor ankommen und diese richtig interpretiert werden.

```
sudo gpsmon /dev/serial0
```

Sollten hier keine Daten ankommen, kann man auch probieren die Raw-Werte der seriellen
Schnittstelle auszulesen. Dafür wird dann das Programm 'minicom' verwendet.

```
minicom -b 9600 -o -D /dev/ttyS0
```

Hier werden die Daten der seriellen Schnittstelle direkt angezeigt.

### Nachrichten

Als Daten kommen unterschiedliche Paket mit Informationen an. Diese haben die 

- $GPGGA
- $GPGSA
- $GPGSV
- $GPGLL
- $GPRMC
- $GPVTG

Die wichtigste Nachricht davon ist die `$GPGGA` alle anderen Nachrichten enthalten
Informationen, die hier nicht weiter betrachtet werden. Nachlesen was die Nachrichten und
ihre Daten bedeuten, kann man [hier](https://aprs.gids.nl/nmea/).

###### GPGGA

Diese Nachricht beinhalter die UTC Zeit, die Longitude, die Latitude, die Richtung und die
Altitude.

Aufgebaut ist die Nachricht wir folgt.

```
$GPGGA,UTC of position fix,Latitude,Direction of latitude,Longitude,Direction of longitude,GPS Quality indicator,Number of SVs in use, range from 00 through to 24+,HDOP,Orthometric height,unit of measure for orthometric height is meters,Geoid separation,geoid separation measured in meters
```