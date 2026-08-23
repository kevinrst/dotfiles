if pgrep -f 'kitty.*--class=bluetoothui' > /dev/null; then
    pkill -f 'kitty.*--class=bluetoothui'
fi

if pgrep -f 'kitty.*--class=networkui' > /dev/null; then
    pkill -f 'kitty.*--class=networkui'
fi

if pgrep -f 'kitty.*--class=audioui' > /dev/null; then
    pkill -f 'kitty.*--class=audioui'
fi

if pgrep -f 'kitty.*--class=calendar' > /dev/null; then
    pkill -f 'kitty.*--class=calendar'
    exit
fi

kitty --class=calendar -e calcurse
