# borg-distribute
borg-distribute is a wrapper for the ingenious borg backup utility. Unfortunately this tool has no support for a server client architecture and other features, like multiple redundant backups distributed over multiple disks. borg-distribute handles the management of your repositories server-side and provides easy ways of pushing and retrieving backups from any client.

## Philosophy

The main feature of borg is the ability to do very fine-grained incremental backups efficiently, but this has a quite severe drawback: Any damage to the archive will result in total corruption as there's no redundancy. This is where borg-distribute comes into play: By creating archives on multiple disks and cycling through them we add another layer of security.

New backups are always pushed onto the oldest archive available. This way we automatically cycle through all disks and wear them down evenly. If you want to retrieve information from your backup it will automatically be pulled from the newest release.

## Server-side directory structure

Consider a structure like this:

    /home/borg
    ├── partlist.txt
    ├── disks
    │   ├── 94047ea0-01 -> /mnt/disk1
    │   ├── a4fc1b7e-01 -> /mnt/disk2
    │   └── 34f5888d-01 -> /mnt/disk3
    └── repos
        ├── my-backup
        │   ├── newest -> /mnt/disk3/backups/jan-hawk
        │   └── oldest -> /mnt/disk2/backups/jan-hawk
        └── another-backup
            ├── newest -> /mnt/disk1/backups/seb-bak
            └── oldest -> /mnt/disk3/backups/seb-bak
            
Here we have three disks for our backup storage available under /home/borg/disks for easier acces and symlinks to the newest and oldest instances of every backup repository respectively. The script `rebuild-links.sh` automatically creates this structure for us. All you have to supply is the file `partlist.txt` which is a collection of all partition UUIDs containing backups.

# Installation
## SSH Access
It's advised to create a new SSH keypair for every user of your borg backup system. Setup some sort of quick access in your .ssh/config like this:

    Host backup
       HostName my.backupserver.com
       Port 22
       User borg
       IdentityFile ~/.ssh/my_backup_private_key

To restrict users of accessing each other's repositories setup the .ssh/authorized_keys file on the server account like this:

    command="cd /home/borg/repos/my_repo; borg serve --restrict-to-repository /home/borg/repos/my_repo/oldest --restrict-to-repository /home/borg/repos/my_repo/newest",no-pty,no-agent-forwarding,no-port-forwarding,no-X11-forwarding,no-user-rc ssh-ed25519 <my_backup_public key> me@my_machine
    
It's important to write everything in one line per key, otherwise SSH won't recognize the rule and your security will be compromised.

# TODO
- Add usage help to any tool
- Automate the process of installing borg-distribute server-side
- Add script to create new repos (has to be done manually for now)
- Call rebuild-linker.sh with every ssh access
- Much more!
