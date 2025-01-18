#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
 Truncate tables
echo $($PSQL "TRUNCATE TABLE games, teams")

# Read games.csv
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    if [[ $YEAR != "year" ]]
    then
        # Insert unique teams
        for TEAM in "$WINNER" "$OPPONENT"
        do
            TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
            if [[ -z $TEAM_ID ]]
            then
                INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")
                echo "Inserted team: $TEAM"
            fi
        done

        # Get team IDs
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

        # Insert game
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
        echo "Inserted game: $YEAR $ROUND - $WINNER vs $OPPONENT"
    fi
done