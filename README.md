# Raspi-Auto

Der Raspberry Pi wird dafür benutzt Daten von einem Auto einzulesen und diese zu speichern.
Dabei werden Systemdaten als auch Fahrzeugdaten verarbeitet

## Datenspeicherung

Die Daten werden in einer InfluxDB gespeichert. Eingelesen werden sie mit Telegraf.

**Wichtig:** Ein Update der Software-Pakete sollte vorher erfolgen. Nach der Installation
von Influx, Telegraf und Grafana ist ein erneutes Update nicht emfohlen. Die Software ist
auf einem älteren Stand und läuft stabil. Nach einem Update kann eine einwandfreie Funktion
nicht sicher gestellt werden

#### Versionen

Die verwendeten Versionen sind für einen Raspberry Pi 3B und laufen dort stabil. Das
Betriebssystem ist ein Debian GNU / Linux 12 (bookworm) (Stand: 26.09.25)

- Influx 1.5.1
- Telegraf 1.2.1
- Grafana 4.6.3

### InfluxDB
 
Influx ist das Programm mit dem die Datenbank zur Speicherung der Daten aufgesetzt wird.
Die Datenbank bekommt alle Daten und trägt diese in unterschiedliche Tabellen ein. Darin
sind dann die Daten vorhanden. Diese können zur Auswertung ausgelesenen werden oder live
auf einem Terminal oder grafischen Oberfläche angezeigt werden.

Nach der Installation der InfluxDB muss noch in der Config nach dem Abschnitt `[http]`
gesucht werden. Hier müssen dann noch Einstellungen manuell eingetragen werden.

```
[http]   
  enabled = true   
  bind-address = ":8086"   
  auth-enabled = true
```

Ggf. sind die Einträge auch schon vorhanden. Dann müssen diese nur auskommentiert werden.

### Telegraf

Telegraf ist der genutzte Handler, der die Daten in die Datenbank einträgt. Zudem liest er
alle Daten in einem dafür definierten Zeitintervall ein. Er führt Programme aus oder nutzt
Systembefehle um die Daten zu erhalten. Danach trägt er sie in die dafür definierten
Tabellen und speichert diese somit in der InfluxDB. Eine vorgefertigte `telegraf.conf` ist
im Installationspaket mit includiert und muss die Standard-Config nur überschreiben.

### Grafana

Grafana dient zur Anzeige von Daten. Das Programm stellt diese auf einer grafischen
Oberfläche zur Verfügung. Dabei sucht es sich die Daten aus der InfluxDB. Die grafische
Oberfläche muss zuvor benutzerdefiniert aufgesetzt werden.

## GPIOs

Am Raspberry Pi sind mehrere GPIOs, bei welchen der Pinzustand regelmäßig geprüft werden
muss. Dafür wurde ein kleines Skript geschrieben, welches die Pinzustände einließt. Dieses
wird dann über Telegraf ausgeführt und die Ausgabe wird an die InfluxDB weitergegeben.

Das Skript macht nichts anderes als die GPIOs über `pigpio` einzulesen und danach über eine
`print`-Ausgabe zurückzugeben. Telegraf ließt diese ein und schreibt sie in die Datenbank.

Das Skript wird unter '/usr/local/bin' abgelegt.

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

Die Nachricht auf die hier näher eingegangen wird sind `$GPGGA`, `GPVTG`und `GPRMC`. Alle
anderen Nachrichten enthalten Informationen, die hier nicht weiter betrachtet werden.
Nachlesen was die Nachrichten und ihre Daten bedeuten, kann man [hier](https://aprs.gids.nl/nmea/).

###### GPGGA

Diese Nachricht beinhalter die UTC Zeit, die Longitude, die Latitude, die Richtung und die
Altitude.

Aufgebaut ist die Nachricht wir folgt.

```
$GPGGA,UTC of position fix,Latitude,Direction of latitude,Longitude,Direction of longitude,GPS Quality indicator,Number of SVs in use, range from 00 through to 24+,HDOP,Orthometric height,unit of measure for orthometric height is meters,Geoid separation,geoid separation measured in meters
```

###### GPVTG

Diese Nachricht beinhaltet die Geschwindigkeit in Knoten und Kilometer pro Stunde sowie
die Richtung in die man sich bewegt in Grad.

Aufgebaut ist die Nachricht wir folgt.

```
$GPVTG, Track made degrees True, True track indicator, Track made good degrees Magnetic, Magnetic track indicator, Speed over ground kn, Nautical speed indicator, Speed km/h, Speed indicator
```

###### GPRMC

Diese Nachricht beinhaltet die Geschwindigkeit in Knoten und Kilometer pro Stunde sowie
die Richtung in die man sich bewegt in Grad.

Aufgebaut ist die Nachricht wir folgt.

```
$GPRMC, UTC of position, Position status, Latitude, Latitude direction, Longitude, Longitude direction, Speed over ground kn, Track made degrees True, Date, Magnetic variation, Magnetic variation direction, Positioning system mode indicator
```