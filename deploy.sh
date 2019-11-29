#!/bin/bash
#
# post-deploy.sh cloud hook
#
# This script will run after a code deploy on Magento 2,
# use it to run commands needed after a new code is deployed.
#
# Example commands:
#
#     magento maintenance:enable
#     magento setup:upgrade
#     magento setup:di:compile
#     magento setup:static-content:deploy --jobs 5
#     magento cache:clean
#     magento cache:flush
#     magento indexer:reindex
#     magento maintenance:disable

# The steps below are intended for PoC only and should be fixed in the future.

#if [[ "$CLOUD_ENVIRONMENT" == "stage" ]] || [[ "$CLOUD_ENVIRONMENT" == "prod" ]]; then
     echo "Stage Post Deploy Cloud Hook - Start"

     echo "Update pull master git repository from server"
     git pull origin master

     echo "Update Magento - Post Deploy Cloud Hook"
     bin/magento setup:upgrade
     bin/magento setup:di:compile


     echo "Delete static files from EBS - Post Deploy Cloud Hook"
     find ~/public_html/pub/static/ -type f -not -name ".htaccess" -not -name "deployed_version.txt" -delete
     rm -rf ~/public_html/pub/static/*
     rm -rf ~/public_html/var/view_preprocessed/*
     
     echo "Get theme information from Store microservice and deploy static content - Post Deploy Cloud Hook"
     bin/magento setup:static-content:deploy en_US --max-execution-time 7200 --jobs 15 --theme Magento/backend --theme Magento/luma

     echo "Reindex Magento - Post Deploy Cloud Hook"
     bin/magento indexer:reindex
     

     echo "Refresh Cache - Post Deploy Cloud Hook"
     bin/magento cache:clean
     bin/magento cache:flush

     echo "Configure Cron - Post Deploy Cloud Hook"
     bin/magento cron:install

     echo "Stage Post Deploy Cloud Hook - End"
#fi
