# Vagrant Arch Meta Repo

This Vagrantfile uses an Arch base to build meta packages that have AUR depends using aurutils.

While offering some customization, this is for my own personal use. You probably shouldn't use it, especially if you're not familiar with Arch / AUR.

### Running

Copy `.env.example` to `.env` make changes and run `vagrant up`

Vagrantfile expects `id_rsa_github` and `id_rsa_github.pub` to be in the `ssh` folder. This is to connect to github for a private repositoy

A custom bootstrap script may be created and made exectuable called `extra_bootstrap.sh`. This may be used to run extra commands, like adding signing keys for aur packages.

### Environment variables

- `DEBUG_ARCH_REPOS` `0` / `1` controls extra logging
- `BUILD_PACKAGES_ON_START` `0` / `1` forces a build when container starts
- `ARCH_PKGS_DATA` *Required* The location of the nfs mount of the repo and meta packages. Used on host system to expose repo over http
- `REPO_NAME` the name of the custom repo. Default is `custom`
- `PACKAGE_REPO` *Required* git path to meta packages
- `PACMAN_CACHE_SERVER` Local mirror cache like flexo
- `CRON_FETCH_PACKAGES` Interval to fetch meta packages. Defaults to 15 minutes
- `CRON_AUR_SYNC_UPDATE` Interval to update AUR packages. Defaults to every hours
- `CRON_PACCACHE_CLEAN` Interval to clear pacman cache. Defaults to once a week on Monday at 8am container time
- `TZ` Set the timezone of the image
