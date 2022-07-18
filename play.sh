#!/bin/bash

if [ "$1" = "" ]
then
echo "Argument -h lub --help, aby otrzymać pomoc."
fi

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    echo "
    -h|--help			Wyświetl tą wiadomość.
    
    -s|--start			Start/restart muzyki.
    
    -t|--stop			Zatrzymaj muzykę.
    
    -a|--append \"URL\"	Dodaj playlistę.
    
    -p|--pop \"URL\"	Usuń playlistę.
    "
    exit 1
    ;;
    -s|--start)
    if [ "`screen -list | grep ytloop`" = "" ]
    then
    screen -S ytloop -md bash ytloop.sh
    fi
    screen -X -S ytdl quit
    #screen -X -S ff quit
    killall mplayer
    screen -S ytdl -md bash ytdll.sh
    shift # past argument
    ;;
    -t|--stop)
    screen -X -S ytdl quit
    screen -X -S ytloop quit
    screen -X -S wake quit
    #screen -X -S ff quit
    killall mplayer
    shift # past argument
    ;;
    -w|--wake)
    screen -X -S wake quit
    screen -S wake -md bash wake.sh "$2"
    shift # past argument
    ;;
    -cw|--cancelwake)
    screen -X -S wake quit
    if [ -f semaphore_wake ]
    then
    rm semaphore_wake
    fi
    shift # past argument
    ;;
    -a|--append)
    if [ ! -z "`echo "$2" | grep "list=" | grep "https://www.youtube.com/"`" ]
    then
    echo "$2" >> list.txt
    cat list.txt | sed 's/.*list=//' > list.tmp
    cat list.tmp | sort | uniq > list2.tmp
    for each in `cat list2.tmp`
    do
    cat list.txt | grep -m 1 "$each" >> list3.tmp
    done
    cat list3.tmp > list.txt
    rm list.tmp
    rm list2.tmp
    rm list3.tmp
    else
    echo "URL powinien zawierać playlistę!"
    exit 1
    fi
    screen -X -S ytloop quit
    screen -S ytloop -md bash ytloop.sh
    shift # past argument
    shift # past value 
    ;;
    -p|--pop)
    if [ ! -z "`echo "$2" | grep "list=" | grep "https://www.youtube.com/"`" ]
    then
    cat list.txt > list.tmp
    cat list.tmp | grep -v "`echo $2 | sed 's/.*list=//'`" > list.txt
    rm list.tmp
    rm -rf "`echo $2 | sed 's/.*list=//'`"
    else
    echo "URL powinien zawierać playlistę!"
    exit 1
    fi
    screen -X -S ytloop quit
    screen -S ytloop -md bash ytloop.sh
    shift # past argument
    shift # past value 
    ;;
    *)    # unknown option
    echo "Argument -h lub --help, aby otrzymać pomoc."
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters
