#!/usr/bin/env bash

## Once a week on Wednesdays during on-call handoff
## get outgoing/incoming Slack handles for on-call engineer and
## log list of issues and PRs with new comments in the last 7 days

DATE_YESTERDAY=$(date -j -v-1d '+%Y-%m-%d')
DATE_2_DAYS_AGO=$(date -j -v-2d '+%Y-%m-%d')
DATE_7_DAYS_AGO=$(date -j -v-7d '+%Y-%m-%d')

DATE_TOMORROW=$(date -j -v+1d '+%Y-%m-%d')
DATE_2_DAYS_IN_FUTURE=$(date -j -v+2d '+%Y-%m-%d')

ALL_ISSUES=$(gh issue list --limit 1000 --json number --jq '[.[] | .number]')
ALL_PRS=$(gh pr list --search "${FILTERED_OUT_LABELS}" --limit 1000 --json number --jq '[.[] | .number]')

CARETAKER_HANDOFF_SLACK_BOT_MESSAGE_ISSUES=""
CARETAKER_HANDOFF_SLACK_BOT_MESSAGE_PRS=""

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

for issue in $(echo -e $ALL_ISSUES | jq -s 'flatten(1)')
do
  if [ "$issue" = "[" ] || [ "$issue" = "]" ]; then
    :
  else
    ISSUE_DETAILS=$(gh issue view ${issue//,} --json comments,url)
    ISSUE_URL=$(jq '. | .url' <<< $ISSUE_DETAILS)

    ISSUE_COMMENTS=$(jq --arg DATE "$DATE_7_DAYS_AGO" '. | [.comments[] | select(.createdAt >= $DATE)] | length' <<< $ISSUE_DETAILS)

    if [ "$ISSUE_COMMENTS" = "0" ]; then
      echo "No new comments in the last 7 days: ${issue//,}"
    else
      CARETAKER_HANDOFF_SLACK_BOT_MESSAGE_ISSUES="${CARETAKER_HANDOFF_SLACK_BOT_MESSAGE_ISSUES}\n*<${ISSUE_URL//\"}|${issue//,}>*"
      echo "Has new comments: ${issue//,}"
    fi
  fi
done

for pr in $(echo -e $ALL_PRS | jq -s 'flatten(1)')
do
  if [ "$pr" = "[" ] || [ "$pr" = "]" ]; then
    :
  else
    PR_DETAILS=$(gh pr view ${pr//,} --json comments,url)
    PR_URL=$(jq '. | .url' <<< $PR_DETAILS)

    PR_COMMENTS=$(jq --arg DATE "$DATE_7_DAYS_AGO" '. | [.comments[] | select(.author.login != "apollo-cla" and .createdAt >= $DATE)] | length' <<< $PR_DETAILS)

    if [ "$PR_COMMENTS" = "0" ]; then
      echo "No new comments in the last 7 days: ${pr//,}"
    else
      CARETAKER_HANDOFF_SLACK_BOT_MESSAGE_PRS="${CARETAKER_HANDOFF_SLACK_BOT_MESSAGE_PRS}\n*<${PR_URL//\"}|${pr//,}>*"
      echo "Has new comments: ${pr//,}"
    fi
  fi
done

echo "CARETAKER_HANDOFF_SLACK_BOT_MESSAGE_ISSUES=${CARETAKER_HANDOFF_SLACK_BOT_MESSAGE_ISSUES}" >> "$GITHUB_OUTPUT"
echo "CARETAKER_HANDOFF_SLACK_BOT_MESSAGE_PRS=${CARETAKER_HANDOFF_SLACK_BOT_MESSAGE_PRS}" >> "$GITHUB_OUTPUT"

echo "OUTGOING_CARETAKER_SLACK_HANDLE=${OUTGOING_CARETAKER_SLACK_HANDLE}" >> "$GITHUB_OUTPUT"
echo "INCOMING_CARETAKER_SLACK_HANDLE=${INCOMING_CARETAKER_SLACK_HANDLE}" >> "$GITHUB_OUTPUT"
