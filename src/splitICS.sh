#!/usr/bin/env bash
# 
# A simple script to split a large ICS file into multiple smaller files, suitable for uploading to Radicale.
#
# @author: Navarro Torres, Agustín
# @date: 2026-01-07
# @version: 0.0.1

[ $# -ne 2 ] && >&2 echo "Usage: splitICS.sh [ics] [prefix]" && exit 1

[ ! -f "$1" ] && 2>&2 echo "File $1 does not exists" && exit 1

NEW_CALENDAR="$2"
NFILE=""

while IFS= read -r line; do
  line=$(echo "$line" | tr -d '\r')

  if [ "$line" = "BEGIN:VEVENT" ]; then
    NFILE="$NEW_CALENDAR$(uuidgen -t)"".ics"
    echo "BEGIN:VCALENDAR" > "$NFILE"
    echo "VERSION:2.0" >> "$NFILE"
    echo "PRODID:-//Radicale//NONSGML Version 3.5.8//EN" >> "$NFILE"
    echo "BEGIN:VEVENT" >> "$NFILE"
  elif [[ -z "$NFILE" ]]; then continue
  elif [ "$line" = "END:VEVENT" ]; then
    echo "END:VEVENT" >> "$NFILE"
    echo "END:VCALENDAR" >> "$NFILE"
  elif [[ "$line" == "END:VCALENDAR" ]]; then exit
  else
    echo "$line" >> "$NFILE"
  fi
done < "$1"
