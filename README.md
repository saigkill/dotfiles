Saigkills Dotfiles Template
===========================

This is a repository for bootstrapping my dotfiles with [Dotbot][dotbot] and or deploying a complete machien.

The first step for using is to fork the repo and modify the config files to your needs. You 
also can just install it, run your Apps and submit the modified configs.

There are two options to install:

  - Install the dotfiles with the install script
  - Install the dotfiles with the deploy script

| :exclamation:  You have to review at least the parts who marked as "TO_MODIFY".<br/> Better you review each part. This step is unique. Also you should make a backup<br/> for the Windows System and the WSL. |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

If you are using the install script, just use one of these commands:

```bash
./install-private.sh (for using on private machines) or
./install-business.sh (for using on business machines)
```

or for Windows:

```powershell
.\install-private.ps1 (for using on private machines) or
.\install-business.ps1 (for using on business machines)
```

The second option is to use a full deploying script.

For using the deploy mechanism, it has to modifed. The deploy directory contains:

  - apt (It contains my preferred packages for using in a apt based distro)
  - powershell-modules (Contains my prefered Powershell Modules. Will installed via Script)
  - winget (My prefered app, installed via winget under Windows)
  - chocolatey (Contains my prefered packages installed via chocolatey under Windows)
  - scoop (Contains my prefered packages installed via scoop under Windows)

You can use one of these scripts in deploy directory:

```bash
./linux-apt.sh (Installs all automatically installable packages for apt based distros)
.\windows.ps1 (Installs all automatically installable packages for windows)
```
While running the deploy script, the dotfiles will be installed too.

License
-------

This software is hereby released into the public domain. That means you can do
whatever you want with it without restriction. See `LICENSE.md` for details.

That being said, I would appreciate it if you could maintain a link back to
Dotbot (or this repository) to help other people discover Dotbot.

[dotbot]: https://github.com/anishathalye/dotbot
