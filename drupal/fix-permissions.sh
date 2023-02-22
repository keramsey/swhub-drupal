#!/bin/sh
# Setup filesystem permissions for drupal to run
#
# MUST BE RUN FROM DRUPAL ROOT FOLDER (/opt/drupal/web)
#
# Script made by David Rush, davidprush@gmail.com
# Changes the permissions of the Drupal sites directory to secure after isntallation
# Very Important Put this script in the same directory as your site/ directory
# You are free to distribute, change, delete, or whatever the hell you want with this script
# see @https://www.drupal.org/node/244924#comment-6600078 for original script
echo "Start fixing permissions..."
# Save current working directory to variable
DIR=$(pwd)
# Change directory to web folder
WEB="/opt/drupal/web"
cd ${WEB}
# Declare file/folder paths and variables
SITE="default"
SITES="sites/${SITE}"
#DEFAULT="sites/${SITE}"
SETTINGS="${SITES}/settings.php"
FILES="${SITES}/files"
FHTACCESS="${SITES}/files/.htaccess"
LIBRARIES="libraries"
THEMES="themes"
MODULES="modules"
PRIVATE="../private"
OLD_PRIVATE="sites/default/private"
PCSHTACCESS="${PRIVATE}/config/sync/.htaccess"
PFHTACCESS="${PRIVATE}/files/.htaccess"
PTHTACCESS="${PRIVATE}/temp/.htaccess"
BACKUP="/var/mysql/backups"
# Declare binary file paths
CHOWN="/bin/chown"
CHMOD="/bin/chmod"
FIND="/usr/bin/find"
# Change owner recursively
$CHOWN -R www-data:www-data ${LIBRARIES}
$CHOWN -R www-data:www-data ${MODULES}
$CHOWN -R www-data:www-data ${THEMES}
$CHOWN -R www-data:www-data ${SITES}
$CHOWN -R root:www-data ${PRIVATE}
# Change ownership if folder exists
if [ -d "$BACKUP" ]; then
$CHOWN -R root:root ${BACKUP}
fi
# Remove old private folder if it exists
if [ -d "$OLD_PRIVATE" ]; then
  rm -rf $OLD_PRIVATE
fi
# Change permissions to secure sites folder and its contents
# ${LIBRARIES} folders=755, files=644
$FIND ${LIBRARIES} -type d -exec $CHMOD u=rwx,g=rx,o=rx {} \;
$FIND ${LIBRARIES} -type f -exec $CHMOD u=rw,g=r,o=r {} \;
# ${MODULES} folders=755, files=644
$FIND ${MODULES} -type d -exec $CHMOD u=rwx,g=rx,o=rx {} \;
$FIND ${MODULES} -type f -exec $CHMOD u=rw,g=r,o=r {} \;
# ${THEMES} folders=755, files=644
$FIND ${THEMES} -type d -exec $CHMOD u=rwx,g=rx,o=rx {} \;
$FIND ${THEMES} -type f -exec $CHMOD u=rw,g=r,o=r {} \;
# ${SITES} folders=755, files=644, .htaccess=444, settings.php=444
$FIND ${SITES} -type d -exec $CHMOD u=rwx,g=rx,o=rx {} \;
$FIND ${SITES} -type f -exec $CHMOD u=rw,g=r,o=r {} \;
$FIND ${SITES} -name .htaccess -exec $CHMOD u=r,g=r,o=r {} \;
$FIND ${SITES} -name settings.php -exec $CHMOD u=r,g=r,o=r {} \;
# ${FILES} folders=775, files=664 plus .htaccess=444 from ${SITES}
$FIND ${FILES} -type d -exec $CHMOD u=rwx,g=rwx,o=rx {} \;
$FIND ${FILES} -type f -exec $CHMOD u=rw,g=rw,o=r {} \;
# ${PRIVATE} folders=770, files=660, .htaccess=440
$FIND ${PRIVATE} -type d -exec $CHMOD u=rwx,g=rwx,o-rwx {} \;
$FIND ${PRIVATE} -type f -exec $CHMOD u=rw,g=rw,o-rwx {} \;
$FIND ${PRIVATE} -name .htaccess -exec $CHMOD u=r,g=r,o-rwx {} \;
# ${PRIVATE}/config folders=770, files=660, .htaccess=440
$FIND ${PRIVATE}/config -type d -exec $CHMOD u=rwx,g=rwx,o-rwx {} \;
$FIND ${PRIVATE}/config -type f -exec $CHMOD u=rw,g=rw,o-rwx {} \;
$FIND ${PRIVATE}/config -name .htaccess -exec $CHMOD u=r,g=r,o-rwx {} \;
# Change directory to previous state
cd ${DIR}
echo "Done fixing permissions, verify all permissions are correct!"
# script done