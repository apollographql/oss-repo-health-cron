#!/usr/bin/env bash

ISSUES_CREATED_LAST_3_DAYS=$(gh issue list --search "${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS} created:${DATE_3_DAYS_AGO}..${DATE_TODAY}" --limit 1000 --json number --jq '[.[] | .number]')
ISSUES_SLACK_BOT_MESSAGE=""
NUM_ISSUES_TO_REPLY_TO=0

if [ "$ISSUES_CREATED_LAST_3_DAYS" != [] ]; then
  for issue in $(echo -e $ISSUES_CREATED_LAST_3_DAYS | jq -s 'flatten(1)')
  do
    if [ "$issue" = "[" ] || [ "$issue" = "]" ]; then
      :
    else
      ISSUE_DETAILS=$(gh issue view ${issue//,} --json comments,url)
      ISSUE_URL=$(jq '. | .url' <<< $ISSUE_DETAILS)
      
      echo $(jq '. | .comments' <<< $ISSUE_DETAILS)
      # get number of comments by maintainers within the first 3 days
      # NB: manually filter out apollo-cla bot, but otherwise include all users
      # with CONTRIBUTOR association
      ISSUE_COMMENTS=$(jq '. | [.comments[] | select((.authorAssociation == "CONTRIBUTOR" or .authorAssociation == "MEMBER") and .author.login != "apollo-cla" and .author.login != "netlify" and .author.login != "github-actions")] | length' <<< $ISSUE_DETAILS)

      if [ "$ISSUE_COMMENTS" = "0" ]; then
        ISSUES_SLACK_BOT_MESSAGE="${ISSUES_SLACK_BOT_MESSAGE}\n*<${ISSUE_URL//\"}|${issue//,}>*"
        echo "Issue without a reply in 72 hours: ${issue//,}"
        NUM_ISSUES_TO_REPLY_TO=$((NUM_ISSUES_TO_REPLY_TO+1))
      else
        echo "Issue with a reply in 72 hours: ${issue//,}"
      fi
    fi
  done
fi

if [ "$NUM_ISSUES_TO_REPLY_TO" = "0" ]; then
  ISSUES_SLACK_BOT_MESSAGE="\nAll caught up :tada:"
fi

echo "ISSUES_SLACK_BOT_MESSAGE=${ISSUES_SLACK_BOT_MESSAGE}" >> "$GITHUB_OUTPUT"