#! /bin/sh

# Runs the ./unlock.sh and ./rposync.sh script for multiple directories and
# commmits and pushes any resulting changes.
#
# v2022.128
#
# You need to create a config file which is a shell script containing required
# variable assignments for driving the whole process. You can use your own
# variables also as long as their names are prefixed with "X_".
#
# Start by creating an empty config file and then run this script. It will
# fail and tell you the next variable which needs to be defined in the config.
# All variables effectively represent one- or two-dimensional arrays. If there
# are no more entries you want to add, just assign am empty string to the next
# array element. This tells the script the arrays stops here.
#
# Basically there are two loops of definitions required:
#
# The outer loop specifies the encrypted directories, the location of the
# encryption key, and the paths to the contained backup subdirectories after
# unlocking the encryption.
#
# The inner loop specifies the relative path to app backup subdirectories as
# well as the path to the unencrypted git repository which shall by synced
# with this backup directory.

vname_repo_prefix=sync_
vname_key_prefix=key_
vname_bundles_subdir_prefix=subdir_
vname_repo_dirs_prefix=repo_
vname_index_sep=_
unlock_script=./unlock.sh
unlock_script_lock_option=-u
sync_script=./rposync.sh
UUID=tkr78gti532vvng066akppadz

set -e
trap 'test $? = 0 || echo "\"$0\" failed!" >& 2' 0

must() {
	"$@" && return
	echo "FAILED: >>>$@<<<" >& 2
	false || exit
}

must_be_set() {
	eval "test \"\${$1+set}\" = set" && return
	echo "Variable \$$1 must be set but it is not!" >& 2
	false || exit
}

verify_all_committed() {
	must test -d "$1"/.git
	(
		cd -- "$1"
		test "`git status --short | wc -l`" = 0 && return
		echo "*** Uncommitted files in $1:"
		git status
		false || exit
	) || exit
}

only_checkin=false
push=true
while getopts Pc opt
do
	case $opt in
		P) push=false;;
		c) only_checkin=true;;
		*) false || exit
	esac
done
shift `expr $OPTIND - 1 || :`

APP=${0##*/}
test "$HOME"; test -d "$HOME"
: ${XDG_DATA_HOME:=$HOME/.local/share} ${XDG_CONFIG_HOME:=$HOME/.config}
APP_=`printf '%s' "$APP" | tr -sc '[:alnum:]' _`
CONFIG_FILE=$XDG_CONFIG_HOME/misc/${APP_}_$UUID.conf
must test -f "$CONFIG_FILE"
. "$CONFIG_FILE"

i=1
while :
do
	must_be_set $vname_repo_prefix$i
	eval repo=\$$vname_repo_prefix$i
	test -z "$repo" && break
	if $only_checkin
	then
		:
	else
		verify_all_committed "$repo"
	fi
	eval key=\$$vname_key_prefix$i
	must test -f "$key"
	test -f "$repo/$unlock_script"
	test -f "$repo/$sync_script"
	j=1
	while :
	do
		k=$i$vname_index_sep$j
		must_be_set $vname_bundles_subdir_prefix$k
		eval bundles=\$$vname_bundles_subdir_prefix$k
		test -z "$bundles" && break
		eval urepo=\$$vname_repo_dirs_prefix$k
		if $only_checkin
		then
			:
		else
			verify_all_committed "$urepo"
		fi
		j=`expr $j + 1`
	done
	i=`expr $i + 1`
done
i=1
while :
do
	eval repo=\$$vname_repo_prefix$i
	test -z "$repo" && break
	eval key=\$$vname_key_prefix$i
	(
		printf '\n*** %s\n' "$repo"
		cd -- "$repo"
		if $only_checkin
		then
			:
		else
			psw=$key sh "$unlock_script"
			j=1
			while :
			do
				k=$i$vname_index_sep$j
				eval bundles=\$$vname_bundles_subdir_prefix$k
				test -z "$bundles" && break
				eval urepo=\$$vname_repo_dirs_prefix$k
				sh "$sync_script" "$urepo" "$bundles"
				j=`expr $j + 1`
			done
			sh "$unlock_script" $unlock_script_lock_option
		fi
		if test "`git status --short | wc -l`" != 0
		then
			git add .
			git commit -m push
		fi
		if $push
		then
			git push
		fi
	)
	i=`expr $i + 1`
done
