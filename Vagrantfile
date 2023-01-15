# -*- mode: ruby -*-
# vi: set ft=ruby :
require "shellwords"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vagrant.plugins = ["vagrant-libvirt", "vagrant-readenv"]

  config.env.enable

  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "archlinux/archlinux"

  config.vm.hostname = "arch-pkgs"
  config.vm.provision "file", source: "makepkg.conf", destination: "~/.makepkg.conf"
  config.vm.provision "file", source: "ssh/config", destination: "~/.ssh/config"
  config.vm.provision "file", source: "ssh/known_hosts", destination: "~/.ssh/known_hosts"
  config.vm.provision "file", source: "ssh/id_rsa_github", destination: "~/.ssh/id_rsa_github"
  config.vm.provision "file", source: "ssh/id_rsa_github.pub", destination: "~/.ssh/id_rsa_github.pub"

  config.vm.synced_folder ENV["ARCH_PKGS_DATA"], "/var/cache/build", type: "virtiofs"
  config.vm.synced_folder "./", "/vagrant", type: "virtiofs"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"


  env = {
    "TZ" => ENV["TZ"],
    "PUID" => ENV["PUID"],
    "PGID" => ENV["PGID"],
    "REPO_NAME" => ENV["REPO_NAME"],
    "PACKAGE_REPO" => ENV["PACKAGE_REPO"],
    "DEBUG_ARCH_REPOS" => ENV["DEBUG_ARCH_REPOS"],
    "BUILD_PACKAGES_ON_START" => ENV["BUILD_PACKAGES_ON_START"],
    "PACMAN_CACHE_SERVER" => Shellwords.escape(ENV["PACMAN_CACHE_SERVER"]),
    "CRON_FETCH_PACKAGES" => ENV["CRON_FETCH_PACKAGES"],
    "CRON_AUR_SYNC_UPDATE" => ENV["CRON_AUR_SYNC_UPDATE"],
    "CRON_AUR_SYNC_UPDATE" => ENV["CRON_AUR_SYNC_UPDATE"],
  }

  config.vm.provider :libvirt do |libvirt|
		libvirt.cpus = 6
		libvirt.memory = 8192
    libvirt.memorybacking :access, :mode => "shared"
  end

  config.vm.provision "shell", path: "bootstrap.sh", env: env, privileged: true
  config.vm.provision "shell", path: "init.sh", env: env, run: "always", privileged: true
end
