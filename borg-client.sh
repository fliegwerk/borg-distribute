#!/bin/sh

HOST=$(uname -n)

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=ssh://backup/~/repos/"$USER-$HOST/newest"

# Setting this, so you won't be asked for your repository passphrase:
#export BORG_PASSPHRASE='XYZl0ngandsecurepa_55_phrasea&&123'
# or this to ask an external program to supply the passphrase:
#export BORG_PASSCOMMAND='pass show backup'

export BORG_PASSCOMMAND="cat $HOME/.config/borg/hawk-pk"

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

epoch_hour=$(($(date '+%s') / 60 / 60))


push_backup()
{
    info "Starting backup"

    # Backup the most important directories into an archive named after
    # the machine this script is currently running on:

    borg create                         \
        --verbose                       \
        --filter AME                    \
        --list                          \
        --stats                         \
        --show-rc                       \
        --compression lz4               \
        --exclude-caches                \
        --exclude '/home/*/.var/app'    \
        --exclude '/home/*/.cache/*'    \
        --exclude '/var/cache/*'        \
        --exclude '/var/tmp/*'          \
                                        \
        ::'{hostname}-{now}'            \
        /home/"$USER"                   \

    #    /etc                            \
    #    /home                           \
    #    /root                           \
    #    /var                            \

    backup_exit=$?
}

prune_backup(){
    info "Pruning repository"

    # Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
    # archives of THIS machine. The '{hostname}-' prefix is very important to
    # limit prune's operation to this machine's archives and not apply to
    # other machines' archives also:

    borg prune                          \
        --list                          \
        --show-rc                       \
        --keep-daily    7               \
        --keep-weekly   4               \
        --keep-monthly  6               \
        --keep-yearly   3               \
        --prefix '{hostname}-'          \

    prune_exit=$?
}

mount_repo(){
    info "Starting mount. Unmount with ^C"

    borg mount -f $BORG_REPO $1 
}

# display all the arguments using for loop
if [ $# -gt 0 ]; then
    case $1 in
        backup )
            push_backup
            exit $backup_exit;;
        prune  )
            prune_backup
            exit $prune;;
        info   ) borg info
            exit;;
        mount  )
            mount_repo $2;;
        * ) echo "Unrecognized command: $arg"
            exit 2;; # TODO: Print helpFunction in case parameter is non-existent
    esac
else
    echo "No argument provided to the script. Default: Backup and Prune"
    push_backup
    prune_backup

    borg info

    # use highest exit code as global exit code
    global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

    if [ ${global_exit} -eq 0 ]; then
        info "Backup and Prune finished successfully"
    elif [ ${global_exit} -eq 1 ]; then
        info "Backup and/or Prune finished with warnings"
    else
        info "Backup and/or Prune finished with errors"
    fi

    exit ${global_exit}
fi
