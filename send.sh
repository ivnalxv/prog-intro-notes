#!/bin/bash

MESSAGE="new fix"
if [[ ! -z $1 ]]; then MESSAGE=$1; fi;
MESSAGE="\""$MESSAGE"\""

echo $MESSAGE

mdbook build
git add .	
git commit -m "${MESSAGE}"
git push
