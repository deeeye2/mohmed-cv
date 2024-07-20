#!/bin/bash

FILE="app.py"

if [ "$1" == "exclude" ]; then
    echo "Excluding $FILE from tracking..."
    if [ -f "$FILE" ]; then
        echo $FILE >> .gitignore
        git rm --cached $FILE
        git add .gitignore
        git commit -m "Exclude $FILE from tracking"
        git push origin master
        echo "$FILE has been excluded from tracking and added to .gitignore."
    else
        echo "File $FILE does not exist. Skipping..."
    fi
elif [ "$1" == "include" ]; then
    echo "Including $FILE in tracking..."
    if [ -f "$FILE" ]; then
        sed "/$FILE/d" .gitignore > .gitignore.tmp && mv .gitignore.tmp .gitignore
        git add $FILE
        git add .gitignore
        git commit -m "Include $FILE in tracking"
        git push origin master
        echo "$FILE has been included in tracking and removed from .gitignore."
    else
        echo "File $FILE does not exist. Skipping..."
    fi
else
    echo "Usage: $0 {exclude|include}"
fi

