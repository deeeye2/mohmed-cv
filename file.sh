#!/bin/bash

FILES=("app.py" ".env")

if [ "$1" == "exclude" ]; then
    echo "Excluding files from tracking..."
    for FILE in "${FILES[@]}"; do
        if [ -f "$FILE" ]; then
            echo $FILE >> .gitignore
            git rm --cached $FILE
        else
            echo "File $FILE does not exist. Skipping..."
        fi
    done
    git add .gitignore
    git commit -m "Exclude files from tracking"
    git push origin master
    echo "Files have been excluded from tracking and added to .gitignore."
elif [ "$1" == "include" ]; then
    echo "Including files in tracking..."
    for FILE in "${FILES[@]}"; do
        if [ -f "$FILE" ]; then
            # Use a temporary file for the updated .gitignore
            sed "/$FILE/d" .gitignore > .gitignore.tmp && mv .gitignore.tmp .gitignore
            git add $FILE
        else
            echo "File $FILE does not exist. Skipping..."
        fi
    done
    git add .gitignore
    git commit -m "Include files in tracking"
    git push origin master
    echo "Files have been included in tracking and removed from .gitignore."
else
    echo "Usage: $0 {exclude|include}"
fi
