## Description

This is simple Vagrant setup that should be able to run Drupal on probably any OS.
So far this is tested on OS X 10.9/10.10, Windows 8.0/0.1 and Ubuntu 14 on default instalations
almost everything works out-of-the-box but every system can have it quirk's.

It does couple of things:

  * Installs drush on VM so you can manage website within vagrant
  * If you setup project folder and within that folder is Drupal it will be installed( admin:admin )
  * If database_filename is set drush wil import database after install, disable caching and agregation,
  and clear caches
  * If there are drush aliases on host they will be available on vagrant (.drush is mounted)
  * Private keys from host machine will be forwared to vagrant so they can be used.
  This can be tested by loging into vagrant (`vagrant ssh`) and running `ssh -T git@github.com`


## Getting Vagrant up

Before doing anything you must to initialize and update git submodules that are inside this project by runing:

    git submodule init
    git submodule update

After this download Drupal or clone your project to vagrant root folder and configure config.yml to your needs.
Probably last step before being able to access your project is to get vagrant up by runing:

    vagrant up

After this vagrant might ask you to install couple plugins that will make your life easier.
When done with install try running vagrant up again.
