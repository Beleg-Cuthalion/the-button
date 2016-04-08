#!/bin/sh
while true; do
    read -p "WARNING: You are about to deploy the production version! Are you sure? yes/no: " yn
    case $yn in
        yes ) ./deploy 7619570ijzhsajs; break;;
        * ) echo "Aborting..."; exit;;
    esac
done
