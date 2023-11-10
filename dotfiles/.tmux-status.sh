#!/bin/bash

CONKY=/usr/bin/conky

if [[ -x $CONKY ]]; then
    PID_FILE=/tmp/tmux.conky.pid
    DISP_FILE=/tmp/tmux.conky.txt

    if [ ! -f $PID_FILE ]; then
        CONF_FILE=/tmp/tmux.conky.conf
        cat <<\EOF > $CONF_FILE
conky.config = {
    background = false,
    out_to_console = true,
    out_to_x = false,
    override_utf8_locale = true,
    max_text_width = 0,
    own_window = false,
    update_interval = 1,
    short_units = true,
    if_up_strictness = address,
    use_spacer = right,
    override_utf8_locale = false,
    cpu_avg_samples = 2,
    temperature_unit = celsius,
    pad_percents = 2,
    console_graph_ticks = " ,_,▁,▂,▃,▄,▅,▆,▇,█"
}

conky.text =
[[ ${cpu cpu0}% ${acpitemp}℃   $memperc/$swapperc%  ${downspeedf eth0}  ${upspeedf eth0}]]
EOF
        cd /
        setsid sh -c "conky -c $CONF_FILE | while read DUMMY; do echo \$DUMMY > $DISP_FILE; done" >/dev/null 2>&1 </dev/null &
        echo $! > $PID_FILE
        sleep 0.1
    fi
    # echo -n "$(lsusb | grep '2207:320c' | sed 's,.*ID ,,')" ; cat $DISP_FILE
    cat $DISP_FILE
else
    echo " $(cat /proc/loadavg)"
fi
