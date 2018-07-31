#!/bin/sh

# Run on VM to bootstrap Puppet Agent nodes

if ps aux | grep "puppet agent" | grep -v grep 2> /dev/null
then
    echo "Puppet Agent is already installed. Moving on..."
else
    # Ubuntu
    # sudo apt-get install -yq puppet

    # Centos
    #sudo yum install -y puppet
    sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
    sudo yum install -y puppet-agent
fi

if cat /etc/crontab | grep puppet 2> /dev/null
then
    echo "Puppet Agent is already configured. Exiting..."
else
    # Ubuntu
    # sudo apt-get update -yq && sudo apt-get upgrade -yq

    # Centos
    sudo yum update -yq && sudo yum upgrade -yq

    # Ubuntu
    # sudo puppet resource cron puppet-agent ensure=present user=root minute=30 \
    #     command='/usr/bin/puppet agent --onetime --no-daemonize --splay'

    # sudo puppet resource service puppet ensure=running enable=true
    sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.5    puppet.example.com  puppet" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.10   node01.example.com  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.20   node02.example.com  node02" | sudo tee --append /etc/hosts 2> /dev/null

    # Ubuntu ??
    # Add agent section to /etc/puppet/puppet.conf
    # echo "" && echo "[agent]\nserver=puppet" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null

    # Ubuntu ??
    # sudo puppet agent --enable

    sudo /opt/puppetlabs/bin/puppet agent --test

fi
