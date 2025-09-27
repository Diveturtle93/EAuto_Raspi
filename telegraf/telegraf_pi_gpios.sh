#!/bin/bash
kl15=$(pigs r 4)
button1=$(pigs r 22)
button2=$(pigs r 27)
luefter=$(pigs r 26)
echo -e "{\"Button1\":$button1, \"Button2\":$button2, \"KL15\":$kl15, \"Luefter\":$luefter}"