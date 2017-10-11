#!/bin/bash

echo "Install Jenkins"

echo "deb http://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt-get update
apt-get install jenkins -y --allow-unauthenticated

echo -n "Wait for jenkins to start and create admin user."
for i in {1..10} ; do
	sleep 1
	if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
		echo "."
		break
	fi
	echo -n "."
done

echo "Disable setup wizard in Jenkins"
cp /var/lib/jenkins/{jenkins.install.UpgradeWizard.state,jenkins.install.InstallUtil.lastExecVersion}

echo "Restart Jenkins"
service jenkins restart
