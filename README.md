# storjble
Ansible script to set up a Storj node from source on a 32bit ubuntu based linux.

> **DISCLAIMER**: I am really a beginner with Ansible, in fact this is my first project. It is at the same time something I need and an opportunity to learn the tool. Any comment and feedback is welcome, I'll be happy to take them into accoutn to improve the project.

## Preamble

The purpose of the project is to:

1. Recreate a Storj node from scratch building from source and setting up
   the system to properly operate (see to Create a node from scratch)
2. Upgrade an existing Storj node to a new version from source (see Upgrade an existing node)

In both cases it is assumed the target system is an 32 bit ubuntu based linux system, which is the motivation to start this project because Docker is not  available on such environment. I still wanted to use an old machine as Storj node, therefore I had to start from the source code.

Many thanks to who helped me to put all the pieces together, in particular **Storj support engineers** and the **Storj forum**. Special thanks to **Alexey** who always and promptely replied to my questions. Thanks **littleskunk**, **elek** and **ifraixedes** for the support in fixing a building issue.

## Prerequisites

This approach assumes the following requirements are met:

- Ubuntu installed with at least a sudoer user
- Networking is configured and the machine is accessible from the Ansible controller
- SSH certificate authentication (i.e. passwordless)
- Ansible

## Instructions

As a first step, we need to download some required packages for a 32bit system
that may not be easily avalable through the standard repoitories:

> $> . init-repository.sh

The next step  is to customize a couple of files:

1. Copy **env.example** to your own version and customize it; this provides some bootstrap information that can not be published in the repository likenetwork configuration, wallet, etc
2. Copy **hosts.example** to your own version and customize it; this contains the hosts to be used as ansible's targets

Finally, copy the archived Storj node identity to **repository/identity-{TARGET}.tgz** (i.e. the content of **.local/share/storj/identity**; eg. cd **.local/share/storj**; tar cvzf **identity-test.tgz** **identity**)

### Create a node from scratch

To create a node from scratch, set-up your env and hosts files (let's assume
they are called env and hosts) and run the playbook:

> $> . env

> $> ansible-playbook -i hosts storj-create.yaml -K

This will:

- Install git,bash,gcc,libc-dev from apt repository
- Setup the host netplan to a fixed IP configuration
- Install go1.17.6.linux-386 from the version in repository/
- Install node-v16.13.2-linux-x86 from the package in repository/
- Install and configure Wonder Shaper to limit the bandwdth used by the node between 9:00AM and 8:00PM
- - Create the user storj
- Add the mount point adding to fstab the line files/{TARGET}/etc/fstab
- Build and install Storj ver {VERSION} under /home/storj/STORJ
- Install the script earnings.py (<https://github.com/ReneSmeekes/storj_earnings>)
- Install the script successrate.sh (<https://github.com/ReneSmeekes/storj_success_rate>) and schedule to run it every day
- Configure logrotate to rotate Storj and successrate logs
- Install a Storj node identity
- Configure the node with testing values
- Install a Storj service to be managed with systemctl

After the playbook has done, reboot the target.

### Upgrade an existing node

First update VERSION in your environment with the version of Storj to install (eg. v1.47.3)

Run the upgrade playbook:
 
> $> . env

> $> ansible-playbook -i hosts storj-upgrade.yaml --user storj -K

NOTES

1. Note the the playbook runs as **storj** user
2. The playbook requests to confirm the installation of the new version; check that the version you are installing is a release version
3. At the end of the process the service **storagenode** is restarted

