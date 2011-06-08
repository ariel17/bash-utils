#!/bin/bash

BIN=/usr/bin

cd $BIN;

terminator -m -b --working-directory ~ &       # console
pidgin & skype &   # IM clients
clementine &       # music player
tsclient &         # windows remote desktop
transmission-gtk & # torrent
google-chrome &    # web browser
