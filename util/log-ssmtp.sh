#!/bin/sh
set -e
LOGFILE="/tmp/ssmtp-$(date +%Y%m%d-%H%M%S-$$)"
echo "$0 $@" > "$LOGFILE"
# tee -a "$LOGFILE" | ssmtp.real "$@"
tee -a "$LOGFILE"