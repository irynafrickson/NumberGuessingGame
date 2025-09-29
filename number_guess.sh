#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate random number
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

# ask user name
echo "Enter your username:"
read USERNAME

# check if username in database
USER_ID=$($PSQL "SELECT user_id FROM number_guess WHERE username = '$USERNAME';")

# if not in database
if [[ -z $USER_ID ]]
then
  FIRST_TIME=true
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  FIRST_TIME=false
  # get games info for the user
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM number_guess WHERE user_id = $USER_ID;")
  BEST_GAME=$($PSQL "SELECT best_game FROM number_guess WHERE user_id = $USER_ID;")
  # print user games info
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi  

# prompt for a guess
echo "Guess the secret number between 1 and 1000:"
GUESSED=false
NUMBER_GUESSES=0

# until right answer
until [[ $GUESSED == "true" ]];
do 
  read GUESS
  # increment number of guesses
  ((NUMBER_GUESSES++))

  # if input is not an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    # compare to the random number
    if [[ $GUESS -eq $RANDOM_NUMBER ]]
    then
      GUESSED=true
      echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    else
      # if input is higher
      if [[ $GUESS -gt $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      else
        # input is lower
        echo "It's higher than that, guess again:"
      fi
    fi  
  fi
done

# update database
# if new user
if [[ $FIRST_TIME == "true" ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO number_guess(username, games_played, best_game) VALUES ('$USERNAME', 1, $NUMBER_GUESSES);")
else
  # returning user
  ((GAMES_PLAYED++))
  UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE number_guess SET games_played = $GAMES_PLAYED WHERE user_id = $USER_ID;")
  # if played better this time
  if [[ "$BEST_GAME" -gt "$NUMBER_GUESSES" ]]
  then
    UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE number_guess SET best_game = $NUMBER_GUESSES WHERE user_id = $USER_ID;")
  fi
fi  