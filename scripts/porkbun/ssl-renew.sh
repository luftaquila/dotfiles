#!/bin/bash

# load $APIKEY and $SECRET
source ./porkbun-secret.sh

# get keys from API
res=`curl -X POST -H "Content-Type: application/json" -d "{\"apikey\": \"$APIKEY\", \"secretapikey\": \"$SECRET\"}" https://porkbun.com/api/json/v3/ssl/retrieve/luftaquila.io`

jq -r '.certificatechain' <<< "$res" > domain.cert.pem
jq -r '.privatekey' <<< "$res" > private.key.pem
jq -r '.publickey' <<< "$res" > public.key.pem

echo "SSL certificate retrieve complete"

echo "Removing original *.pem files"
sudo rm /etc/ssl/porkbun/luftaquila.io/*.pem

echo "Copying new *.pem files"
sudo cp *.pem /etc/ssl/porkbun/luftaquila.io

echo "Removing temporary files"
rm *.pem

echo "Restarting web server"
sudo systemctl restart nginx

echo "Job completed"
