#!/bin/bash
while [ true ]
do
    cat list.txt | while read -r each
do
    >semaphore_stop
    echo "$each"
    if [ ! -d "playlists" ]
    then
        mkdir playlists
    fi
    if [ ! -d "playlists/`echo $each | sed 's/.*list=//'`" ]
    then
        mkdir "playlists/`echo $each | sed 's/.*list=//'`"
    fi
    youtube-dl --flat-playlist --get-filename --playlist-end 100  -o '%(id)s' "$each" > "playlists/`echo $each | sed 's/.*list=//'`/new.txt"
    OLDPL="playlists/`echo $each | sed 's/.*list=//'`/old.txt"
    NEWPL="playlists/`echo $each | sed 's/.*list=//'`/new.txt"
    #if [ ! -f "$OLDPL" ]
    #then
        #cat "$NEWPL" > "$OLDPL"
        #>semaphore_restart
    #elif [[ ! "`cat "$OLDPL"`" = "`cat "$NEWPL"`" ]]
    #then
        #>semaphore_restart
        #cat "$NEWPL" > "$OLDPL"
    #fi
done
rm semaphore_stop
sleep 1d
done
