#!/bin/bash
# Sleeps for argument number of seconds.
SLEEP_TIME="$1"
# SLEEP_TIME=3
: ${SLEEP_TIME:?Missing SLEEP_TIME integer}
sleep "$SLEEP_TIME"
echo "sleep time is over"
