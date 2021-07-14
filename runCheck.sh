#!/usr/bin/env bash
chmod 400 my-key mykey.pem
ssh -i "my-key" $1 'pwd
systemctl status nginx
if [ $? -ne 0 ] ; then
    echo "************"
    sudo service nginx start'

#if curl ec2-15-223-70-168.ca-central-1.compute.amazonaws.com/version.txt | grep "1.0.6" > /dev/null; then
if curl --head $1 | grep "200 OK" > /dev/null; then
   echo "nginx webserver is UP and RUNNING "
else
echo "nginx webserver is DOWN"
fi
