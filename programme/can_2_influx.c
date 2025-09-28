// Auto can2influx

// Include Files
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/socket.h>

#include <linux/can.h>
#include <linux/can/raw.h>

// Logdatei Name definieren
#define filename	"/home/development/Logs/can_2_influx.log"

// Main Routine
int main(int argc, char **argv)
{
	// Definiere Variablen
	FILE * datei;
	time_t timenow;
	struct tm *myTime;
	char date[20];
	int status = 0;
	
	int hSocket, i; 
	int nbytes;
	struct sockaddr_can addr;
	struct ifreq ifr;
	struct can_frame frame;
	
	int count = 0;

	printf("CAN Sockets Receive Demo\r\n");

	if ((hSocket = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
		perror("Socket");
		return 1;
	}

	strcpy(ifr.ifr_name, "can0" );
	ioctl(hSocket, SIOCGIFINDEX, &ifr);

	memset(&addr, 0, sizeof(addr));
	addr.can_family = AF_CAN;
	addr.can_ifindex = ifr.ifr_ifindex;

	if (bind(hSocket, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
		perror("Bind");
		return 1;
	}
		
	// Zeit aufnehmen
	time(&timenow);
	myTime = localtime(&timenow);
	strftime(date, 20, "%Y.%m.%d-%H:%M:%S", myTime);

	// Log Programm start
	datei = fopen(filename, "a");
	fprintf(datei, "Starte Programm CAN Logger:\t%s\n", date);
	fclose(datei);
	
	while(1)
	{
		nbytes = read(hSocket, &frame, sizeof(struct can_frame));
		
		count++;

		/*if (nbytes < 0) {
			perror("Read");
			return 1;
		}*/

		printf("0x%03X [%d] ",frame.can_id, frame.can_dlc);

		for (i = 0; i < frame.can_dlc; i++)
			printf("%02X ",frame.data[i]);

		printf("\t%d\r\n",count);

		/*if (close(hSocket) < 0) {
			perror("Close");
			return 1;
		}*/
	}
	return 0;
}
