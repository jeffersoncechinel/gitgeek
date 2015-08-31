#!/bin/sh
# ==================================================================
# @Author: Jefferson Cechinel
# @Email: jefferson@homeyou.com
# @Date:   2015-08-30 16:26:28
# @Last Modified by:   jefferson
# @Last Modified time: 2015-08-31 09:24:11
#
# ------------------------------------------------------------------

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

echo ""
echo  -e $COL_YELLOW"GIT Console Helper - Verson 0.1 (Jefferson Cechinel)"$COL_RESET
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
    echo -n "Deleting caching files if any... "
    rm -rf data/log/* data/cache/*.php app/log*
    echo "OK"
    echo "Adding all files.."
	git add .
	echo "Checking git status.."
	git status -s
	echo "Commiting with message: $msg"
	read -p "Perform git commit? (y/n):" yn
	if [ "$yn" != "y" ]; then
		return
	fi
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
			 git push $i $BRANCH
		fi

	done
	#git push origin master
}

autocommit()
{
	msg="Auto commited."
    echo -n "Deleting caching files if any... "
    rm -rf data/log/* data/cache/*.php
    echo "OK"
    echo -n "Adding files.."
	git add .
	echo "OK"
	git commit -a -m "$msg"
	echo "Pushing to all remotes..."
	#git push origin master
}

deploy_production()
{
	echo "You´re about to merge the develop changes into master."
	read -p "Do you really want to deploy to production(master)?" yn
	if [ "$yn" == "n" ];then
		return
	fi
	echo "Checking out master.."
	git checkout master
	echo "Merging develop into master branch..."
	git merge develop
	echo "git push origin master(cmd only)"
}

checkout()
{
	git branch
	read -p "Branch name to checkout: " bcheckout
	git checkout $bcheckout
}

merge()
{
	ESC_SEQ="\x1b["
	COL_RESET=$ESC_SEQ"39;49;00m"
	COL_RED=$ESC_SEQ"31;01m"
	COL_GREEN=$ESC_SEQ"32;01m"
	BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`

	if [ "$BRANCH" == "master" ];then
		echo "It is not good practice to merge 'master' into another branch."
		echo "Please checkout to another branch and try again."
		echo "Aborting..."
		return
	fi
	echo -e "You are about to merge the current branch: $COL_GREEN $BRANCH $COL_RESET"
	echo "You can merge this branch into one of the branches below:"
	git branch | grep -v $BRANCH | grep -v "grep"
	read -p "Type the branch name you want to merge it into:" bname
	if [ "$bname" == "$BRANCH" ];then
		echo "Source and destination branches are the same."
		echo "Aborting..."
		return
	fi
	if [ "$bname" == "" ];then
		echo "Aborting..."
		return
	fi

	echo "Checking out $bname: "
	git checkout $bname
	echo "Merging $BRANCH into $bname"
	git merge $BRANCH
	echo "git push origin $bname(cmd only)"
	echo "git push dropbox $bname(cmd only)"
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
		return
	fi
	if [ "$bname" == "develop" ];then
		echo "You cannot delete the branch ($bname) using this tool."
		echo "Aborting..."
		return
	fi
	if [ "$bname" == "" ];then
		return
	fi
	git branch -d $bname
}

ps3()
{
	CUR_BRANCH=`git branch | grep "*" | grep -v "grep" | cut -d '*' -f2 | xargs`
	PS3=`echo -e $COL_BLUE"Please enter your choice "$COL_RESET"($COL_GREEN $CUR_BRANCH $COL_RESET): "`
}

ps3

options=("Commit and Push" "Auto Commit and Push" "Deploy Production" "List Branches" "Checkout Branch" "Merge Branch" "Delete Branch" "Show Remotes" "About" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Commit and Push")
            commit
            ps3
            ;;
        "Auto Commit and Push")
            autocommit
            ps3
            ;;
        "Deploy Production")
            deploy_production
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
        "Merge Branch")
			merge
			ps3
            ;;
        "Delete Branch")
			delete_branch
			ps3
            ;;
        "Show Remotes")
			git remote -v
			ps3
            ;;
        "About")
			echo "About me"
			ps3
            ;;
        "Quit")
			#break
			exit
            ;;
        *) echo invalid option;;
    esac
done