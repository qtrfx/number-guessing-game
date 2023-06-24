#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$(($RANDOM % 1000+1))
echo "$RANDOM_NUMBER"
echo -e "\n~~~~~ Number Guessing Game ~~~~\n"

USERNAME_MENU () {

if [[ $1 ]]
then
  echo "$1"
fi

echo -e "Enter your username:"
read USERNAME

ENTERED_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME';")

if [[ -z $ENTERED_USERNAME ]]
then
  if [[ ${#USERNAME} == 0 ]] || [[ ${#USERNAME} -gt 20 ]]
  then
    if [[ ${#USERNAME} == 0 ]]
    then
    USERNAME_MENU "Please input a username."
    else
    USERNAME_MENU "Maximum length of usernames is 20 characters."
    fi
  else
    INSERT_NEW_USER=$($PSQL "INSERT INTO users (username) VALUES('$USERNAME');")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
    INSERT_NEW_STATISTIC=$($PSQL "INSERT INTO statistics(user_id) VALUES($USER_ID);")
    ENTERED_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME';")
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  fi
else
GET_USER_DATA=$($PSQL "SELECT games_played, best_game FROM users INNER JOIN statistics USING(user_id) WHERE username='$USERNAME';")
echo "$GET_USER_DATA" | while IFS='|' read GAMES_PLAYED BEST_GAME
do
echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
done
fi

if [[ $ENTERED_USERNAME  ]]
then
  NUMBER_GUESSING_MENU
fi
}

NUMBER_GUESSING_MENU () {
ATTEMPTS=1
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESSED_NUMBER
while [[ $GUESSED_NUMBER -ne $RANDOM_NUMBER ]]
do
if [[ $GUESSED_NUMBER -lt $RANDOM_NUMBER ]] && [[ $GUESSED_NUMBER -gt 0 ]]
then
echo "It's higher than that, guess again:"

elif [[ $GUESSED_NUMBER -gt $RANDOM_NUMBER ]] && [[ $GUESSED_NUMBER -lt 1001 ]]
then
echo "It's lower than that, guess again:"
else
echo "That is not an integer, guess again:"
fi
ATTEMPTS=$(($ATTEMPTS+1))
read GUESSED_NUMBER
done
INSERT_GAMES_PLAYED=$($PSQL "UPDATE statistics SET games_played=$(($GAMES_PLAYED + 1));")
if [[ -z $BEST_GAME ]] 
then
INSERT_RESULT=$($PSQL "UPDATE statistics SET best_game=$ATTEMPTS;")
elif [[ $ATTEMPTS -lt $BEST_GAME ]]
then
INSERT_RESULT=$($PSQL "UPDATE statistics SET best_game=$ATTEMPTS;")
fi
echo -e "\nYou guessed it in $ATTEMPTS tries. The secret number was $RANDOM_NUMBER. Nice job!"
}

USERNAME_MENU
