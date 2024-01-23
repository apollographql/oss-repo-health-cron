#!/usr/bin/env bash

## Once a week on Wednesdays during on-call handoff
## get outgoing/incoming Slack handles for on-call engineer and
## log list of issues and PRs with new comments in the last 7 days

PD_OUTGOING=$(curl --request GET \
  --url "https://api.pagerduty.com/schedules/PWFDVT5/users?since=${DATE_2_DAYS_AGO}&until=${DATE_YESTERDAY}" \
  --header 'Accept: application/json' \
  --header "Authorization: Token token=${PD_TOKEN}" \
  --header 'Content-Type: application/json')

PD_INCOMING=$(curl --request GET \
  --url "https://api.pagerduty.com/schedules/PWFDVT5/users?since=${DATE_TOMORROW}&until=${DATE_2_DAYS_IN_FUTURE}" \
  --header 'Accept: application/json' \
  --header "Authorization: Token token=${PD_TOKEN}" \
  --header 'Content-Type: application/json')

OUTGOING_USER_EMAIL=$(jq '.users[0] | .email' <<< $PD_OUTGOING)
INCOMING_USER_EMAIL=$(jq '.users[0] | .email' <<< $PD_INCOMING)

OUTGOING_CARETAKER_SLACK_HANDLE=""
INCOMING_CARETAKER_SLACK_HANDLE=""

# TODO: use a proper map here - couldn't get this working in bash

# NB: need to use Slack user ID here in order to @-mention via their "blocks" API
if [ "${OUTGOING_USER_EMAIL//\"}" == "jerel.miller@apollographql.com" ]; then
  OUTGOING_CARETAKER_SLACK_HANDLE="U042QURCXN2"
elif [ "${OUTGOING_USER_EMAIL//\"}" == "alessia@apollographql.com" ]; then
  OUTGOING_CARETAKER_SLACK_HANDLE="U03KL3M1BV1"
elif [ "${OUTGOING_USER_EMAIL//\"}" == "lorenz.weber-tronic@apollographql.com" ]; then
  OUTGOING_CARETAKER_SLACK_HANDLE="U04M0FY4KCK"
fi

if [ "${INCOMING_USER_EMAIL//\"}" == "jerel.miller@apollographql.com" ]; then
  INCOMING_CARETAKER_SLACK_HANDLE="U042QURCXN2"
elif [ "${INCOMING_USER_EMAIL//\"}" == "alessia@apollographql.com" ]; then
  INCOMING_CARETAKER_SLACK_HANDLE="U03KL3M1BV1"
elif [ "${INCOMING_USER_EMAIL//\"}" == "lorenz.weber-tronic@apollographql.com" ]; then
  INCOMING_CARETAKER_SLACK_HANDLE="U04M0FY4KCK"
fi

echo "OUTGOING_CARETAKER_SLACK_HANDLE=${OUTGOING_CARETAKER_SLACK_HANDLE}" >> "$GITHUB_OUTPUT"
echo "INCOMING_CARETAKER_SLACK_HANDLE=${INCOMING_CARETAKER_SLACK_HANDLE}" >> "$GITHUB_OUTPUT"
