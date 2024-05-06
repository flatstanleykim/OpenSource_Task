#! /bin/bash

if [ $# -ne 3 ]
then
	echo "usage: ./2024-OSS-Project1.sh file1 file2 file3"
	exit 1
fi
echo "************OSS1 - Project1************"
echo "*         StudentID : 12201707        *"
echo "*         Name : SeHwan Kim           *"
echo "***************************************"
echo ""
teams=$1
players=$2
matches=$3
chmod +x $teams
chmod +x $players
chmod +x $matches
stop="N"
until [ "$stop" = "Y" ]
do
	echo ""
	echo "[MENU]"
	echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
	echo "2. Get the team data to enter a league position in teams.csv"
	echo "3. Get the Top-3 Attendance matches in mateches.csv"
	echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
	echo "5. Get the modified format of date_GMT in matches.csv"
	echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
	echo "7. Exit"

	read -p "Enter your CHOICE (1~7) : " NUM

	case "$NUM" in
		1)
			read -p "Do you want to get the Heung-Min Son's data? (y/n) :" ANS
			if [ $ANS = "y" ]
			then
				team=$(awk -F',' '$1=="Heung-Min Son" {printf("Team:%s, Apperance:%s, Goal:%s, Assist:%s", $4, $6, $7, $8)}' "$players")
				echo "$team"
			fi;;
		2)
			read -p "What do you want to get the team data of league_position[1~20] :" POS
			pos=$(awk -v POS="$POS" -F',' '$6==POS {printf("%s %s %.6f\n", $6, $1, $2/($2+$3+$4))}' "$teams")
			echo "$pos";;
		
		3)
			read -p "Do you want to know Top-3 attendance data and average attendance? (y/n) :" TOPATT
			if [ $TOPATT = "y" ]
			then
				echo "***Top-3 Attendance Match***"
				i=1
				until [ $i -gt 3 ]
				do
					topatt=$(cat "$matches" | sort -r -n -t',' -k 2 | awk -v i="$i" -F',' 'NR==i {printf("%s vs %s (%s)", $3, $4, $1)}')

					tpatt=$(cat "$matches" | sort -r -n -t',' -k 2 | awk -v i="$i" -F',' 'NR==i {printf("%s %s", $2, $7)}')
					echo ""
					echo "$topatt"
					echo "$tpatt"
					let i=i+1
				done
			fi;;
		4)
			read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) :" TEAMSCORE
			if [ $TEAMSCORE = "y" ]
			then
				
				i=$(cat "$teams" | awk '{print NR}')
				for var in $i
				do				
					if [ "$var" != "1" ]
					then
						team=$(cat "$teams" | sort -n -t',' -k 6 | awk -v i="$var" -F',' 'NR==i {printf("%s", $1)}')
						pos=$(cat "$teams" | sort -n -t',' -k 6 | awk -v i="$var" -F',' 'NR==i {printf("%s", $6)}')
			
						echo ""
						echo "$pos" "$team"
						num=1
						bre="N"
						count="N"
						until [ $bre = "Y" ]
						do
						
							play=$(cat "$players" | sort -n -r -t',' -k 7,7 | awk -v i="$num" -v t="$team" -F',' 'NR==i && $4==t {printf("%s %s\n", $1, $7)}')
 
							if [ -n "$play" ]
							then
								
								count="Y"
							fi
							
							if [ $count = "Y" ]
							then	
								echo "$play"
								bre="Y"
							fi							
							let num=num+1
						done
					fi
				
				done		

			fi;;
		5)
			read -p "Do you want to modify the format of date? (y/n) :" MODIFY
			if [ $MODIFY = "y" ]
			then
				i=$(cat "$matches" | awk '{print NR}')
				touch f1.csv
				f1=f1.csv
				for var in $i
				do
					if [ $var = 1 ]
					then
						first=$(cat "$matches" | head -n 1)
						echo "$first" >> "$f1"
						continue
					fi

					date=$(cat "$matches" | awk -v num="$var" -F',' 'NR==num {print $1}')

					month=$(echo "$date" | awk -F' ' '{print $1}')
					case $month in
						Jan)
							month=01;;
						Feb)
							month=02;;
						Mar)
							month=03;;
						Apr)
							month=04;;
						May)
							month=05;;
						Jun)
							month=06;;
						Jul)
							month=07;;
						Aug)
							month=08;;
						Sep)
							month=09;;
						Oct)
							month=10;;
						Nov)
							month=11;;
						Dec)
							month=12;;
						*)
							echo "not a month";;
					esac
					change=$(echo "$date" | awk -v mon="$month" -F' ' '{printf("%s/%s/%s %s",$3, mon, $2, $5)}')
					new=$(cat "$matches" | awk -v num="$var" -v cha="$change" -F',' 'NR==num {printf("%s,%s,%s,%s,%s,%s,%s", cha, $2, $3, $4, $5, $6, $7)}')
					echo "$new" >> "$f1"
				
				done
				cp "$f1" "$matches"
				k=1
				until [ $k -gt 11 ]
				do
					fix=$(cat "$matches" | awk -v n="$k" -F',' 'NR==n {print $1}')
					echo "$fix"
					let k=k+1
				done
				
			fi;;
		6)			
			team=$(cat "$teams" | awk -F',' 'NR!=1&&NR<=11 {print $1}')
			cnt=1
			cnt2=11
			IFS=$'\n'
			for var in $team
			do
				line=$(echo -n "$var" | wc -c)
				t1=$(cat "$teams" | awk -v i="$cnt" -F',' 'NR==i+1 {print $1}')
				t2=$(cat "$teams" | awk -v i="$cnt2" -F',' 'NR==i+1 {print $1}')
				let line=30-line
				if [ $cnt -lt 10 ]
				then
					cnt=" $cnt"
				fi
				echo "$cnt) $t1$(printf '%*s' $line)$cnt2) $t2"
				let cnt=cnt+1
				let cnt2=cnt2+1				

			done			
			read -p "Enter your team number :" TEAMNUM
			winteam=$(cat "$teams" | awk -v n="$TEAMNUM" -F',' 'NR==n+1 {print $1}')
			
			winscore=$(cat "$matches" | awk -v t="$winteam" -F',' '$3==t {print $5-$6}')
			
			max=-99
			for var2 in $winscore
			do
				if [ $var2 -gt $max ]
				then
					max=$var2
				fi	
			done
			winrow=$(cat "$matches" | awk -v t="$winteam" -v m="$max" -F',' '$3==t&&($5-$6)==m {printf("\n%s\n%s %s vs %s %s\n", $1, $3, $5, $6, $4)}')
			echo "$winrow"
			



			;;
		

		7)
			echo "Bye!"
			echo ""
			stop="Y";;
		*)
			echo "ERRO: Invalid option..."
			read -p "Press [Enter]..." Key;;
	esac
done
exit 0
