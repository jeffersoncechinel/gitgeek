#!/bin/sh
# ==================================================================
# @Author: Jefferson Cechinel
# @Email: jefferson@homeyou.com
# @Date:   2015-08-30 16:26:28
# @Last Modified by:   jefferson
# @Last Modified time: 2015-09-14 21:30:20
#
# ------------------------------------------------------------------

#
# GitGeek (gitgeek) - v0.1
# This is a simple bash script utility that speeds up the repetitive tasks
# by automating in a few strokes the use of git application in a very fashion
# prompt menu way.
#

# By default it will prompt you to configure the git project bt setting your real name and
# e-mail address if it is not set yet.


#Stop git from converting end lines LF(unix) to CRLF(windows).
git config core.autocrlf false

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

clear

echo ""
echo "  ____ _ _    ____           _    "
echo " / ___(_) |_ / ___| ___  ___| | __"
echo "| |  _| | __| |  _ / _ \/ _ \ |/ /"
echo "| |_| | | |_| |_| |  __/  __/   < "
echo " \____|_|\__|\____|\___|\___|_|\_\\"
echo ""
echo  -e $COL_YELLOW"GIT Geek - Verson 0.1 (Jefferson Cechinel)"$COL_RESET
echo ""
BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`

# if [ -z "$BRANCH" ]; then
# 	echo "You have no branches at this moment. You need at least one branch to run this script."
# 	exit
# fi

echo -e "You are working in branch: $COL_GREEN $BRANCH $COL_RESET"
echo "List of branches in this repository:"
git branch
echo ""

NAME=`git config user.name`
EMAIL=`git config user.email`

if [ -z "$NAME" ]; then
	read -p "Full Name for this project (git config user.name): " tname
	git config user.name "$tname"
	echo ""
fi

if [ -z "$EMAIL" ]; then
	read -p "Email address for this project (git config user.email): " temail
	git config user.email "$temail"
	echo ""
fi

commit()
{
	read -p "Type the commit message:" msg
    echo "Adding all files.."
    echo -e $COL_MAGENTA"git add . $COL_RESET"
	git add .
	echo "Checking git status.."
	echo -e $COL_MAGENTA"git status $COL_RESET"
	git status
	echo "Commiting with message: $msg"
	echo -e $COL_MAGENTA"git commit -a -m "$msg" $COL_RESET"
	git commit -a -m "$msg"
	refresh
}

commitpush()
{
	read -p "Type the commit message:" msg
    echo "Adding all files.."
    echo -e $COL_MAGENTA"git add . $COL_RESET"
	git add .
	echo "Checking git status.."
	echo -e $COL_MAGENTA"git status $COL_RESET"
	git status
	echo "Commiting with message: $msg"
	read -p "Perform git commit? (y/n):" yn
	if [ "$yn" != "y" ]; then
		refresh
		return
	fi
	echo -e $COL_MAGENTA"git commit -a -m "$msg" $COL_RESET"
	git commit -a -m "$msg"

	echo "Pushing to remotes..."
	IFS=$'\n'
	arr=($(git remote -v |grep "(push)"| sed 's/:.*//'))
	unset IFS

	BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`
	for i in "${arr[@]}"
	do
		DST=`echo $i | cut -d " " -f1`

		read -p "Push to $DST? (y/n):" yn
		if [ "$yn" == "y" ]; then
			echo -e $COL_MAGENTA"git push $DST $BRANCH $COL_RESET"
			git push $DST $BRANCH
		fi
	done
	refresh
}

autocommit()
{
	msg="Auto commited."
    echo -n "Deleting caching files if any... "
    rm -rf data/log/* data/cache/*.php
    echo "OK"
    echo "Adding all files.."
   	echo -e $COL_MAGENTA"git add . $COL_RESET"
	git add .
	echo "Checking git status.."
	echo -e $COL_MAGENTA"git status $COL_RESET"
	git status
	echo "Commiting with message: $msg"
	echo -e $COL_MAGENTA"git commit -a -m $msg $COL_RESET"
	git commit -a -m "$msg"
	echo "Pushing to all remotes..."
	IFS=$'\n'
	arr=($(git remote -v |grep "(push)"| sed 's/:.*//'))
	unset IFS

	BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`
	for i in "${arr[@]}"
	do
		DST=`echo $i | cut -d " " -f1`
		echo -e $COL_MAGENTA"git push $DST $BRANCH $COL_RESET"
		git push $DST $BRANCH
	done
	refresh
}

merge_deploy()
{
	BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`

	if [ "$BRANCH" == "master" ];then
		echo -e "You cannot merge current branch ($COL_GREEN $BRANCH $COL_RESET) into ($COL_YELLOW master $COL_RESET)"
		return
	fi

	echo -e "You are about to merge the current branch ($COL_GREEN $BRANCH $COL_RESET) into ($COL_YELLOW master $COL_RESET)."
	read -p "Do you really want to merge? (y/n): " yn
	if [ "$yn" != "y" ];then
		echo "Aborting..."
		refresh
		return
	fi
	echo "Checking out master.."
	echo -e $COL_MAGENTA"git checkout master $COL_RESET"
	git checkout master
	echo  -e "Merging $COL_GREEN $BRANCH $COL_RESET into $COL_YELLOW master $COL_RESET."
	echo -e $COL_MAGENTA"git merge $BRANCH $COL_RESET"
	git merge $BRANCH
	echo "Pushing to remote master"
	IFS=$'\n'
	arr=($(git remote -v |grep "(push)"| sed 's/:.*//'))
	unset IFS

	for i in "${arr[@]}"
	do
		DST=`echo $i | cut -d " " -f1`
		read -p "Push to master? (y/n):" yn
		if [ "$yn" == "y" ]; then
			echo -e $COL_MAGENTA"git push $DST master $COL_RESET"
			git push $DST master
		fi

	done
	echo -e $COL_MAGENTA"git checkout $BRANCH $COL_RESET"
	git checkout $BRANCH
	refresh
}

checkout()
{
	BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`
	IFS=$'\n'
	arr=($(git branch | grep -v "*" | grep -v "grep" | cut -d '*' -f2 | xargs))
	unset IFS
	PS3=`echo -e $COL_YELLOW"Choose a branch ($COL_MAGENTA checkout $COL_RESET): "$COL_RESET`
	counter=0
	for i in "${arr[@]}"
	do
		DST=`echo $i`
		options2[$counter]=$DST
		counter=$((counter+1))
	done
	options2[$counter]="Back to main menu"

	select opt2 in "${options2[@]}"
	do
		if [ "$opt2" == "Back to main menu" ]; then
			refresh
			return
		fi
		echo -e $COL_MAGENTA"git checkout $opt2 $COL_RESET"
		git checkout $opt2
		return
	done
	refresh
}

merge_destination_branch()
{
	BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`

	if [ "$BRANCH" == "master" ];then
		echo "It is not good practice to merge 'master' into another branch."
		echo "Consider using 'Merge Working Branch' instead."
		echo "Aborting..."
		refresh
		return
	fi
	echo -e "You are about to merge the contents of ($COL_GREEN $BRANCH $COL_RESET) into another branch"
	IFS=$'\n'
	arr=($(git branch | grep -v "*" | grep -v "grep" | cut -d '*' -f2 | xargs))
	unset IFS
	PS3=`echo -e $COL_YELLOW"Choose a destination branch ($COL_MAGENTA merge $COL_RESET): "$COL_RESET`
	counter=0
	for i in "${arr[@]}"
	do
		DST=`echo $i`
		options2[$counter]=$DST
		counter=$((counter+1))
	done
	options2[$counter]="Back to main menu"

	select opt2 in "${options2[@]}"
	do
		if [ "$opt2" == "Back to main menu" ]; then
			refresh
			return
		fi
		echo -e $COL_MAGENTA"git merge $opt2 $COL_RESET"
		#echo git merge $opt2
		echo "Checking out $opt2: "
		echo -e $COL_MAGENTA"git checkout $opt2 $COL_RESET"
		git checkout $opt2
		echo "Merging $BRANCH into $opt2"
		echo -e $COL_MAGENTA"git merge $BRANCH $COL_RESET"
		git merge $BRANCH
		echo -e $COL_MAGENTA"git checkout $BRANCH $COL_RESET"
		git checkout $BRANCH
		refresh
		return
	done
}

merge_working_branch()
{
	BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`
	IFS=$'\n'
	arr=($(git branch | grep -v "*" | grep -v "grep" | cut -d '*' -f2 | xargs))
	unset IFS
	PS3=`echo -e $COL_YELLOW"Choose a branch ($COL_MAGENTA merge $COL_RESET): "$COL_RESET`
	counter=0
	for i in "${arr[@]}"
	do
		DST=`echo $i`
		options2[$counter]=$DST
		counter=$((counter+1))
	done
	options2[$counter]="Back to main menu"

	select opt2 in "${options2[@]}"
	do
		if [ "$opt2" == "Back to main menu" ]; then
			refresh
			return
		fi
		echo -e "You are about to merge the contents of ($COL_GREEN $opt2 $COL_RESET) into ($COL_GREEN $BRANCH $COL_RESET)"
		read -p "Do you want to proceed? (y/n)" yn
		if [ "$yn" != "y" ]; then
			echo "Aborting..."
			refresh
			return
		fi
		echo "Merging $opt2 into $BRANCH"
		echo -e $COL_MAGENTA"git merge $opt2 $COL_RESET"
		git merge $opt2
		refresh
		return
	done
}

delete_branch()
{
	ESC_SEQ="\x1b["
	COL_RESET=$ESC_SEQ"39;49;00m"
	COL_GREEN=$ESC_SEQ"32;01m"
	BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`
	echo "You are about to permanetly delete a branch."
	echo "You cannot delete 'master' and 'develop' branches using this tool for security purposes."
	echo "Below is the list of branches this tool is able to delete:"
	git branch | grep -v "master" | grep -v "develop"
	read -p "Type the branch name you want to delete or leave in blank to cancel the operation:" bname
	if [ "$bname" == "master" ];then
		echo "You cannot delete the branch $COL_GREEN($bname)$COL_REST using this tool."
		echo "Aborting..."
		refresh
		return
	fi
	if [ "$bname" == "develop" ];then
		echo "You cannot delete the branch ($bname) using this tool."
		echo "Aborting..."
		refresh
		return
	fi
	if [ "$bname" == "" ];then
		refresh
		return
	fi
	echo -e $COL_MAGENTA"git branch -d $bname $COL_RESET"
	git branch -d $bname
	refresh
}

push()
{
	BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`
	IFS=$'\n'
	arr=($(git remote -v |grep "(push)"| sed 's/:.*//'))
	unset IFS
	PS3=`echo -e $COL_BLUE"Choose the remote repository ($COL_MAGENTA push $COL_RESET): "$COL_RESET`
	counter=0
	for i in "${arr[@]}"
	do
		DST=`echo $i | cut -d " " -f1`
		options2[$counter]=$DST
		counter=$((counter+1))
	done
	options2[$counter]="Back to main menu"

	select opt2 in "${options2[@]}"
	do
		if [ "$opt2" == "Back to main menu" ]; then
			refresh
			return
		fi
		echo -e $COL_MAGENTA"git push $opt2 $BRANCH $COL_RESET"
		git push $opt2 $BRANCH
	done
	refresh
}

pull()
{
	BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`
	IFS=$'\n'
	arr=($(git remote -v |grep "(push)"| sed 's/:.*//'))
	unset IFS
	PS3=`echo -e $COL_BLUE"Choose the remote repository ($COL_MAGENTA pull $COL_RESET): "$COL_RESET`
	counter=0
	for i in "${arr[@]}"
	do
		DST=`echo $i | cut -d " " -f1`
		options2[$counter]=$DST
		counter=$((counter+1))
	done
	options2[$counter]="Back to main menu"

	select opt2 in "${options2[@]}"
	do
		if [ "$opt2" == "Back to main menu" ]; then
			refresh
			return
		fi
		echo -e $COL_MAGENTA"git pull $opt2 $BRANCH $COL_RESET"
		git pull $opt2 $BRANCH
		return
	done
	refresh
}

status()
{
echo -e $COL_MAGENTA"git status $COL_RESET"
git status
refresh
}

log()
{
	echo "Showing last 10 commits.."
	echo -e $COL_MAGENTA"git log --graph --decorate --pretty=oneline --abbrev-commit --all $COL_RESET"
	git log --graph --decorate --pretty=oneline --abbrev-commit --all
	refresh
}

list_branch()
{
	echo -e $COL_MAGENTA"git branch --all $COL_RESET"
	git branch
	refresh
}

about()
{
	echo "  ____ _ _    ____           _    "
	echo " / ___(_) |_ / ___| ___  ___| | __"
	echo "| |  _| | __| |  _ / _ \/ _ \ |/ /"
	echo "| |_| | | |_| |_| |  __/  __/   < "
	echo " \____|_|\__|\____|\___|\___|_|\_\\"
	echo ""
	echo "Git Geek - A simple bash script utility to speed up the repetitive daily git commands."
	echo "Author: Jefferson Cechinel"
	echo "E-mail: jefferson@homeyou.com"
	echo "Project Website: https://github.com/jeffersoncechinel/dev-scripts.git"
	echo ""
}

refresh()
{
    refresh
}

ps3()
{
	CUR_BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`
	PWD=`basename "$PWD"`
	PS3=`printf "\nWorking in project ($COL_GREEN $PWD $COL_RESET) branch ($COL_GREEN $CUR_BRANCH $COL_RESET)\n"$COL_BLUE"Please enter your option number$COL_RESET : "`
}

ps3

options=("Show Status" "Commit" "Commit and Push" "Auto Commit and Push" "Push" "Pull" "List Branches" "Checkout Branch" "Merge Working Branch" "Merge Destination Branch" "Delete Branch" "Merge and Deploy" "Show Remotes" "Log" "About" "Quit")
select opt in "${options[@]}"
do
    case $opt in
    	"Show Status")
    	    status
    	    ps3
    	    ;;
    	"Commit")
            commit
            ps3
            ;;
        "Commit and Push")
            commitpush
            ps3
            ;;
        "Auto Commit and Push")
            autocommit
            ps3
            ;;
        "Push")
			push
			ps3
			;;
		"Pull")
			pull
			ps3
			;;
        "List Branches")
			git branch
			ps3
            ;;
        "Checkout Branch")
			checkout
			ps3
            ;;
        "Merge Working Branch")
			merge_working_branch
			ps3
            ;;
        "Merge Destination Branch")
			merge_destination_branch
			ps3
            ;;
        "Delete Branch")
			delete_branch
			ps3
            ;;
        "Merge and Deploy")
            merge_deploy
            ps3
            ;;
        "Show Remotes")
			git remote -v
			ps3
            ;;
        "Log")
			log
			ps3
            ;;
        "About")
			about
			ps3
            ;;
        "Quit")
			exit
            ;;
        *) echo "Invalid Option! - Press enter to see command list.";;
    esac
done