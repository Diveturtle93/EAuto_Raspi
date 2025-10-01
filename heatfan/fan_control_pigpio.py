import os
import time
import sys
import pigpio

schwell_otemp = 50 # The maximum temperature in Celsius after which we trigger the fan
schwell_utemp = 35 # The maximum temperature in Celsius after which we trigger the fan
status = 0

pi = pigpio.pi()
pi.set_mode(26, pigpio.OUTPUT)

def getCPUtemperature():
	res = os.popen('vcgencmd measure_temp').readline()
	temp = (res.replace("temp=","").replace("'C\n",""))
	print("CPU-Temperatur beträgt {0}'C.".format(temp))
	return temp

def fanON():
	pi.write(26, True)
	return()

def fanOFF():
	pi.write(26, False)
	return()

def getTEMP(x):
	CPU_temp = float(getCPUtemperature())
	if CPU_temp>schwell_otemp:
		x = 1
		fanON()
		#print("CPU-Temperatur beträgt {0}°C".format(CPU_temp))
		print("Fan an")
	elif CPU_temp<schwell_utemp:
		x = 0
		fanOFF()
		#print("CPU-Temperatur beträgt {0}°C".format(CPU_temp))
		print("Fan aus")
	return x

try:
	while True:
		status = getTEMP(status)
		time.sleep(5) # Read the temperature every 5 sec, increase or decrease this limit if you want

except KeyboardInterrupt: # trap a CTRL+C keyboard interrupt
	sys.exit(0)