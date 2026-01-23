#!/bin/sh
export XDG_DATA_DIRS="/run/current-system/sw/share:/etc/profiles/per-user/woolw/share:$HOME/.local/share"
exec anyrun "$@"
