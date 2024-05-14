#!/usr/bin/env bash

WEEKLY_SLACK_BOT_MESSAGE_ISSUES=""

ALL_ISSUES=$(gh issue list --state all --limit 1000 --json number --jq '[.[] | .number]')

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
      WEEKLY_SLACK_BOT_MESSAGE_ISSUES="${WEEKLY_SLACK_BOT_MESSAGE_ISSUES}\n*<${ISSUE_URL//\"}|${issue//,}>*"
      echo "Has new comments: ${issue//,}"
    fi
  fi
done

echo "WEEKLY_SLACK_BOT_MESSAGE_ISSUES=${WEEKLY_SLACK_BOT_MESSAGE_ISSUES}" >> "$GITHUB_OUTPUT"