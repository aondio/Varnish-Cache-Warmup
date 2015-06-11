#!/bin/bash
# vars
verbose=0
url_file="urls_`date +%Y%m%d`.txt"

# define help function
function help(){
    echo "Varnish-Cache WarmUp";
    echo "===================="
    echo "Usage example:";
    echo "VCW (-l|--logfile) string [(-h|--help)] [(-v|--verbose)]";
    echo
    echo "Options:";
    echo "-h or --help:                    help";
    echo "-v or --verbose:                 verbose mode";
    echo "-l or --logfile (string):        apache access.log file.(mandatory)";
    exit 1;
}

# execute getopt
ARGS=$(getopt -o "hvl:" -l "help,verbose,logfile:" -n "Varnish-Cache WarmUp" -- "$@");

# and chek if bad arguments
if [ $? -ne 0 ];
then
    help;
fi

eval set -- "$ARGS";

while true; do
    case "$1" in
        -h|--help)
            shift;
            help;
            ;;
        -v|--verbose)
            shift;
                    verbose="1";
            ;;
        -l|--logfile)
            shift;
                    if [ -n "$1" ]; 
                    then
                        logfile="$1";
                        shift;
                    fi
            ;;
        --)
            shift;
            break;
            ;;
    esac
done

if [ -z "$logfile" ]
then
    echo "logfile is required.";
    exit 1
fi

if [ ! -f $logfile ]
then
    echo "logfile does not exist: $logfile"
    exit 1
fi

# strip URLs from logfile and save them in a tmp file.
cat $logfile | gawk '{print $1$7}' | gawk '{gsub(/?/, "", $1);print$1}' > $url_file

if [ ! -f $url_file ]
then
    echo "missing generated url file ($url_file)"
    exit 1
fi

# let's warm the cache up!
if which siege >/dev/null; then 
    arguments="--delay=1 -i --file=$url_file"

    if [ $verbose = 1 ]
    then
        arguments="$arguments -v"
    else
        arguments="$arguments -q"
    fi

    echo "siege $arguments"
   
    siege $arguments 
else
    arguments="-O/dev/null -i $url_file --random-wait"

    if [ $verbose = 1 ]
    then
        arguments="$arguments -v"
    else
        arguments="$arguments -q"
    fi

    echo "wget $arguments"

    wget $arguments
fi

# remove temp url file
rm $url_file
