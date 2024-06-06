#!/usr/bin/env bash

## Once a week on Wednesdays during on-call handoff
## get outgoing/incoming Slack handles for on-call engineer and
## log list of issues and PRs with new comments in the last 7 days

PD_OUTGOING=$(curl --request GET \
  --url "https://api.pagerduty.com/schedules/${PD_WEB_SCHEDULE_ID}/users?since=${DATE_2_DAYS_AGO}&until=${DATE_YESTERDAY}" \
  --header 'Accept: application/json' \
  --header "Authorization: Token token=${PD_TOKEN}" \
  --header 'Content-Type: application/json')

PD_INCOMING=$(curl --request GET \
  --url "https://api.pagerduty.com/schedules/${PD_WEB_SCHEDULE_ID}/users?since=${DATE_TOMORROW}&until=${DATE_2_DAYS_IN_FUTURE}" \
  --header 'Accept: application/json' \
  --header "Authorization: Token token=${PD_TOKEN}" \
  --header 'Content-Type: application/json')

OUTGOING_USER_EMAIL=$(jq '.users[0] | .email' <<< $PD_OUTGOING)
INCOMING_USER_EMAIL=$(jq '.users[0] | .email' <<< $PD_INCOMING)

OUTGOING_CARETAKER_SLACK_HANDLE=""
INCOMING_CARETAKER_SLACK_HANDLE=""

# Weed to use Slack user ID here in order to @-mention via Slack "blocks" API
if [ "${OUTGOING_USER_EMAIL//\"}" == "${JEREL_EMAIL}" ]; then
  OUTGOING_CARETAKER_SLACK_HANDLE=$JEREL_SLACK_ID
elif [ "${OUTGOING_USER_EMAIL//\"}" == "${ALESSIA_EMAIL}" ]; then
  OUTGOING_CARETAKER_SLACK_HANDLE=$ALESSIA_SLACK_ID
elif [ "${OUTGOING_USER_EMAIL//\"}" == "${LENZ_EMAIL}" ]; then
  OUTGOING_CARETAKER_SLACK_HANDLE=$LENZ_SLACK_ID
elif [ "${OUTGOING_USER_EMAIL//\"}" == "${JEFF_EMAIL}" ]; then
  OUTGOING_CARETAKER_SLACK_HANDLE=$JEFF_SLACK_ID
fi

if [ "${INCOMING_USER_EMAIL//\"}" == "${JEREL_EMAIL}" ]; then
  INCOMING_CARETAKER_SLACK_HANDLE=$JEREL_SLACK_ID
elif [ "${INCOMING_USER_EMAIL//\"}" == "${ALESSIA_EMAIL}" ]; then
  INCOMING_CARETAKER_SLACK_HANDLE=$ALESSIA_SLACK_ID
elif [ "${INCOMING_USER_EMAIL//\"}" == "${LENZ_EMAIL}" ]; then
  INCOMING_CARETAKER_SLACK_HANDLE=$LENZ_SLACK_ID
elif [ "${INCOMING_USER_EMAIL//\"}" == "${JEFF_EMAIL}" ]; then
  INCOMING_CARETAKER_SLACK_HANDLE=$JEFF_SLACK_ID
fi

# Update Slack usergroup for @caretaker-web
curl --request POST \
  --url "https://slack.com/api/usergroups.users.update" \
  --header "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data "{\"usergroup\":\"${SLACK_USER_GROUP}\", \"users\":[\"${INCOMING_CARETAKER_SLACK_HANDLE}\"]}"

echo "OUTGOING_CARETAKER_SLACK_HANDLE=${OUTGOING_CARETAKER_SLACK_HANDLE}" >> "$GITHUB_OUTPUT"
echo "INCOMING_CARETAKER_SLACK_HANDLE=${INCOMING_CARETAKER_SLACK_HANDLE}" >> "$GITHUB_OUTPUT"
