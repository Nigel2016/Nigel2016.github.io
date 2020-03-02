#! /bin/bash

DIRECTORY="~/test_project_blue"
SOURCE="/mnt/c/users/123ch/Nigel2016.github.io/*"
DESTINATION="ndcharle@oncampus-course.engin.umich.edu"

while true; do
    sudo rsync -ruve ssh ${SOURCE} ${DESTINATION}:${DIRECTORY}
    sleep 10
done