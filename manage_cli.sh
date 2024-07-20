#!/bin/bash

if [ "$1" == "exclude" ]; then
    echo "Excluding mohmed-cv/app.py from tracking..."
    echo "mohmed-cv/app.py" >> .gitignore
    git rm --cached mohmed-cv/app.py
    git add .gitignore
    git commit -m "Exclude cli.py from tracking"
    git push origin master
    echo "mohmed-cv/app.py has been excluded from tracking and added to .gitignore."
elif [ "$1" == "include" ]; then
    echo "Including devops_bot/cli.py in tracking..."
    sed -i '' '/mohmed-cv\/app.py/d' .gitignore
    git add .gitignore
    git add mohmed-cv/app.py
    git commit -m "Include cli.py in tracking"
    git push origin master
    echo "mohmed-cv/app.py has been included in tracking and removed from .gitignore."
else
    echo "Usage: $0 {exclude|include}"
fi

