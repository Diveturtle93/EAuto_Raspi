#!/usr/bin/env python3

import sys
import json
import gps
import time

def main():
    # Verbindung zu gpsd herstellen
    session = gps.gps(host="127.0.0.1", port="2947")
    session.stream(gps.WATCH_ENABLE | gps.WATCH_NEWSTYLE)

    try:
        for report in session:
            if report['class'] == 'TPV':  # Time-Position-Velocity
                latitude = getattr(report, 'lat', None)
                longitude = getattr(report, 'lon', None)
                altitude = getattr(report, 'alt', None)
                speed = getattr(report, 'speed', None)

                data = {
                    "Latitude": latitude,
                    "Longitude": longitude,
                    "Altitude_m": altitude,
                    "Speed_m_s": speed
                }

                # JSON-Ausgabe fuer Telegraf
                print(json.dumps(data))
                sys.exit(0)  # nur einmal ausgeben und beenden

            time.sleep(0.5)

    except KeyboardInterrupt:
        sys.exit(0)

if __name__ == "__main__":
    main()