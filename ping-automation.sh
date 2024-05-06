#!/bin/bash

# Automating to continuous ping of a website
# This ensures the server is up and running

sudo apt update -y
sudo apt install telnet -y

echo "Please enter the hostname (i.e. www.google.com):"
read hostname

echo "Please enter the port number:"
read portNumber

echo "Ping $hostname on port number $portNumber..."
ping -c 10 $hostname

if [ $? = 0 ]; then
    echo "Server is up and running..."
else
    echo "Server is down. Using telnet..."
    telnet -c 10 $hostname $portNumber
fi
