#!/usr/bin/env bash
set -x

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
termcmd="${TERMCMD:- kitty --class float -o background_opacity=1.0}"

chosen="$out".1
rm -f "$chosen"

if [ "$save" = "1" ]; then
    set -- --chooser-file="$chosen" "$path"
elif [ "$directory" = "1" ]; then
    set -- --chooser-file="$chosen" "$path"
elif [ "$multiple" = "1" ]; then
    set -- --chooser-file="$chosen" "$path"
else
    set -- --chooser-file="$chosen" "$path"
fi

command="$termcmd $cmd"
for arg in "$@"; do
    escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
    command="$command \"$escaped\""
done


sh -c "$command" || true

if [ -s "$chosen" ]; then
    if [ "$directory" = "1" ]; then
        sep=""
        while IFS= read -r entry || [ -n "$entry" ]; do
            [ -n "$entry" ] || continue
            [ -d "$entry" ] || entry=$(dirname -- "$entry")
            printf '%s%s' "$sep" "$entry"
            sep=""
        done < "$chosen" > "$out"
    else
        cat "$chosen" > "$out"
    fi
fi

rm -f "$chosen"
