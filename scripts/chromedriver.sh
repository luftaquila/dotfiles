rm /usr/bin/chromedriver
version=`curl https://chromedriver.storage.googleapis.com/LATEST_RELEASE`
wget https://chromedriver.storage.googleapis.com/$version/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
mv chromedriver /usr/bin
chmod 755 /usr/bin/chromedriver
chown luftaquila:luftaquila /usr/bin/chromedriver
rm chromedriver_linux64.zip
echo DONE
rm LICENSE.*
