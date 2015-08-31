IFS=$'\n'
arr=($(git remote -v |grep "(push)"| sed 's/:.*//'))
unset IFS

for i in "${arr[@]}"
do
	echo $i | cut -d " " -f1
done
