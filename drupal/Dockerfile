FROM drupal:9-apache
#
# From official Docker Hub image of Drupal on Apache (default drupal:9-apache:latest)
#
# Install system packages
#  - mysql-client and zip are needed for drush to export database dumps using drush
RUN apt-get -y update \
  && apt-get -y install apt-utils
RUN apt-get -y update \
  && apt-get -y install zip \
  && apt-get -y install wget \
  && apt-get -y install git \
  && apt-get -y install default-mysql-client
# Copy script used to update drupal using composer
COPY /opt/docker/swhub-${PROJECT}/drupal/update-composer.sh /opt/drupal
# Copy script used to update drupal database using drush
COPY /opt/docker/swhub-${PROJECT}/drupal/update-drush.sh /opt/drupal
# Copy script used to fix drupal filesystem permissions
COPY /opt/docker/swhub-${PROJECT}/drupal/fix-permissions.sh /opt/drupal/web
# Copy site folder contents to sites/default
COPY /opt/docker/swhub-${PROJECT}/drupal/src/default/ /opt/drupal/web/sites/default
# Create libraries folder
RUN mkdir /opt/drupal/web/libraries
# Create private folders
RUN mkdir /opt/drupal/private
RUN mkdir /opt/drupal/private/config
RUN mkdir /opt/drupal/private/config/sync
RUN mkdir /opt/drupal/private/files
RUN mkdir /opt/drupal/private/temp
# Copy .htaccess files and private/files folder contents but not configuration or temp files
COPY /opt/docker/swhub-${PROJECT}/drupal/private/config/sync/.htaccess /opt/drupal/private/config/sync
COPY /opt/docker/swhub-${PROJECT}/drupal/private/temp/.htaccess /opt/drupal/private/temp
COPY /opt/docker/swhub-${PROJECT}/drupal/private/files/ /opt/drupal/private/files
# Set filesystem permissions for sites folder and contents
RUN sh /opt/drupal/web/fix-permissions.sh