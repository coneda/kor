#!/bin/bash -e

HOST="root@home.moritzschepp.me"

npm run build
rsync -av public/ $HOST:/var/www/widgets/ 
ssh $HOST "rm /var/www/widgets/index.html"
