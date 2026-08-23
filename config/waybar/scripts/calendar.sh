if pgrep -f 'blueman-manager' > /dev/null; then
    pkill -f 'blueman-manager'
fi

if pgrep -f 'kitty.*--class=networkui' > /dev/null; then
    pkill -f 'kitty.*--class=networkui'
fi

if pgrep -f 'pavucontrol' > /dev/null; then
    pkill -f 'pavucontrol'
fi

if pgrep -f 'kitty.*--class=calendar' > /dev/null; then
    pkill -f 'kitty.*--class=calendar'
    exit
fi

kitty --class=calendar -e calcurse
