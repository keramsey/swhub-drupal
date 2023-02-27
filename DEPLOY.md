# Deploy stack services and migrate website content (files, database) from Drupal 8 to 9
1. Store environment variable to allow naming of project folder, image and stack services
```sh
export PROJECT=test
```
>>>Note: Using above example where PROJECT=test then folder=swhub-test, service=drupal-test and image=drupal-test
1. Download github repo to a specified non-existant folder
```sh
git clone https://github.com/keramsey/swhub-drupal.git swhub-$PROJECT
```
2. Run script by modifying the following example (single command line) as needed
```sh
SERVER=jornada-test.nmsu.edu DOMAIN=test.swclimatehub.info DRUPAL_VER=9.5.3 PROJECT_TAG=1.0.0 bash swhub-$PROJECT/src/deploy-drupal.sh
```
Notes:
- SERVER = docker swarm server domain name (FQDN)
- DOMAIN = desired website URL
- DRUPAL_VER = desired drupal version after upgrade (e.g., 9.5.3)
- PROJECT_TAG = desired image tag when pushing to Docker Hub (e.g., 1.0.0)
- PROJECT = used to name folder, image and stack drupal service (including network and volumes)
3. Provide root user password to copy source website files and folders
