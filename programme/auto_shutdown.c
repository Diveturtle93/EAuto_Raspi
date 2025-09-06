// Auto shutdown, KL15 pin

// Include Files
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <time.h>

// GPIOs definieren, nach WPI
#define	KL15		6		// Pin 22, Rev1.0; Pin 7, Rev1.1
#define	PI_ON		5		// Pin 18, Rev1.1

// Logdatei Name definieren
#define filename	"/home/development/Logs/autoshutdown.log"

// Main Routine
int main(void)
{
	// Definiere Variablen
	FILE * datei;
	time_t timenow;
	struct tm *myTime;
	char date[20];
	int count;

	// Zeit aufnehmen
	time(&timenow);
	myTime = localtime(&timenow);
	strftime(date, 20, "%Y.%m.%d-%H:%M:%S", myTime);

	// Start Programm
	datei = fopen(filename, "a");
	fprintf(datei, "Starte Programm Autoshutdown:\t%s\n", date);
	fclose(datei);

	// Starte WiringPi
	if (wiringPiSetup() < 0)
	{
		datei = fopen(filename, "a");
		fprintf(datei, "Die Bibliothek WiringPi konnte in Auto-shutdown nicht gestartet werden: %s!\n", strerror(errno));
		fclose(datei);
		return 1;
	}

	// Pinbelegung festlegen
	pinMode(KL15, INPUT);
//	pinMode(PI_ON, OUTPUT);

	// Raspberry Pi dauerhaft einschalten
//	digitalWrite(PI_ON, 1);

	// Endlosschleife
	while(1)
	{
		// Einlesen des Pin KL15
		if (digitalRead(KL15) != 1)
		{
			// KL15 ist aktiv
			delay(1000);
			count = 0;
		}
		else
		{
			// KL15 ist nicht aktiv
			delay(1000);
			count ++;
		}

		// Countvariable erreicht 300 (5min)
		if (count >= 300)
		{
			// Zeit aufnehmen
			time(&timenow);
			myTime = localtime(&timenow);
			strftime(date, 20, "%Y.%m.%d-%H:%M:%S", myTime);
			
			// Beende Programm
			datei = fopen(filename, "a");
			fprintf(datei, "Shutdown Raspberry Pi:\t%s\n", date);
			fclose(datei);
			
			// System ausschalten
			system("sudo shutdown now");
		}

	}
	return 0;
}
