#! /bin/bash
# program for salon: maintaining customer's base and appointment scheduler
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~ MY SALON ~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
# wrong service selected message
  if [[ $1 ]] 
  then
  echo -e "\n$1"
  fi

# diplay available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
  echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

# what if the service selected DOESN'T exist:
  SERVICE_AVAILABLE=$($PSQL "SELECT service_id, name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  if [[ -z $SERVICE_AVAILABLE ]]
  then
  MAIN_MENU "Invalid service selected. Please, choose one from the list below:"

# what if the service selected exists:
  else
  # get customer ID
    # ask for phone
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # if this is a new customer, ask for name and update customers base
      if [[ -z $CUSTOMER_ID ]] 
      then
      echo "What is your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_DATA=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      fi

    # ask for an appointment time and update appointment table
      echo "What time is convenient for you?"
      read SERVICE_TIME
      INSERT_APPOINTMENT_DATA=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # display message confirming an appointment
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed -E 's/^ +| +$//')
      CUSTOMER_NAME=$($PSQL "SELECT DISTINCT(name) FROM customers INNER JOIN appointments USING(customer_id) WHERE customer_id = $CUSTOMER_ID" | sed -E 's/^ +| +$//')
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  fi
}
MAIN_MENU

