# borg-distribute
borg-distribute is a wrapper for the ingenious borg backup utility. Unfortunately this tool has no support for a server client architecture and other features, like multiple redundant backups distributed over multiple disks. borg-distribute handles the management of your repositories server-side and provides easy ways of pushing and retrieving backups from any client.

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
-Add usage help to any tool
-Automate the process of installing borg-distribute server-side
-Add script to create new repos (has to be done manually for now)
-Call rebuild-linker.sh with every ssh access
-Much more!
