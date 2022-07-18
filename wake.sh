#!/bin/bash

>semaphore_wake
killall mplayer
#screen -X -S ff quit
while [ ! "`date +%R`" = "$1" ]
do
sleep 5
done
rm semaphore_wake
