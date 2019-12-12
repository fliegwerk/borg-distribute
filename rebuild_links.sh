#!/bin/sh

partition_list='partlist.txt'

folder_ifn_exists() {
	if [ ! -d ./"$1" ]
	then
		mkdir -p ./"$1" -m=700
	fi
}

folder_ifn_exists disks

rm -r repos

unlink ./disks/*

while read -r part_uuid; do
	disk_path=$(findmnt -rn -S PARTUUID="$part_uuid" -o TARGET)

	folder_ifn_exists "$disk_path"/backups

	ln -s "$disk_path"/backups ./disks/"$part_uuid"
	echo "$part_uuid: $disk_path"

	for repo in ./disks/"$part_uuid"/*; do
		repo_name=$(basename "$repo")
		repo_dir="$disk_path"/backups/"$repo_name"
		echo "  $repo_name"
		folder_ifn_exists "repos/$repo_name"

		# If repo/newest exists, check if current is newer, else just symlink
		if [ -e "repos/$repo_name/newest" ]
		then
			path_to_newest=$(pwd -P repos/"$repo_name"/newest)
			[ "$repo" -nt "$path_to_newest" ] && ln -s "$repo_dir" ./repos/"$repo_name"/newest
		else
			ln -s "$repo_dir" ./repos/"$repo_name"/newest
		fi

		# If repo/oldest exists, check if current is older, else just symlink
		if [ -e "repos/$repo_name/oldest" ]
		then
			path_to_oldest=$(pwd -P repos/"$repo_name"/oldest)
			[ "$repo" -ot "$path_to_oldest" ] && ln -s "$repo_dir" ./repos/"$repo_name"/oldest
		else
			ln -s "$repo_dir" ./repos/"$repo_name"/oldest
		fi
	done
done < $partition_list


