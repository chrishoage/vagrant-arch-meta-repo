#!/bin/bash

if [[ "$PACMAN_CACHE_SERVER" != "" ]]; then
  echo "setting up $PACMAN_CACHE_SERVER"
  echo "Server = $PACMAN_CACHE_SERVER" >/etc/pacman.d/mirrorlist
fi

pacman -Syu --noconfirm --quiet --needed \
    base \
    base-devel \
    wget \
    rsync \
    cronie \
    devtools \
    logrotate \
    pacutils \
    pacman-contrib

systemctl enable --now logrotate.timer
systemctl enable --now paccache.timer

mkdir -p /etc/systemd/system/cronie.service.d
echo "\
[Service]
ExecStart=
ExecStart=/usr/bin/crond -n -s -P
" > /etc/systemd/system/cronie.service.d/override.conf

systemctl enable --now cronie.service

echo "installing aurutils"

sudo -u vagrant /bin/sh <<\EOF
cd /tmp
whoami
wget --quiet https://aur.archlinux.org/cgit/aur.git/snapshot/aurutils.tar.gz
tar xzf /tmp/aurutils.tar.gz
cd aurutils
makepkg --noconfirm --rmdeps -rsci
cd ..
rm -rf aurutils aurutils.tar.gz
EOF


echo "setting up extra pacman config"
echo "Include = /etc/pacman.d/*.conf" >> /etc/pacman.conf

#User params
TIMEZONE=${TZ:="UTC"}

TZFILE="../usr/share/zoneinfo/${TIMEZONE}"

# Work from the /etc directory
cd /etc

if [ -f ${TZFILE} ]; then # Make sure the file exists
	echo "Setting timezone to ${TIMEZONE}"
	ln -sf ${TZFILE} localtime # Set the timezone
else
	echo "Timezone: ${TIMEZONE} not found, skipping"
fi

echo "Syncing /vagrant/bin"

rsync -pr /vagrant/bin/ /usr/local/bin/
chmod +x /usr/local/bin/

if [ -f /vagrant/extra_bootstrap.sh ]; then
  echo "Executing extra_bootstrap.sh"
  bash /vagrant/extra_bootstrap.sh
fi
