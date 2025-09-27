# Raspi-Auto

Der Raspberry Pi wird dafür benutzt Daten von einem Auto einzulesen und diese zu speichern,
Dabei werden Systemdaten als auch Fahrzeugdaten verarbeitet

## Datenspeicherung

Die Daten werden in einer InfluxDB gespeichert. Eingelesen werden sie mit Telegraf.

### InfluxDB
 
Influx ist das Programm mit dem die Datenbank zur Speicherung der Daten aufgesetzt wird. Die
Datenbank bekommt alle Daten und trägt diese in unterschiedliche Tabellen ein. Darin sind
dann die Daten vorhanden. Diese können zur Auswertung ausgelesenen werden oder live auf
einem Terminal oder grafischen Oberfläche angezeigt werden.

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