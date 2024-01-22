# #!/bin/bash

cat << EOF > /etc/environment
REPO_NAME=${REPO_NAME:-"custom"}
PACKAGE_REPO=${PACKAGE_REPO:-""}
DEBUG_ARCH_REPOS=${DEBUG_ARCH_REPOS:-"0"}
BUILD_PACKAGES_ON_START=${BUILD_PACKAGES_ON_START:-"0"}
PACMAN_CACHE_SERVER=${PACMAN_CACHE_SERVER:-""}
# Every 15 Minutes
CRON_FETCH_PACKAGES="${CRON_FETCH_PACKAGES:-"*/15 * * * *"}"
# Every hour on minute 3
CRON_AUR_SYNC_UPDATE="${CRON_AUR_SYNC_UPDATE:-"3 * * * *"}"
EOF

set -o allexport
source /etc/environment
set +o allexport

if [ -f /tmp/arch-packages.local ]; then
  echo "removing /tmp/arch-packages.local found during init"
  rm /tmp/arch-packages.local
fi

echo "setting up  /var/cache/build/repo"
mkdir -p /var/cache/build/repo
repo_db=/var/cache/build/repo/$REPO_NAME.db.tar.zst

if [ ! -f $repo_db ]; then
  repo-add $repo_db
fi

pacman_conf=/etc/pacman.d/$REPO_NAME.conf

if [ ! -f $pacman_conf ]; then
  echo "setting up $pacman_conf"
  echo "\
[options]
CacheDir = /var/cache/pacman/pkg
CacheDir = /var/cache/build/repo
CleanMethod = KeepCurrent

[$REPO_NAME]
SigLevel = Optional TrustAll
Server = file:///var/cache/build/repo
" >$pacman_conf
fi

chroot_pacman_conf=/etc/aurutils/pacman-x86_64.conf

if [ ! -f $chroot_pacman_conf ]; then
  echo "setting up $chroot_pacman_conf"
  cp /usr/share/devtools/pacman.conf.d/extra.conf $chroot_pacman_conf
  echo "\
[$REPO_NAME]
SigLevel = Optional TrustAll
Server = file:///var/cache/build/repo
" >>$chroot_pacman_conf
fi

chroot_makepkg_conf=$HOME/makepkg.conf

if [ ! -f $chroot_makepkg_conf ]; then
  echo "setting up $chroot_makepkg_conf"
  cp /usr/share/devtools/makepkg.conf.d/x86_64_v3.conf $chroot_makepkg_conf
fi

pacsync $REPO_NAME

# chown -R build:build /var/cache/build

if [ ! -d /var/cache/build/packages ]; then
  echo "setting up /var/cache/build/packages"

  (
    cd /var/cache/build
    GIT_SSH_COMMAND="ssh -o 'StrictHostKeyChecking=accept-new'" \
      sudo -u vagrant -E git clone $PACKAGE_REPO packages
  )

  if [ $? -gt 0 ]; then
    echo "failed to check out $PACKAGE_REPO"
    exit 1
  fi
fi

pacman -Syu --noconfirm --quiet

if [ "$BUILD_PACKAGES_ON_START" == "1" ]; then
  sudo -E -u vagrant make-pkgs
fi

echo "$CRON_FETCH_PACKAGES  vagrant fetch-pkgs 2>&1 | dlog" >/etc/cron.d/fetch-packages
echo "$CRON_AUR_SYNC_UPDATE vagrant aur-check 2>&1 | dlog" >/etc/cron.d/aur-sync-update

chmod 0644 /etc/cron.d/*


