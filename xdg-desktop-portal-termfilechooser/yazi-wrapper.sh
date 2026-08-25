#!/usr/bin/env bash
set -x

set -e
export EDITOR=code
if [ "$6" -ge 4 ]; then
    set -x
fi

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

cmd="yazi"
termcmd="${TERMCMD:- kitty --class termfilechooser -o background_opacity=1.0}"


# Only --chooser-file is used: yazi writes it when `open` fires (Enter), and
# never on quit. --cwd-file is deliberately avoided, since yazi writes that on
# *every* normal exit, which would turn `q` into a selection.
chosen="$out".1
rm -f "$chosen"

if [ "$save" = "1" ]; then
    # save a file
    set -- --chooser-file="$chosen" "$path"
elif [ "$directory" = "1" ]; then
    # pick a directory: Enter chooses the hovered entry, l/-> descends into it
    set -- --chooser-file="$chosen" "$path"
elif [ "$multiple" = "1" ]; then
    # upload multiple files
    set -- --chooser-file="$chosen" "$path"
else
    # upload only 1 file
    set -- --chooser-file="$chosen" "$path"
fi

command="$termcmd $cmd"
for arg in "$@"; do
    # escape double quotes
    escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
    # escape special
    command="$command \"$escaped\""
done


# A killed terminal (Alt+F4) exits non-zero; that is a cancel, not an error.
sh -c "$command" || true

# No Enter pressed -> nothing was written -> leave "$out" empty so the portal
# reports a cancellation.
if [ -s "$chosen" ]; then
    if [ "$directory" = "1" ]; then
        # Enter on a file in directory mode: hand back its parent directory.
        # yazi writes the last entry without a trailing newline, hence the
        # `|| [ -n "$entry" ]` guard, and the separator is emitted up front to
        # keep the same shape on the way out.
        sep=""
        while IFS= read -r entry || [ -n "$entry" ]; do
            [ -n "$entry" ] || continue
            [ -d "$entry" ] || entry=$(dirname -- "$entry")
            printf '%s%s' "$sep" "$entry"
            sep="
"
        done < "$chosen" > "$out"
    else
        cat "$chosen" > "$out"
    fi
fi

rm -f "$chosen"
