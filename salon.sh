#!/bin/bash

PSQL="psql -t -A --username=freecodecamp --dbname=salon -c"

#echo $($PSQL "TRUNCATE TABLE services")

echo -e "\n ~~~~~ MY SALON ~~~~~\nWelcome to My Salon, how can I help you?\n"

#echo $($PSQL "SELECT * FROM services;") | while IFS=' ' read row
#do
#  echo -e "$row\n"
#done

function SERVICES() {

  if [[ $1 ]]
  then
    echo "$1"
  fi

  LIST=$($PSQL "SELECT * FROM services;")
  for ROW in ${LIST} 
  do
    echo "$ROW" | sed 's/|/) /'
  done

  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  #echo "service name: $SERVICE_NAME"
  if [[ -z $SERVICE_NAME ]]
  then
    SERVICES "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # insert customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
      #get id
      if [[ $INSERT_CUSTOMER_RESULT == 'INSERT 0 1' ]]
      then
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      fi
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
    fi

    # get time for appointment
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME
    # insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, service_id, customer_id) VALUES('$SERVICE_TIME', $SERVICE_ID_SELECTED, $CUSTOMER_ID);")
    if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
    then
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
    
  fi
}

SERVICES


