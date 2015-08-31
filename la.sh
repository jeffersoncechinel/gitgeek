#!/bin/sh
# ==================================================================
#
# .d88888b  dP                      dP
# 88.    "' 88                      88
# `Y88888b. 88  .dP  dP    dP .d888b88 .d8888b. .d8888b.
#       `8b 88888"   88    88 88'  `88 88ooood8 88'  `88
# d8'   .8P 88  `8b. 88.  .88 88.  .88 88.  ... 88.  .88
#  Y88888P  dP   `YP `8888P88 `88888P8 `88888P' `88888P'
# oooooooooooooooooooo~~~~.88~ooooooooooooooooooooooooooo
#                     d8888P                        Inc
#
# @Author: Jefferson Cechinel
# @Email: jefferson@homeyou.com
# @Date:   2015-08-31 20:22:32
# @Last Modified by:   jefferson
# @Last Modified time: 2015-08-31 20:31:24
#
# ------------------------------------------------------------------
IFS=$'\n'
arr=($(git branch | grep -v "*" | grep -v "grep" | cut -d '*' -f2 | xargs))
unset IFS
PS3=`echo -e $COL_BLUE"Choose a destination branch ($COL_MAGENTA merge $COL_RESET): "$COL_RESET`
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
		echo -e $COL_CYAN"Leave it blank and PRESS ENTER to refresh the command list."
		return
	fi
	echo -e "$COL_MAGENTA git merge $opt2 $COL_RESET"
	#echo git merge $opt2
done