#!/bin/sh

PID_FILE=/tmp/tmux.conky.pid
DISP_FILE=/tmp/tmux.conky.txt

if [ ! -f $PID_FILE ]; then
    cd /
    setsid sh -c "conky -c ~/.tmux.conky.conf | while read DUMMY; do echo \$DUMMY > $DISP_FILE; done" >/dev/null 2>&1 </dev/null &
    echo $! > $PID_FILE
    sleep 0.5
fi
cat $DISP_FILE
