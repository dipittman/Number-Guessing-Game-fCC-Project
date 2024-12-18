#!/bin/bash

RANDOM_NUMBER=$(( (RANDOM % 1000) + 1 ))

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_data WHERE username='$USERNAME';")
BEST_GAME=$($PSQL "SELECT best_game FROM user_data WHERE username='$USERNAME';")

if [[ -z $GAMES_PLAYED ]]
then
  #insert new user
  INSERT_USER=$($PSQL "INSERT INTO user_data(username) VALUES('$USERNAME');")
  #display message
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
NUM_OF_GUESSES=0

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  read USER_GUESS
  
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not an integer, guess again:"
  else
    if [[ $USER_GUESS -gt $RANDOM_NUMBER ]]
    then
      ((NUM_OF_GUESSES++))
      MAIN_MENU "It's lower than that, guess again:"
    else
      if [[ $USER_GUESS -lt $RANDOM_NUMBER ]]
      then
        ((NUM_OF_GUESSES++))
        MAIN_MENU "It's higher than that, guess again:"
      else
        if [[ $USER_GUESS -eq $RANDOM_NUMBER ]]
        then
          ((NUM_OF_GUESSES++))
          ((GAMES_PLAYED++))
          echo "You guessed it in $NUM_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
          #add 1 to games_played and add to database
          if [[ -z $BEST_GAME ]]
          then
            UPDATE_INITIAL_DATA=$($PSQL "UPDATE user_data SET games_played = 1, best_game = $NUM_OF_GUESSES WHERE username='$USERNAME';")
          else
            UPDATE_GAMES_PLAYED=$($PSQL "UPDATE user_data SET games_played = $GAMES_PLAYED WHERE username='$USERNAME';")
            if [[ $NUM_OF_GUESSES -lt $BEST_GAME ]]
            then
              UPDATE_BEST_GAME=$($PSQL "UPDATE user_data SET best_game = $NUM_OF_GUESSES WHERE username='$USERNAME';")
            fi
          fi
        fi
      fi
    fi
  fi
}

MAIN_MENU