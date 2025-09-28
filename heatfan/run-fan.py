#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import time
import signal
import RPi.GPIO as GPIO

pin = 22 # The pin ID, edit here to change it (BCM)
schwell_temp = 40 # The maximum temperature in Celsius after which we trigger the fan
max_temp = 45 # The maximum temperature after the Controller shows a warning
shutdown_temp = 75 # The temperature when the raspberry pi shutdown itself
status = 0

def setup():
	GPIO.setmode(GPIO.BCM)
	GPIO.setup(pin, GPIO.OUT)
	GPIO.setwarnings(False)
	f = open('/home/development/HeatFan/log.txt', 'a')
	f.close()
	return()

def getCPUtemperature():
	res = os.popen('vcgencmd measure_temp').readline()
	temp = (res.replace("temp=","").replace("'C\n",""))
	#print("CPU-Temperatur beträgt {0}°C.".format(temp)) #Uncomment here for testing
	return temp

def getCPUvolts():
	res = os.popen('vcgencmd measure_volts').readline()
	temp = (res.replace("volt=","").replace("00V\n",""))
	#print("CPU-Spannung liegt bei {0}V.".format(temp)) #Uncomment here for testing
	return temp

def getClockARM():
	res = os.popen('vcgencmd measure_clock arm').readline()
	temp = (res.replace("frequency(45)=","").replace("000","").replace("000","")).replace("\n","")
	#print("CPU-Frequenz liegt bei {0}MHz.".format(temp)) #Uncomment here for testing
	return temp

def getClockCore():
	res = os.popen('vcgencmd measure_clock core').readline()
	temp = (res.replace("frequency(1)=","").replace("000","").replace("000","")).replace("\n","")
	#print("Grafikfrequenz liegt bei {0}MHz.".format(temp)) #Uncomment here for testing
	return temp
	
def getCPUarm():
	res = os.popen('vcgencmd get_mem arm').readline()
	temp = (res.replace("arm=","").replace("M","")).replace("\n","")
	#print("CPU-Ram beträgt {0}M.".format(temp)) #Uncomment here for testing
	return temp

def fanON():
	GPIO.output(pin, True)
	return()

def fanOFF():
	GPIO.output(pin, False)
	return()

def getTEMP(x):
	CPU_temp = float(getCPUtemperature())
	if CPU_temp > max_temp:
		if x != 2:
			writetime(CPU_temp, "Overheat")
		x = 2
		fanON()
		#print("Data wird in log.txt gespeichert")
		#print("CPU-Temperatur beträgt {0}°C".format(CPU_temp))
	elif CPU_temp > schwell_temp:
		if x == 0:
			writetime(CPU_temp, "Fan on")
		x = 1
		fanON()
		#print("CPU-Temperatur beträgt {0}°C".format(CPU_temp))
		#print "Fan an"
	elif CPU_temp > shutdown_temp:
		writetime(CPU_temp, "Thermal shutdown")
		os.system("sudo shutdown -h now")
	else:
		if x != 0:
			writetime(CPU_temp, "Fan off")
		x = 0
		fanOFF()
		#print("CPU-Temperatur beträgt {0}°C".format(CPU_temp))
		#print "Fan aus"
	return x
	
def writetime(data, status):
	f = open('./fan_log.txt', 'a')
	logtime = time.ctime()
	f.write("%s\t\t%s ==> %s°C" % (status, logtime, data))
	f.write(", %sV, %sMhz, %sMHz, %sM\n" % (getCPUvolts(), getClockARM(), getClockCore(), getCPUarm()))
	f.close() 

try:
	setup()
	while True:
		status = getTEMP(status)
		time.sleep(5) # Read the temperature every 5 sec, increase or decrease this limit if you want

except KeyboardInterrupt: # trap a CTRL+C keyboard interrupt
	GPIO.cleanup() # resets all GPIO ports used by this program
