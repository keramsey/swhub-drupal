#!/bin/bash
# ***************************************************************************************
# Script to update and deploy Drupal 8 website to docker stack services on Drupal 9
# ***************************************************************************************
#
# Must pass this script variables in the command line used to run this script
#   - DO NOT USE TRAILING SLASHES IN SRC_PATH -
#
# Example command line (single line):
#   SERVICE_PORT=8070 DOCKER_ACCOUNT=landscapedatacommons SRC_DB=jornada-src SRC_PATH=/drupal/drupa-8.9.20/sites/default SRC_USER=username PROJECT=test SERVER=jornada-test.nmsu.edu DOMAIN=test.swclimatehub.info DRUPAL_VER=9.5.3 PROJECT_TAG=1.0.0 bash /opt/docker/deploy-drupal.sh
#
# Description of variables passed in command line used to run this script:
#   - SERVICE_PORT = loadbalancer port for traefik
#   - DOCKER_ACCOUNT = Docker Hub user account
#   - SRC_DB = source database host
#   - SRC_PATH = source sites path (without trailing slash) on source host (not necessarily database host)
#   - SRC_USER = user for authenticating to copy source files and folders
#   - PROJECT = project subdomain (e.g., dust if migrating dust.swclimatehub.info)
#   - SERVER = docker swarm node server (FQDN)
#   - DOMAIN = production website domain (FQDN)
#   - DRUPAL_VER = drupal version for drupal stack service (e.g., 9.5.3)
#   - PROJECT_TAG = desired tag for pushing image to Docker Hub
#
# Build testing URL using host server instead of production URL
PROJECT_URL=${PROJECT}.${SERVER}

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
scp -r $SRC_USER@$SRC_DB:$SRC_PATH/* /opt/docker/swhub-$PROJECT/src/site/default/

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
trusted_host_patterns="\$settings\['trusted_host_patterns'\]\ \=\ \[\n"
trusted_host_patterns+="\ \ '\^${DOMAIN//./\\\\\\.}\$',\n"
trusted_host_patterns+="\ \ '\^${PROJECT}\\\.${SERVER//./\\\\\\.}\$',\n"
trusted_host_patterns+="\];"

# Within settings.php add 2nd TRUSTED_HOST array member
# 1st TRUSTED_HOST: '^test\.swclimatehub\.info$',
# 2nd TRUSTED_HOST: '^test\.jornada-swhub\.nmsu\.edu$',

# The sed command is intentionally split with a hard line return for multiline output
sed -i "/\ \*\ @see\ https:\/\/www\.drupal\.org\/docs\/installing-drupal\/trusted-host-settings/{N;a ${trusted_host_patterns}
}" /opt/docker/swhub-$PROJECT/src/site/default/default.settings.php

# Delete and replace D7 settings.php file
rm -f /opt/docker/swhub-$PROJECT/src/site/default/settings.php
mv /opt/docker/swhub-$PROJECT/src/site/default/default.settings.php /opt/docker/swhub-$PROJECT/src/site/default/settings.php

# Rename docker-compose.yml file
mv /opt/docker/swhub-$PROJECT/swhub-drupal.yml /opt/docker/swhub-$PROJECT/swhub-$PROJECT.yml

# Update renamed docker-compose.yml file using PROJECT
sed -i "s/test/${PROJECT}/g" /opt/docker/swhub-$PROJECT/swhub-$PROJECT.yml
sed -i "s/:9\.5\.3-php8\.1-apache/-${PROJECT}:${PROJECT_TAG}/" /opt/docker/swhub-$PROJECT/swhub-$PROJECT.yml
#sed -i "s/loadbalancer\.server\.port=80/loadbalancer.server.port=${SERVICE_PORT}/" /opt/docker/swhub-$PROJECT/swhub-$PROJECT.yml

# Create .secrets/.env file for configuring mysql container
echo "MYSQL_DATABASE="${database//\'} >> /opt/docker/swhub-$PROJECT/.secrets/.env
echo "MYSQL_USER="${username//\'} >> /opt/docker/swhub-$PROJECT/.secrets/.env
echo "MYSQL_PASSWORD="${password//\'} >> /opt/docker/swhub-$PROJECT/.secrets/.env

# Update Dockerfile
sed -i "s/9-apache/${DRUPAL_VER}-apache/g" /opt/docker/swhub-$PROJECT/drupal/Dockerfile

# Build config file variable using bash variable substitution
my="[client${PROJECT}]\n"
my+="user=$(echo ${username//\'})\n"
my+="password=$(echo ${password//\'})\n"
my+="host=$(echo ${SRC_DB//\'})\n"
my+="port=$(echo ${port//\'})"
my+="\n"

# Create or overwrite database config file in user's home directory to allow dumping of source database
echo -e $my > ~/.my.cnf

# Backup website (Drupal 8) database (~/.my.cnf must exist and contain login credentials)
mysqldump --defaults-group-suffix=${PROJECT} --column-statistics=0 ${database//\'}| gzip > /opt/docker/swhub-${PROJECT}/src/mysql/site-db.sql.gz

# Create docker volumes
docker volume create ${PROJECT}-drupal
docker volume create ${PROJECT}-drupal-data
docker volume create ${PROJECT}-mysql-data

# Create docker network
docker network create --driver=overlay ${PROJECT}-net

# Change directory
cd /opt/docker/swhub-${PROJECT}

# Build image
docker-compose -f swhub-${PROJECT}.yml build --no-cache --force-rm
docker login
docker push ${DOCKER_ACCOUNT}/swhub-drupal-${PROJECT}:${PROJECT_TAG}

# Deploy stack
# NOTE: docker network must exist (network create --driver=overlay --attachable shiny-net)
DOMAIN=${DOMAIN} PORT=${SERVICE_PORT} docker stack deploy -c swhub-${PROJECT}.yml swhub-${PROJECT}

# Pause script processing to allow stack services to come up completely
echo "Waiting 120 seconds for stack services to come up completely before proceeding"
sleep 120
# Run update-drush.sh to complete Drupal setup within container (stack service)
docker service swhub-${PROJECT}_drupal-${PROJECT}

# Change to original directory
cd $ORIGINAL_DIR