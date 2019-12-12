# borg-distribute
A collection of tools to allow management of borg repos over many devices and disks.

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
    
It' important to write everything in one line per key, otherwise SSH won't recognize the rule and your security will be compromised.
