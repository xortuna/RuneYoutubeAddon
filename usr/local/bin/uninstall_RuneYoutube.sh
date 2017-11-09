#!/bin/bash

# main reference
alias=RuneYoutube

### template - import default variables, functions
. /srv/http/addonstitle.sh

### template - function: start message, installed check
uninstallstart $@

# start custom script ------------------------------------------------------------------------------>>>

echo -e "$bar Remove youtube-dl ..."
pacman -R --noconfirm youtube-dl

echo -e "$bar Remove php script ..."
rm -v /srv/http/youtube.php
echo -e "$bar Remove shell youtube script ..."
rm -v /usr/local/bin/tube
echo -e "$bar Remove shell playlist script ..."
rm -v /usr/local/bin/tubeplaylist
echo -e "$bar Restore files ..."
file=/srv/http/app/templates/playback.php
echo $file
sed -i -e $'/<button id="pl-import-youtube" class="btn btn-default" type="button" title="Import a playlist or video from youtube." data-toggle="modal" data-target="#modal-pl-youtube"><i class="fa fa-youtube-play"><\/i><\/button>/ d\
' -e $'/<div id="modal-pl-youtube" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="modal-pl-youtube-label" aria-hidden="true">\
    <div class="modal-dialog">\
        <div class="modal-content">\
            <div class="modal-header">\
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;<\/button>\
                <h3 class="modal-title" id="modal-pl-youtube-label">Import from youtube<\/h3>\
            <\/div>\
            <div class="modal-body">\
                <label for="pl-video-url">Enter a video or playlist url<\/label>\
                <input id="pl-video-url" class="form-control osk-trigger" type="text" placeholder="Enter url">\
            <\/div>\
            <div class="modal-footer">\
                <button type="button" class="btn btn-default btn-lg" data-dismiss="modal">Close<\/button>\
                <button type="button" id="modal-pl-youtube-btn" class="btn btn-primary btn-lg" data-dismiss="modal">Import<\/button>\
            <\/div>\
        <\/div>\
    <\/div>\
<\/div>/ d' $file

echo -e "$bar Modify files ..."
file=/srv/http/assets/js/runeui.js
echo $file
	sed -i $'/\/\/ save youtube to playlist\
        $(\'#modal-pl-youtube-btn\').click(function(){\
            var playlistname = $(\'#pl-video-url\').val();\
            if (playlistname != null) {\
             var encstream = encodeURI(playlistname);  \/\/url encode\
             encstream = encodeURIComponent(encstream); \/\/encodes also ? & ... chars\
             $.get("youtube.php?url=" + encstream);\
        }\
        });/ d' $file
		

echo -e "$bar Removing youtube directory ..."
rm -r /mnt/MPD/LocalStorage/Youtube
# end custom script --------------------------------------------------------------------------------<<<

### template - function: remove version from database, finish message
uninstallfinish $@