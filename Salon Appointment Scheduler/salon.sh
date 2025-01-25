#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\nWelcome to the Salon! How can we help you today?\n"

# Display services
echo -e "\nAvailable services:"
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# Prompt for service
while true; do
  echo -e "\nEnter the service ID for the service you'd like:"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid service. Please select a valid service."
    echo -e "\nAvailable services again:"
    echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
  else
    break
  fi
done

# Prompt for customer phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_ID ]]; then
  # New customer
  echo -e "\nYou're not in our system. What's your name?"
  read CUSTOMER_NAME

  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

# Prompt for appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME appointment?"
read SERVICE_TIME

# Insert appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirm appointment
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
