# Deploy stack services and migrate website content (files, database) from Drupal 8 to 9
NOTE: THIS SCRIPT WILL OVERWRITE ~/.my.cnf IF IT EXISTS
1. Store environment variable to allow naming of project folder, image and stack services
```sh
export PROJECT=test
export PROJECT_TAG=1.0.0
export DOCKER_ACCOUNT=landscapedatacommons
export GIT_ACCOUNT=keramsey
```
>>>Note: Using above example where PROJECT=test then folder=swhub-test, service=drupal-test and image=drupal-test
2. Change directory
```sh
cd /opt/docker
```
3. Download github repo to a specified non-existant folder
```sh
git clone https://github.com/${GIT_ACCOUNT}/swhub-drupal.git swhub-${PROJECT}
```
4. Create .env file containing one line containing the mysql root user password (DO NOT SURROUND PASSWORD WITH QUOTES)
```sh
nano swhub-${PROJECT}/mysql/.secrets/.mysql_root
```
Note: Add single line containing the root database user password (without quotes) for use by separate phpmyadmin stack before saving .mysql_root file

5. Run script by modifying the following example (single command line) as needed -- enter SRC_USER password (source web server) when prompted
```sh
cd /opt/docker
SRC_DB=my_source_db_server SRC_PATH=/pathto/source/sites_folder SRC_USER=root SERVER=host_server_fqdn DOMAIN=website_fqdn MYSQL_VER=8.0.32 DRUPAL_VER=9.5.3 bash swhub-${PROJECT}/deploy-drupal.sh
```
Notes:
- PROJECT = abbreviated project name
- DOCKER_ACCOUNT = Docker Hub user account
- SRC_DB = source database host
- SRC_PATH = source sites path (without trailing slash) on source host (not necessarily database host)
- SRC_USER = user for authenticating to copy source files and folders
- PROJECT = project subdomain (e.g., dust if migrating dust.swclimatehub.info)
- SERVER = docker swarm node server (FQDN)
- DOMAIN = production website domain (FQDN)
- DRUPAL_VER = drupal version for drupal stack service (e.g., 9.5.3)
- PROJECT_TAG = desired tag for pushing image to Docker Hub