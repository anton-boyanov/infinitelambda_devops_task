#!/bin/bash${cluster_name}"
yum -y update
yum -y install docker
systemctl start docker
systemctl enable docker
systemctl status docker
yum -y install java-1.8.0-openjdk git
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum -y install jenkins
systemctl start jenkins
systemctl status jenkins

echo "Done"