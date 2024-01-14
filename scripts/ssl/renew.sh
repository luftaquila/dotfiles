#!/bin/bash

source ./porkbun.secret.sh

jq -r '.intermediatecertificate' <<< "$res" > intermediate.cert.pem
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
