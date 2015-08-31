IFS=$'\n'
arr=($(git remote -v |grep "(push)"| sed 's/:.*//'))
unset IFS

for i in "${arr[@]}"
do
	DST=`echo $i | cut -d " " -f1`
	echo $DST
done
