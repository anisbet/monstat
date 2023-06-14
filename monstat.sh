#!/bin/bash
###############################################################################
#
# watcher.sh watches for new files in a set of directores.
# 
#  Copyright 2021 Andrew Nisbet
#  
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#  
#       http://www.apache.org/licenses/LICENSE-2.0
#  
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Wed 17 Feb 2021 10:26:29 AM EST
#
###############################################################################
set -o pipefail

. ~/.bashrc
VERSION="0.0.1"
is_test=false
is_background_process=false
APP=$(basename -s .sh $0)
RETRIES=5
# Prints out usage message.
usage()
{
    cat << EOFU!
 Usage: $0 [flags]

Starts and monitors status of arbitrary scripts.

Flags:
-b, -bg, --bg: Put process in background.
-h, -help, --help: This help message.
-r, -retry, --retry[int]: Retry to start the script 'n' times before mailing.
-t, -test, --test: Display debug information to STDOUT.
-v, -version, --version: Print monstat.sh version and exits.
 Example:
    ${0} --retry=5
EOFU!
}

##### Non-user-related variables ########


### Check input parameters.
# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
# the comma separates different long options
# -a is for long options with single dash like -version
options=$(getopt -l "bg,help,retry:,test,version" -o "bhr:tv" -a -- "$@")
if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi
# set --:
# If no arguments follow this option, then the positional parameters are unset. Otherwise, the positional parameters
# are set to the arguments, even if some of them begin with a ‘-’.
eval set -- "$options"

while true
do
    case $1 in
    -b|--bg)
        is_background_process=true
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    -r|--retry)
        shift
        RETRIES=$(echo "$1 + 0" | bc -l)
        ;;
    -t|--test)
        is_test=true
        ;;
    -v|--version)
        echo "$APP version: $VERSION"
        exit 0
        ;;
    --)
        shift
        break
        ;;
    esac
    shift
done
# Make a directory where we store the command and pids of child processes.
MONSTAT_DIR_BASE="/home/anisbet/Dev/EPL"
MONSTAT_DIR="$MONSTAT_DIR_BASE/$APP"
## Set up logging.
LOG_FILE="$MONSTAT_DIR/$APP.log"
# Logs messages to STDERR and $LOG file.
# param:  Log file name. The file is expected to be a fully qualified path or the output
#         will be directed to a file in the directory the script's running directory.
# param:  Message to put in the file.
# param:  (Optional) name of a operation that called this function.
logit()
{
    local message="$1"
    local time=$(date +"%Y-%m-%d %H:%M:%S")
    if [ -t 0 ]; then
        # If run from an interactive shell message STDERR.
        echo -e "[$time] $message" >&2
    fi
    echo -e "[$time] $message" >>$LOG_FILE
}

# The command to run should be the first non-commented line is the command file.
start()
{
    COMMAND_FILE="$MONSTAT_DIR/commands"
    if [ -f "$COMMAND_FILE" ]; then
        while read -r line; do
            # Ignore lines that start with comments.
            [ -z "$(echo $line | egrep -ve '^#')" ] && continue
            if [ "$is_background_process" == true ]; then
                logit "command '$line' running in background."
                command $line >>"$LOG_FILE"&
            else
                result=$(command $line)
                if (("$?" > 0)); then
                    logit "command '$line' failed."
                    continue
                fi
                if [ -z "$result" ]; then
                    logit "command '$line' ran."
                else
                    logit "command '$line' output:\n$result"
                fi
            fi
        done <"$COMMAND_FILE"
    else
        logit "no command file ($COMMAND_FILE) found, nothing to do."
    fi
}

start
