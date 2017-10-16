#!/bin/bash

if [[ $# -gt 1 ]] #if statements check that there is only 1 process ID provided and that it is entirely numerical
then
echo "You have entered too many process IDs. Please enter only one, I am not that amazing."
elif [[ $# -eq 0 ]]
then
echo "You have not entered a process ID. Please enter a single process ID."
elif [[ $1 =~ ^-?[0-9]+$ ]]
then 
	inputid=${1}  #sets inputid to the provided argument
	cmdname=`ps -o cmd fp $inputid | tail -1` #list command name for given PID
	echo "The command name is ${cmdname}."
	
	echo =================================================================

	if [[  ${inputid} -eq 1 ]]
	then
		echo "There is no parent/grandparent/great grandparent process."
		echo =================================================================
	else 
		export parentid=`ps -l $inputid | awk '{print $5}' | tail -1`
		parentcmdname=`ps -o cmd fp $parentid | tail -1`
		echo "The parent process ID is: ${parentid}. The command is ${parentcmdname}. "
		echo =================================================================	
		if [[  ${parentid} -eq 1 ]]
        	then
            		echo "There is no grandparent/great grandparent process."
			echo =================================================================
        	else
			export gparentid=`ps -l $parentid | awk '{print $5}' | tail -1` #gparentcmdname=`ps -o cmd fp $gparentid | tail -1`
			gparentcmdname=`ps -o cmd fp $gparentid | tail -1`
			echo "The grandparent process ID is: ${gparentid}. The command is ${gparentcmdname}. "
			echo =================================================================	
			if [[ ${gparentid} -eq 1 ]]
			then 
				echo "There is no grandparent process."
				echo =================================================================
			else 
				export grgparentid=`ps -l $gparentid | awk '{print $5}' | tail -1`
				grgparentcmdname=`ps -o cmd fp $grgparentid | tail -1`
				echo "The greatgrandparent process ID is: ${grgparentid}. The command is ${grgparentcmdname}. "
				echo =================================================================	
			fi
 	       fi
	fi
	
	echo Network statistics for these processes are as follows:
	sudo netstat -anp | egrep "(ESTABLISHED)[[:space:]](${grgparentid}\/|${gparentid}\/|${parentid}\/|${inputid}\/)"  #grep netstat for the given PID having set the flags to show the PID
	echo =================================================================

	pgrep -P ${inputid}>childinfo.ls 	
	
	if ! [[ -s  childinfo.ls  ]] 
	then
	echo "The process ${inputid} has no child processes"
	else 	
		for i in `pgrep -P ${inputid}`
		do
			echo A child process of ${inputid} has ID ${i}, with the command `ps -o cmd fp $i |tail -1`
			echo It has network activty as follows:
			sudo netstat -anp | egrep "(ESTABLISHED)[[:space:]](${i}/)" 
			for x in `pgrep -P ${i}`
			do	
				echo A child process of ${i} has ID ${x}, with the command `ps -o cmd fp $x |tail -1`
				echo It has network activty as follows:
				sudo netstat -anp | egrep "(ESTABLISHED)[[:space:]](${x}/)"
		        	for y in `pgrep -P ${x}`
		        	do	
					echo A child process of ${x} has ID ${y}, with the command `ps -o cmd fp $y |tail -1`
					echo It has network activty as follows:
					sudo netstat -anp | egrep "(ESTABLISHED)[[:space:]](${y}/)"
					echo ==========
		        	done	       
				echo ===============
			done
			echo ====================
		done
	fi

else
	echo "You have not grasped the concept of a number. Please enter a single process ID in digits."
fi
