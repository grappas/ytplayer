#!/bin/bash
sleep 1
while [ -f semaphore_stop ]
do
    echo "Czekam na usunięcie semaphore_stop"
    sleep 5
done

while [ true ]
do
    >files.txt
    FILES="`find playlists | grep new`"
    echo "$FILES" | while read each
do
    echo -n "$each " >> files.txt
done
cat files.txt
FILES="`cat files.txt`"
echo "$FILES"
rm files.txt
sleep 1
rm semaphore_restart
while [ ! -f semaphore_restart ]
do
    for each in `paste $FILES`
    do
        if [ -f semaphore_restart ]
        then
            break
        fi
        while [ -f semaphore_wake ]
        do
            sleep 5
        done
        sleep 5
        echo "$each"
        #screen -S ff -md youtube-dl -f 140 --no-part -o - "$each" | mplayer -novideo -cache 1000 -cache-min 2 -
        #youtube-dl -f 140 --no-part -o - "$each" | mplayer -novideo -cache 1000 -cache-min 2 -
        mpv --no-video 'https://www.youtube.com/watch?v='"$each"
        #sleep 15
        #num=0
        #while  [ -n  "`pacmd list-sink-inputs | grep player`" ]
        #do
            #echo "ff odtwarza"
            #sleep 5
            #num=$((num + 5))
            #echo "$num"
            #if [ "$num" = "360" ]
            #then
                #killall mplayer
                #screen -X -S ff quit
            #fi
        #done
        #screen -X -S ff quit
        #python3 youtube-dl $each | cvlc --no-video
        #sleep 5
        #proxychains python3 youtube-dl --no-part -o - -f '[protocol^=https]' $each | cvlc --no-video --play-and-exit /dev/fd/3 3<&0 </dev/tty
    done
done
done


