IFS=$'\n'
arr=($(git remote -v |grep "(push)"| sed 's/:.*//'))
unset IFS

counter=0
for i in "${arr[@]}"
do
	DST=`echo $i | cut -d " " -f1`
	build_array_value="$build_array_value $DST"
	options[$counter]=$DST
	counter=$((counter+1))
done
options[$counter]="Back to main menu"

select opt in "${options[@]}"
do

	if [ "$opt" == "Back to main menu" ]; then
		echo "Aborting.."
		break
	fi
   #  case $opt in
   #      "Back to main menu")
   #          echo "Aborting.."
   #          echo $opt
   #          ;;
   #      *) echo "git push $opt branch"
			# ;;
   #  esac
done


