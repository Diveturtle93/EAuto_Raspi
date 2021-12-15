#include <stdio.h>
#include <stdlib.h>
#include "../inc/influxdb.h"

int main() {
	FILE *fp;
	double T;

	// define influxdb client
	//influx_client_t c = {.host = strdup("127.0.0.1"), .port = 8086, .db = strdup("GPSTest"), .usr = strdup("admin"), .pwd = strdup("test")};
	//influx_client_t c = {strdup("127.0.0.1"), 8086, NULL, NULL, NULL};
	influx_client_t c;
	c.host = strdup("127.0.0.1");
	c.port = 8086;
	c.db = strdup("GPSTest");
	c.usr = strdup("admin");
    c.pwd = strdup("test");

	// Check the CPU temp.
	fp = fopen("/sys/class/thermal/thermal_zone0/temp", "r");
	if(fp == NULL)
	{
		return -1;
	}

	// Read the output a line at a time.
	fscanf(fp, "%lf", &T);

	// Close file
	fclose(fp);

	// Convert to °C
	T /= 1000;

	// Write temperature
	printf("Temperatur = %6.3f\n", T);

	// write DB
	post_http(&c, INFLUX_MEAS("CPU"), INFLUX_TAG("CPU_Temp", 1), INFLUX_F_FLT("Temp", T, 3), INFLUX_END);
	//send_udp(&c, INFLUX_MEAS("CPU"), INFLUX_TAG("CPU_Temp", 1), INFLUX_F_FLT("Temp", 10.3456, 2), INFLUX_F_BOL("Test", 1), INFLUX_END);
}