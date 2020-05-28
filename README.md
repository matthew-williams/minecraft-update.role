# Minecraft Update-Role
=========

This role runs the bash script in ./files that can either backup, restore, or backup, install new package,
and the restore backups to a new install of twitch launcher modpacks.


## Requirements
------------
- Curse provided .zip server modpack files
- access to create files in /tmp
- access to sudo for rsync and file deletion
## Dependencies
------------
- unzip

## Usage
-----
Currently the role tasks do not function but the bash script does. You can run it manually using command below:

Backup only:
```
sudo bash ~/minecraftupdate.sh --pack-path /opt/minecraft/PO3/ -b
```

Installation of a new updated pack version:

```
sudo bash ~/minecraftupdate.sh --pack-path /opt/minecraft/CrackPack3/ -n Eternal+\(Server+Pack+1.3.3\).zip
```

Usage commands:
```
sudo bash ~/minecraftupdate.sh -h
```

## Testing
-----
 - [shellcheck.net](https://www.shellcheck.net/) <= this is an online bash script linter i use to validate this script.

### Links For Additional Information
--------------------------------

 - [ansible inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html) <= this is python package just use `pip install ansible` in your virtual environment
