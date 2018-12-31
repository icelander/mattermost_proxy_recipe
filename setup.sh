#!/bin/bash

echo "Updating and Upgrading"
apt-get -yq update

export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< 'mysql-server-10.0 mysql-server/root_password password #MYSQL_ROOT_PASSWORD'
debconf-set-selections <<< 'mysql-server-10.0 mysql-server/root_password_again password #MYSQL_ROOT_PASSWORD'

apt-get install -yq mysql-server squid


mv /etc/squid/squid.conf /etc/squid/squid.orig.conf
ln -s /vagrant/squid.conf /etc/squid/squid.conf

sed -i 's/MATTERMOST_PASSWORD/#MATTERMOST_PASSWORD/' /vagrant/db_setup.sql
echo "Setting up database"
mysql -uroot -p#MYSQL_ROOT_PASSWORD < /vagrant/db_setup.sql

rm -rf /opt/mattermost

wget https://releases.mattermost.com/5.5.1/mattermost-5.5.1-linux-amd64.tar.gz

tar -xzf mattermost*.gz

rm mattermost*.gz
mv mattermost /opt

mkdir /opt/mattermost/data
rm /opt/mattermost/config/config.json

ln -s /vagrant/config.json /opt/mattermost/config/config.json
chmod 777 /vagrant/config.json

# Sets the proxy values
ln -s /vagrant/mattermost.environment /opt/mattermost/config/mattermost.environment


useradd --system --user-group mattermost
chown -R mattermost:mattermost /opt/mattermost
chmod -R g+w /opt/mattermost

# Contains environment variables
# ln -s /vagrant/mm.environment /opt/mattermost/config/mm.environment

ln -s /vagrant/mattermost.service /lib/systemd/system/mattermost.service
systemctl daemon-reload

cd /opt/mattermost
bin/mattermost user create --email admin@planetexpress.com --username admin --password admin
bin/mattermost sampledata --seed 10 --teams 4 --users 30

service mysql start
service mattermost start

# IP_ADDR=`/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'`

printf '=%.0s' {1..80}
echo 
echo '                     VAGRANT UP!'
echo "GO TO http://127.0.0.1:8065 and log in with \`admin\`"
echo
printf '=%.0s' {1..80}