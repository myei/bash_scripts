#!/bin/bash

# This is a program that keeps your address book up to date.

friends="/var/tmp/michel/friends"

echo "Hello, "$USER".  This script will register you in Michel's friends database."
read -p $'\e[31mFoobar\e[0m: ' foo
echo -n "Enter your name and press [ENTER]: "
read name
echo -n "Enter your gender and press [ENTER]: "
read -n 1 gender
echo
exit
grep -i "$name" "$friends"

if  [ $? == 0 ]; then
  echo "You are already registered, quitting."
  exit 1
elif [ "$gender" == "m" ]; then
  echo "You are added to Michel's friends list."
  exit 1
else
  echo -n "How old are you? "
  read age
  if [ $age -lt 25 ]; then
    echo -n "Which colour of hair do you have? "
    read colour
    echo "$name $age $colour" >> "$friends" 
    echo "You are added to Michel's friends list.  Thank you so much!"
  else
    echo "You are added to Michel's friends list."
    exit 1
  fi
fi