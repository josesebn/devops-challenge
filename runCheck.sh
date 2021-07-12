#!/usr/bin/env bash

#if curl ec2-15-223-70-168.ca-central-1.compute.amazonaws.com/version.txt | grep "1.0.6" > /dev/null; then
if curl --head ec2-15-223-70-168.ca-central-1.compute.amazonaws.com | grep "200 OK" > /dev/null; then
   echo "webserver version 1.0.6 is UP and RUNNING "
else
echo "Website version 1.0.6 is DOWN"
fi
