#!/bin/bash

# main reference
alias=RuneYoutube

### template - import default variables, functions
. /srv/http/addonstitle.sh

### template - function: start message, installed check
installstart $@

### template - function: free space check (needed kb for install)
checkspace 5000

### template - function: get repository zip and extract to system directories
getinstallzip

### template - function: (optional) rank miror servers and 'pacman -Sy' before install packages
rankmirrors

### PACMAN ### }
echo -e "$bar youtube-dl package ..."
pacman -S --noconfirm youtube-dl

### PHP Script ###}
echo -e "$bar youtube php script..."
echo '<?php
try {
   set_time_limit(0);
   ini_set('max_execution_time', 600);
    $u = urldecode($_GET['url']); 
    #validate
    $youtube = "/^(https:\/\/|http:\/\/|)(www\.|m\.|)(youtube\.com\/watch\?v=|youtu\.be\/)[\w-]+$/"; 
    $playlist ="/^(https:\/\/|http:\/\/|)(www\.|m\.|)(youtube\.com\/playlist\?list=|youtu\.be\/)[\w-]+$/";
   
    if ( preg_match ($youtube, $u ) )
    {
      exec("tube " . $u );
      echo "sent song" . $u;
   }
    if(preg_match($playlist, $u))
   {
      exec("tubeplaylist " . $u . " >/dev/null 2>&1 &");
      echo "sent playlist" . $u;
   }
}    
catch (Exception $e) {
    echo "Exception :  ", $e->getMessage(),"<br />";

}
?>' >> /srv/http/youtube.php

### Tube ###
echo -e "$bar youtube bash script..."
echo $'#!/bin/bash
youtube-dl --no-mtime --restrict-filenames -o \'/mnt/MPD/LocalStorage/Youtube/%(title)s.%(ext)s\' --write-description -f "bestaudio[ext=m4a]" $1 && mpc update --wait LocalStorage/Youtube && VV=$(ls /mnt/MPD/LocalStorage/Youtube/*.description -t | head -n1) && VV=$(basename $VV .description) && mpc add "LocalStorage/Youtube/$VV.m4a" && echo $VV && chown -R http:http /mnt/MPD/LocalStorage/Youtube/$VV.*' >> /usr/local/bin/tube
### Tube playlist ###
echo -e "$bar youtube playlist script..."
echo $'#!/bin/bash
youtube-dl --no-mtime --restrict-filenames --ignore-errors -o \'/mnt/MPD/LocalStorage/Youtube/%(title)s.%(ext)s\' --write-description -f "bestaudio[ext=m4a]" $1 && mpc update --wait LocalStorage/Youtube

(IFS=\'
\'
for x in $(find /mnt/MPD/LocalStorage/Youtube/ -type f -name *.description -mmin -15); do VV=$(basename "$x" .description) && mpc add "LocalStorage/Youtube/$VV.m4a" && echo $VV; done)
#Find all descriptions less than 15 min modifcation time then add to playlist' >> /usr/local/bin/tubeplaylist


echo -e "$bar Modify files ..."
file=/srv/http/app/templates/playback.php
echo $file
	sed -i -e $'/<button id="pl-manage-save" class="btn btn-default" type="button" title="Save current queue as playlist" data-toggle="modal" data-target="#modal-pl-save"><i class="fa fa-save"><\/i><\/button>/ a\
			<button id="pl-import-youtube" class="btn btn-default" type="button" title="Import a playlist or video from youtube." data-toggle="modal" data-target="#modal-pl-youtube"><i class="fa fa-youtube-play"></i></button>'
-e $'/<div id="modal-pl-save" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="modal-pl-save-label" aria-hidden="true">/ i\
<div id="modal-pl-youtube" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="modal-pl-youtube-label" aria-hidden="true">\
    <div class="modal-dialog">\
        <div class="modal-content">\
            <div class="modal-header">\
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>\
                <h3 class="modal-title" id="modal-pl-youtube-label">Import from youtube</h3>\
            </div>\
            <div class="modal-body">\
                <label for="pl-video-url">Enter a video or playlist url</label>\
                <input id="pl-video-url" class="form-control osk-trigger" type="text" placeholder="Enter url">\
            </div>\
            <div class="modal-footer">\
                <button type="button" class="btn btn-default btn-lg" data-dismiss="modal">Close</button>\
                <button type="button" id="modal-pl-youtube-btn" class="btn btn-primary btn-lg" data-dismiss="modal">Import</button>\
            </div>\
        </div>\
    </div>\
</div>'
	$file

echo -e "$bar Modify files ..."
file=/srv/http/assets/js/runeui.js
echo $file
	sed -i $'/sort queue entries/ i\
         // save youtube to playlist\
        $('#modal-pl-youtube-btn').click(function(){\
            var playlistname = $('#pl-video-url').val();\
            if (playlistname != null) {\
             var encstream = encodeURI(playlistname);  //url encode\
             encstream = encodeURIComponent(encstream); //encodes also ? & ... chars\
             $.get("youtube.php?url=" + encstream);\
        }\
        });' $file
			
			
echo -e "$bar Masking youtube directory ..."
mkdir /mnt/MPD/LocalStorage/Youtube
echo -e "$bar Setting permissions..."
chmod 777 /usr/local/bin/tube
chmod 777 /usr/local/bin/tubeplaylist
chmod 777 /srv/http/youtube.php

chown http:http /srv/http/youtube.php
chown http:http /usr/local/bin/tube
chown http:http /usr/local/bin/tubeplaylist
chown http:http /mnt/MPD/LocalStorage/Youtube

# end custom script --------------------------------------------------------------------------------<<<

### template - function: save version to database, finish message
installfinish $@

# extra info if any
title -nt "extra info"