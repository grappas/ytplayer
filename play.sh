#!/bin/bash

if [ "$1" = "" ]
then
echo "Pass -h or --help for help."
fi

DEPENDENCYCHECK=

if [ ! -z "$(where screen | grep 'not found')" ]
then
DEPENDENCYCHECK="screen
$DEPENDENCYCHECK"
fi

if [ ! -z "$(where mplayer | grep 'not found')" ]
then
DEPENDENCYCHECK="mplayer
$DEPENDENCYCHECK"
fi

if [ ! -z "$(where jq | grep 'not found')" ]
then
DEPENDENCYCHECK="jq
$DEPENDENCYCHECK"
fi

if [ ! -z "$(where youtube-dl | grep 'not found')" ]
then
DEPENDENCYCHECK="youtube-dl
$DEPENDENCYCHECK"
fi

if [ ! -z "$DEPENDENCYCHECK" ]
then
    echo "
Dependencies not satisfied.
Please install these applications:
$DEPENDENCYCHECK
"
exit 1
fi

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    echo "
    -h|--help			        Display this message.

    -s|--start			        Start playing.

    -t|--stop			        Stop playing.

    -a|--append <Playlist ID>	Append playlist.

    -p|--pop <Playlist ID>	    Pop playlist.
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
    echo "It should contain playlist ID."
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
    echo "It should contain playlist ID"
    exit 1
    fi
    screen -X -S ytloop quit
    screen -S ytloop -md bash ytloop.sh
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    echo "Pass -h or --help for help."
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters
