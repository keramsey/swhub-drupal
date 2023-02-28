#!/bin/bash
# ***************************************************************************************
# Script to update and deploy Drupal 8 website to docker stack services on Drupal 9
# ***************************************************************************************
#
# Must include prefixes (~ARGUMENTS) in command line calling this script
#   e.g., 'PROJECT=test SERVER=jornada-test.nmsu.edu DOMAIN=test.swclimatehub.info DRUPAL_VER=9.5.3 PROJECT_TAG=1.0.0 bash /opt/docker/deploy-drupal.sh'
#
PROJECT_URL=${PROJECT}.${SERVER}

#
# NEED TO DYNAMICALLY CREATE ~/.my.cnf using database-settings array
#

#
# NEED TO ADD MORE VARIABLES TO FULLY AUTOMATE MODIFICATION OF docker-compose.yml
#

#
# NEED TO ADD MORE VARIABLES TO FULLY AUTOMATE MODIFICATION OF Dockerfile
#

#
# NEED TO ADD MORE VARIABLES TO FULLY AUTOMATE SCRIPT USING 'ARGUMENTS' (e.g., scp and mysqldump info)
#

#
# NEED TO AUTOMATICALLY INSERT BACKSLASHES USING $PROJECT, $SERVER AND $DOMAIN USING SED
#
# USE $DOMAIN FOR PRI_DOMAIN_PATTERN AND USE $PROJECT.$SERVER FOR SEC_DOMAIN_PATTERN
#PRI_DOMAIN_PATTERN=test\.swclimatehub\.info
PRI_DOMAIN_PATTERN=${DOMAIN//./\\.}
SEC_DOMAIN_PATTERN=test\.jornada-swhub\.nmsu\.edu
#SEC_DOMAIN_PATTERN=$PROJECT\\\.${SERVER//./\\.}

# Store current working directory
ORIGINAL_DIR=$(pwd)

# Create project directory
mkdir /opt/docker/swhub-$PROJECT

# Change directory
cd /opt/docker

# Download drupal
wget https://ftp.drupal.org/files/projects/drupal-$DRUPAL_VER.tar.gz
# Extract default.settings.php from drupal version download
tar -xzf drupal-$DRUPAL_VER.tar.gz drupal-$DRUPAL_VER/sites/default/default.settings.php --strip-components=3
# Move default.settings.php
mv default.settings.php /opt/docker/swhub-$PROJECT/src/site/default/default.settings.php
# Cleanup download file
rm -f drupal-$DRUPAL_VER.tar.gz
# Copy website site folder
scp -r root@jornada-climhub:/drupal8/drupal-8.9.20/sites/dust.swclimatehub.info/* /opt/docker/swhub-$PROJECT/src/site/default/
# Backup website (Drupal 8) database (~/.my.cnf must exist and contain login credentials)
mysqldump --column-statistics=0 -h jornada-climhub dustswclimatehub | gzip > /opt/docker/swhub-$PROJECT/src/mysql/site-db.sql.gz
# Store database setting values
cd /opt/docker/swhub-$PROJECT/src/site/default
while IFS=' = ' read -r var val
do
  if [[ "${var}" == *"database"* ]]
  then
    database=${val:2}
    database=${database::-1}
  fi
  if [[ "${var}" == *"username"* ]]
  then
    username=${val:2}
    username=${username::-1}
  fi
  if [[ "${var}" == *"password"* ]]
  then
    password=${val:2}
    password=${password::-1}
  fi
  if [[ "${var}" == *"host"* ]]
  then
    host="'localhost'"
  fi
  if [[ "${var}" == *"port"* ]]
  then
    port=${val:2}
    port=${port::-1}
  fi
  if [[ "${var}" == *"driver"* ]]
  then
    driver=${val:2}
    driver=${driver::-1}
  fi
  if [[ "${var}" == *"prefix"* ]]
  then
    prefix=${val:2}
    if [ -z "$prefix" ]
    then
      # variable is null so assign to empty string
      prefix=''
    else
      # variable is set, trim trailing character
      prefix=${prefix::-1}
    fi
  fi
  if [[ "${var}" == *"collation"* ]]
  then
    collation=${val:2}
    collation=${collation::-1}
  fi
  if [[ "${var}" == *"hash_salt"* ]]
  then
    hash_salt=${val}
    hash_salt=${hash_salt::-1}
  fi
done < settings.php
# Build database settings string
database_settings="\$databases\[\];\n\$databases\[\'default\'\]\[\'default\'\]\ \=\ \[\n\ \ \'database\'\ \=\>\ ${database}\,\n"
database_settings+="\ \ \'username\'\ \=>\ ${username}\,\n"
database_settings+="\ \ \'password\'\ \=>\ ${password}\,\n"
database_settings+="\ \ \'host\'\ \=>\ ${host}\,\n"
database_settings+="\ \ \'port\'\ \=>\ ${port}\,\n"
database_settings+="\ \ \'driver\'\ \=>\ ${driver}\,\n"
if [ -z "${prefix}" ]
  then
    # prefix is not assigned
    database_settings+="\ \ \'prefix\'\ \=>\ ''\,\n"
  else
    # prefix is assigned
    database_settings+="\ \ \'prefix\'\ \=>\ ${prefix}\,\n"
fi
database_settings+="\ \ \'collation\'\ \=>\ ${collation}\,\n"
database_settings+="\];"
# Update database settings in D9 default.settings.php file
sed -i "s/\$databases = \[\];/${database_settings}/" /opt/docker/swhub-$PROJECT/src/site/default/default.settings.php
sed -i "s/# \$settings\['config_sync_directory'\]\ \=\ '\/directory\/outside\/webroot';/\$settings\['config_sync_directory'\]\ \=\ '\/opt\/drupal\/private\/config\/sync'\;/" /opt/docker/swhub-$PROJECT/src/site/default/default.settings.php
sed -i "s/\$settings\['hash_salt'\]\ \=\ '';/\$settings\['hash_salt'\]\ \=\ ${hash_salt}\;/" /opt/docker/swhub-$PROJECT/src/site/default/default.settings.php
sed -i "s/# \$settings\['file_private_path'\]\ \=\ '';/\$settings\['file_private_path'\]\ \=\ '\/opt\/drupal\/private\/files'\;/" /opt/docker/swhub-$PROJECT/src/site/default/default.settings.php
sed -i "s/# \$settings\['file_temp_path'\]\ \=\ '\/tmp';/\$settings\['file_temp_path'\]\ \=\ '\/opt\/drupal\/private\/temp'\;/" /opt/docker/swhub-$PROJECT/src/site/default/default.settings.php
# Build replace string
#trusted_host_patterns="\$settings\['trusted_host_patterns'\]\ \=\ \[\n"
#trusted_host_patterns+="\ \ '\^${PRI_DOMAIN_PATTERN}\$',\n"
#trusted_host_patterns+="\ \ '\^${SEC_DOMAIN_PATTERN}\$',\n"
#trusted_host_patterns+="\];"
trusted_host_patterns="\$settings\['trusted_host_patterns'\]\ \=\ \[\n"
trusted_host_patterns+="\ \ '\^${PRI_DOMAIN_PATTERN}\$',\n"
trusted_host_patterns+="\ \ '\^${SEC_DOMAIN_PATTERN}\$',\n"
trusted_host_patterns+="\];"
# Within settings.php add 2nd TRUSTED_HOST array member
# 1st TRUSTED_HOST: '^test\.swclimatehub\.info$',
# 2nd TRUSTED_HOST: '^test\.jornada-swhub\.nmsu\.edu$',
# The sed command is intentionally split with a newline
sed -i "/\ \*\ @see\ https:\/\/www\.drupal\.org\/docs\/installing-drupal\/trusted-host-settings/{N;a ${trusted_host_patterns}
}" /opt/docker/swhub-$PROJECT/src/site/default/default.settings.php
# Delete and replace D7 settings.php file
rm -f /opt/docker/swhub-$PROJECT/src/site/default/settings.php
mv /opt/docker/swhub-$PROJECT/src/site/default/default.settings.php /opt/docker/swhub-$PROJECT/src/site/default/settings.php
# Rename docker-compose.yml file
mv /opt/docker/swhub-$PROJECT/swhub-drupal.yml /opt/docker/swhub-$PROJECT/swhub-$PROJECT.yml
# Search and replace within docker-compose.yml file using PROJECT
sed -i "s/test/${PROJECT}/g" /opt/docker/swhub-$PROJECT/swhub-$PROJECT.yml
# Create .secrets/.env file for configuring mysql container
echo "MYSQL_DATABASE="$database >> /opt/docker/swhub-$PROJECT/.secrets/.env
echo "MYSQL_USERNAME="$username >> /opt/docker/swhub-$PROJECT/.secrets/.env
echo "MYSQL_PASSWORD="$password >> /opt/docker/swhub-$PROJECT/.secrets/.env
# Change directory
cd /opt/docker/swhub-$PROJECT
# Create docker volumes
docker volume create $PROJECT-drupal
docker volume create $PROJECT-drupal-data
docker volume create $PROJECT-mysql-data
# Create docker network
docker network create --driver=overlay $PROJECT-net

#
# NEED TO INTEGRATE WITH Dockerfile
#

# Build image
#docker build --no-cache -t landscapedatacommons/swhub-$PROJECT:$PROJECT_TAG .
docker login
#docker push landscapedatacommons/swhub-$PROJECT:$PROJECT_TAG
# NOTE: docker network must exist (network create --driver=overlay --attachable shiny-net)
# Deploy stack
#DOMAIN=$dust.swclimatehub.info PORT=8070 docker stack deploy -c swhub-$PROJECT.yml swhub-$PROJECT

# Change to original directory
cd $ORIGINAL_DIR