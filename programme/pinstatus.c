// Pin Status am Raspberry Pi

// Include Files
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <time.h>

#define PCB_REV		10		// 10 = Rev1.0, 11 = Rev1.1, 12 = Rev1.2

// GPIOs definieren, nach WPI
#ifdev	PCB_REV == 10		// Rev1.0
	#define	KL15		6		// Pin 22, Rev1.0
	#define	BUTTON1		30		// Pin 27, Rev1.0
	#define	BUTTON2		11		// Pin 26, Rev1.0
	#define	LUFTER		25		// Pin 37, Rev1.0
	#define RTC_INT		1		// Pin 12, Rev1.0
	#define RTC_RST		5		// Pin 18, Rev1.0
	#define CAN_INT		31		// Pin 28, Rev1.0
	#define GPS_RST		26		// Pin 32, Rev1.0
	#define GPS_INT		22		// Pin 31, Rev1.0
	#define GPS_AN		27		// Pin 36, Rev1.0
	#define GPS_PWM		23		// Pin 33, Rev1.0
#elif	PCB_REV == 11		// Rev1.1
	#define	KL15		7		// Pin 7, Rev1.1
	#define	PI_ON		5		// Pin 18, Rev1.1
	#define	BUTTON1		3		// Pin 15, Rev1.1
	#define	BUTTON2		2		// Pin 13, Rev1.1
	#define	LUFTER		25		// Pin 37, Rev1.1
	#define RTC_INT		24		// Pin 35, Rev1.1
	#define RTC_RST		21		// Pin 29, Rev1.1
	#define GYRO_INT	0		// Pin 11, Rev1.1
	#define CAN_INT		11		// Pin 26, Rev1.1
	#define GPS_RST		26		// Pin 32, Rev1.1
	#define GPS_INT		22		// Pin 31, Rev1.1
	#define GPS_AN		27		// Pin 36, Rev1.1
	#define GPS_PWM		23		// Pin 33, Rev1.1
#elif	PCB_REV == 12		// Rev1.2
	#define	KL15		7		// Pin 7, Rev1.2
	#define	PI_ON		5		// Pin 18, Rev1.2
	#define	BUTTON1		3		// Pin 15, Rev1.2
	#define	BUTTON2		2		// Pin 13, Rev1.2
	#define	LUFTER		29		// Pin 40, Rev1.2
	#define LED			25		// Pin 37, Rev1.2
	#define RTC_INT		24		// Pin 35, Rev1.2
	#define RTC_RST		21		// Pin 29, Rev1.2
	#define GYRO_INT	0		// Pin 11, Rev1.2
	#define CAN_INT		11		// Pin 26, Rev1.2
	#define GPS_RST		26		// Pin 32, Rev1.2
	#define GPS_INT		22		// Pin 31, Rev1.2
	#define GPS_AN		27		// Pin 36, Rev1.2
	#define GPS_PWM		23		// Pin 33, Rev1.2
#else
	#error "Keine valide Revision gewählt"
#endif

// Main Routine
int main(void)
{
	// Starte WiringPi
	if (wiringPiSetup() < 0)
	{
		return 1;
	};

	// Endlosschleife
	while(1)
	{
		
	}
	return 0;
}
