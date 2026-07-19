#!/usr/bin/env bash
set -x
exec >/tmp/yazi-wrapper.log 2>&1

set -e

if [ "$6" -ge 4 ]; then
    set -x
fi

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

cmd="yazi"
termcmd="${TERMCMD:- kitty --title termfilechooser -o background_opacity=1.0}"


if [ "$save" = "1" ]; then
    # save a file
    set -- --chooser-file="$out" "$path"
elif [ "$directory" = "1" ]; then
    set -- --cwd-file="$out" "$path"
elif [ "$multiple" = "1" ]; then
    # upload multiple files
Requisite=graphical-session.target
After=graphical-session.target
    set -- --chooser-file="$out" "$path"
else
    # upload only 1 file
    set -- --chooser-file="$out" "$path"
fi

command="$termcmd $cmd"
for arg in "$@"; do
    # escape double quotes
    escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
    # escape special
    command="$command \"$escaped\""
done


sh -c "$command"



if [ "$directory" = "1" ]; then
    if [ ! -s "$out" ] && [ -s "$out"".1" ]; then
        cat "$out"".1" > "$out"
        rm "$out"".1"
    else
        rm "$out"".1"
    fi
fi
