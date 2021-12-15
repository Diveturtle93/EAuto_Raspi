// Auto shutdown, CL15 pin

// Include Files
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <time.h>

// GPIOs definieren, nach WPI
#define	BUTTON2		11		// Pin 26, Rev1.0; Pin 13, Rev1.1
#define	LUFTER		25		// Pin 37, Rev1.0; Pin 37, Rev1.1

// Logdatei Name definieren
#define filename	"/home/development/Logs/Luefter.log"

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
	fprintf(datei, "Starte Programm Lüfter:\t%s\n", date);
	fclose(datei);

	// Starte WiringPi
	if (wiringPiSetup() < 0)
	{
		datei = fopen(filename, "a");
		fprintf(datei, "Die Bibliothek WiringPi konnte in Lüfter nicht gestartet werden: %s!\n", strerror(errno));
		fclose(datei);
		return 1;
	}

	// Pinbelegung festlegen
	pinMode(BUTTON2, INPUT);
	pinMode(LUFTER, OUTPUT);

	// Raspberry Pi Luefter einschalten
	digitalWrite(LUFTER, 1);

	// Endlosschleife
	while(1)
	{
		// Einlesen des Pin KL15
		if (digitalRead(BUTTON2) != 1)				// Schalter nicht betätigt = 1, Schalter betätigt = 0
		{
			// Luefter einschalten
			digitalWrite(LUFTER, 1);

			// Warten 1s
			delay(1000);
			count = 0;
		}
		else
		{
			// Warten 1s
			delay(1000);
			count ++;
		}

		// Countvariable erreicht 60 (1min)
		if (count >= 60)
		{
			// Luefter ausschalten
			digitalWrite(LUFTER, 0);
		}

	}
	return 0;
}
