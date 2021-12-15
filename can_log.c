// Auto shutdown, CL15 pin

// Include Files
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <time.h>

// GPIOs definieren, nach WPI
#define	Button1		30		// Pin 27, Rev1.0; Pin 15, Rev1.1

// Logdatei Name definieren
#define filename	"/home/development/Logs/can.log"

// Main Routine
int main(void)
{
	// Definiere Variablen
	FILE * datei;
	time_t timenow;
	struct tm *myTime;
	char date[20];
	int status = 0;
	int pid;

	// Zeit aufnehmen
	time(&timenow);
	myTime = localtime(&timenow);
	strftime(date, 20, "%Y.%m.%d-%H:%M:%S", myTime);

	// Log Programm start
	datei = fopen(filename, "a");
	fprintf(datei, "Starte Programm CAN Logger:\t%s\n", date);
	fclose(datei);

	// Starte WiringPi
	if (wiringPiSetup() < 0)
	{
		datei = fopen(filename, "a");
		fprintf(datei, "Die Bibliothek WiringPi konnte in CAN Logger nicht gestartet werden: %s!\n", strerror(errno));
		fclose(datei);
		return 1;
	}

	// Pinbelegung festlegen
	pinMode(Button1, INPUT);

	// Endlosschleife
	while(1)
	{
		// Einlesen des Pin KL15
		if (digitalRead(Button1) != 1)
		{
			if (status == 0)
			{
				// Zeit aufnehmen
				time(&timenow);
				myTime = localtime(&timenow);
				strftime(date, 20, "%Y.%m.%d-%H:%M:%S", myTime);

				// Log Canlog start
				datei = fopen(filename, "a");
				fprintf(datei, "Starte Can-Log", date);
				fclose(datei);
				
				// Starte Canlog
				system("candump -l can0 -s 2 &");
				status = 1;
			}
		}
		else
		{
			if (status == 1)
			{
				// Zeit aufnehmen
				time(&timenow);
				myTime = localtime(&timenow);
				strftime(date, 20, "%Y.%m.%d-%H:%M:%S", myTime);

				// Log Canlog stop
				datei = fopen(filename, "a");
				fprintf(datei, "Stoppe Can-Log", date);
				fclose(datei);
				
				// Stope Canlog
				system("pkill -f candump");
				status = 0;
			}
		}
	}
	return 0;
}
