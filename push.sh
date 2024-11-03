#!/bin/bash
MSG=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1`
git add .
git commit -m "$MSG"
git push origin master
