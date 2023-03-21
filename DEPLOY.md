# Deploy stack services and migrate website content (files, database) from Drupal 8 to 9
NOTE: THIS SCRIPT WILL OVERWRITE ~/.my.cnf IF IT EXISTS
1. Store environment variable to allow naming of project folder, image and stack services
```sh
export PROJECT=test
```
>>>Note: Using above example where PROJECT=test then folder=swhub-test, service=drupal-test and image=drupal-test
2. Change directory
```sh
cd /opt/docker
```
3. Download github repo to a specified non-existant folder
```sh
git clone https://github.com/keramsey/swhub-drupal.git swhub-$PROJECT
```
4. Create .env file containing one line containing the mysql root user password (DO NOT SURROUND PASSWORD WITH QUOTES)
```sh
nano swhub-$PROJECT/.secrets/.env
```
Note: Add one line  "MYSQL_ROOT_PASSWORD='<password>'" (without double quotes), substituting <password> with desired password used by a separate phpmyadmin stack
5. Run script by modifying the following example (single command line) as needed
```sh
DOCKER_ACCOUNT=my_account SRC_DB=my_source_db_server SRC_PATH=/pathto/sites_folder SRC_USER=root SERVER=host_server_fqdn DOMAIN=website_fqdn DRUPAL_VER=9.5.3 PROJECT_TAG=1.0.0 bash swhub-$PROJECT/src/deploy-drupal.sh
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
6. Provide server's user password (source web server) to copy files and folders