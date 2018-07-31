#!/bin/sh

# Run on VM to bootstrap Puppet Master server

if ps aux | grep "puppet master" | grep -v grep 2> /dev/null
then
    echo "Puppet Master is already installed. Exiting..."
else
    # Install Puppet Ubuntu Master
    # wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
    # sudo dpkg -i puppetlabs-release-trusty.deb && \
    # sudo apt-get update -yq && sudo apt-get upgrade -yq && \
    # sudo apt-get install -yq puppetmaster

    # Install Puppet Centos Master
    # sudo echo "192.168.10.22 puppetagent-1" | sudo tee -a /etc/hosts
    # sudo echo "192.168.10.23 puppetagent-2" | sudo tee -a /etc/hosts
    # TODO Set this to actual server timezone
    sudo timedatectl set-timezone America/New_York
    sudo yum -y install ntp
    sudo systemctl start ntpd
    sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
    sudo yum -y install puppetserver
    sudo systemctl enable puppetserver
    sudo systemctl start puppetserver

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.5    puppet.example.com  puppet" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.10   node01.example.com  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.20   node02.example.com  node02" | sudo tee --append /etc/hosts 2> /dev/null

    # Add optional alternate DNS names to /etc/puppet/puppet.conf
    # set -x
    # ls /etc
    # set +x
    # Ubuntu. Not sure what this is for in Centos
    # sudo sed -i 's/.*\[main\].*/&\ndns_alt_names = puppet,puppet.example.com/' /etc/puppet/puppet.conf
    
    # Centos
    echo "# Configuring Puppet Master to Allow autosign"
    sudo sed -i '/\[master\]/a autosign = true' /etc/puppetlabs/puppet/puppet.conf
    # sudo echo "autosign = true" /etc/puppetlabs/puppet/puppet.conf

    # Install some initial puppet modules on Puppet Master server
    # Ubuntu
    # sudo puppet module install puppetlabs-ntp
    # sudo puppet module install garethr-docker
    # sudo puppet module install puppetlabs-git
    # sudo puppet module install puppetlabs-vcsrepo
    # sudo puppet module install garystafford-fig

    # Centos
    sudo /opt/puppetlabs/bin/puppet module install puppetlabs-apache

    # symlink manifest from Vagrant synced folder location
    # TODO Make all ubuntu versus centos configuration changes toggled based on the passed arguments from vagrantfile so the command can be the same
    # Ubuntu
    # ln -s /vagrant/site.pp /etc/puppet/manifests/site.pp

    # Centos
    mkdir -p  /opt/puppetlabs/puppet/manifests
    ln -s /vagrant/site.pp /opt/puppetlabs/puppet/manifests/site.pp
    # ln -s /vagrant/site.pp /opt/puppetlabs/code/environments/production/manifests/site.pp

    # Centos
    # echo "*.example.com" >> /opt/puppetlabs/autosign.conf
    echo "*.example.com" | sudo tee -a /etc/puppetlabs/puppet/autosign.conf
fi
