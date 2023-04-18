The swhub-drupal repo contains the scaffolding (scripts, files, folder structure) used to migrate (Drupal 8 to 9), build and deploy an existing drupal website and database to Docker Swarm stack services
## Folder structure:
* drupal
   * private
      * config
         * sync
            * .htaccess
      *  files
            * .htaccess
      *  temp
            * .htaccess
   * src
      * site
         * default
            * .gitignore
   * Dockerfile
   * fix-permissions.sh
   * update-composer.sh
   * update-drush.sh
* mysql
   * .secrets
      * .gitignore
   * src
      * .gitignore
   * Dockerfile
* deploy-drupal.sh
* DEPLOY.md
* docker-stack.yml
* README.md

The .gitignore files ensure folder contents are never published to github. The .gitignore file is the only file in folder published to github

## Deploy stack services instructions: 
see DEPLOY.md

## Bash script that migrates, builds and deploys stack services: 
deploy-drupal.sh (see command line example at top of script or bottom of DEPLOY.md)


