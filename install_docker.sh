#!/bin/bash

until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

yum update -y
amazon-linux-extras install docker -y
service docker start
systemctl enable docker
usermod -a -G docker ec2-user
