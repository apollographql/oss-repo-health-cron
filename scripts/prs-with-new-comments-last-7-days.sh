#!/usr/bin/env bash

WEEKLY_SLACK_BOT_MESSAGE_PRS=""
NUM_PRS_WITH_NEW_COMMENTS=0

ALL_PRS=$(gh pr list --search "${FILTERED_OUT_LABELS} ${IGNORE_USERS} is:open" --limit 1000 --json number --jq '[.[] | .number]')

for pr in $(echo -e $ALL_PRS | jq -s 'flatten(1)')
do
  if [ "$pr" = "[" ] || [ "$pr" = "]" ]; then
    :
  else
    PR_DETAILS=$(gh pr view ${pr//,} --json comments,url)
    PR_URL=$(jq '. | .url' <<< $PR_DETAILS)

    PR_COMMENTS=$(jq --arg DATE "$DATE_7_DAYS_AGO" '. | [.comments[] | select(.author.login != "apollo-cla" and .author.login != "netlify" and .createdAt >= $DATE)] | length' <<< $PR_DETAILS)

    PR_REVIEW_COMMENTS=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/apollographql/${REPOSITORY}/pulls/${pr//,}/comments")

    PR_REVIEW_COMMENTS_BY_MAINTAINERS=$(jq --arg DATE "$DATE_7_DAYS_AGO" '[.[] | select(.author_association == "CONTRIBUTOR" and .author.login != "apollo-cla" and .author.login != "netlify" and .author.login != "github-actions" and .created_at >= $DATE)] | length' <<< $PR_REVIEW_COMMENTS)

    if [ "$PR_COMMENTS" = "0" ] && [ "$PR_REVIEW_COMMENTS_BY_MAINTAINERS" = "0" ]; then
      echo "No new comments in the last 7 days: ${pr//,}"
    else
      WEEKLY_SLACK_BOT_MESSAGE_PRS="${WEEKLY_SLACK_BOT_MESSAGE_PRS}\n*<${PR_URL//\"}|${pr//,}>*"
      echo "Has new comments: ${pr//,}"
      NUM_PRS_WITH_NEW_COMMENTS=$((NUM_PRS_WITH_NEW_COMMENTS+1))
    fi
  fi
done

if [ "$NUM_PRS_WITH_NEW_COMMENTS" = "0" ]; then
  WEEKLY_SLACK_BOT_MESSAGE_PRS="\nNothing to report."
fi

echo "WEEKLY_SLACK_BOT_MESSAGE_PRS=${WEEKLY_SLACK_BOT_MESSAGE_PRS}" >> "$GITHUB_OUTPUT"