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
			pos=$(awk -v POS="$POS" -F',' 'NR==POS {printf("%s %s %.6f\n", NR, $1, $2/($2+$3+$4))}' "$teams")
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
				echo "working"
			fi;;
		6)
			read -p "Enter your team number :" TEAMNUM
			echo "$TEAMNUM";;
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
