#!/bin/bash

# main reference
alias=RuneYoutube

### template - import default variables, functions
. /srv/http/addonstitle.sh

### template - function: start message, installed check
uninstallstart $@

# start custom script ------------------------------------------------------------------------------>>>

echo -e "$bar Remove youtube-dl..."
pacman -R --noconfirm youtube-dl

echo -e "$bar Remove web files..."
rm -v /srv/http/youtube.php
echo -e "$bar Remove shell scripts..."
rm -v /usr/local/bin/tube
rm -v /usr/local/bin/tubeplaylist
echo -e "$bar Patch files..."
file=/srv/http/app/templates/playback.php
echo $file
sed -i $'/<!-- RUNE_YOUTUBE_MOD -->/,/<!-- END_RUNE_YOUTUBE_MOD -->/ d' $file
file=/srv/http/assets/js/runeui.js
echo $file
	sed -i $'/\/\/RUNE_YOUTUBE_MOD/,/\/\/END_RUNE_YOUTUBE_MOD/ d' $file


echo -e "$bar Removing youtube directory.."
rm -r /mnt/MPD/LocalStorage/Youtube
# end custom script --------------------------------------------------------------------------------<<<

### template - function: remove version from database, finish message
uninstallfinish $@