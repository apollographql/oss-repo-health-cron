#!/usr/bin/env bash

WEEKLY_SLACK_BOT_MESSAGE_PRS=""

ALL_PRS=$(gh pr list --search "${FILTERED_OUT_LABELS}" --limit 1000 --json number --jq '[.[] | .number]')

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
      WEEKLY_SLACK_BOT_MESSAGE_PRS="${WEEKLY_SLACK_BOT_MESSAGE_PRS}\n*<${PR_URL//\"}|${pr//,}>*"
      echo "Has new comments: ${pr//,}"
    fi
  fi
done

echo "WEEKLY_SLACK_BOT_MESSAGE_PRS=${WEEKLY_SLACK_BOT_MESSAGE_PRS}" >> "$GITHUB_OUTPUT"