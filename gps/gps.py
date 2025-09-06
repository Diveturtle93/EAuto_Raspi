#!/usr/bin/env python
#http://raspberry.tips/projekte/gps-tracking-mit-dem-raspberry-pi
import subprocess
import time
from datetime import datetime as dt
 
# Terminate existing gpsd instances, start gpsd and sleep a few seconds
subprocess.call('sudo killall gpsd', shell=True)
subprocess.call('sudo /usr/sbin/gpsd /dev/ttyAMA0 -F /var/run/gpsd.sock', shell=True)
time.sleep(30)
 
# Refresh the local time
subprocess.call('sudo service ntp restart', shell=True)
time.sleep(3)
 
#output file name with actual date
filename = "/home/pi/gpstrack-" + dt.now().strftime("%Y%m%d-%H%M%S") + ".txt"
 
# start gpspipe and output the GPS Data as NMEA to file
subprocess.call('gpspipe -d -l -r -o '+ filename +' ', shell=True)