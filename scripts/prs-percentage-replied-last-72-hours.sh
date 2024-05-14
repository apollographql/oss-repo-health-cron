#!/usr/bin/env bash

PRS_CREATED_LAST_3_DAYS=$(gh pr list --search "${FILTERED_OUT_LABELS} ${IGNORE_USERS} created:${DATE_3_DAYS_AGO}..${DATE_TODAY} review:none -is:draft" --limit 1000 --state all --json number --jq '[.[] | .number]')
PRS_SLACK_BOT_MESSAGE=""
NUM_PRS_TO_REPLY_TO=0

if [ "$PRS_CREATED_LAST_3_DAYS" != [] ]; then
  for pr in $(echo -e $PRS_CREATED_LAST_3_DAYS | jq -s 'flatten(1)')
  do
    if [ "$pr" = "[" ] || [ "$pr" = "]" ]; then
      :
    else
      PR_DETAILS=$(gh pr view ${pr//,} --json comments,url)
      
      PR_URL=$(jq '. | .url' <<< $PR_DETAILS)
      
      PR_REVIEW_COMMENTS=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/apollographql/${REPOSITORY}/pulls/${pr//,}/comments")

      PR_REVIEW_COMMENTS_BY_MAINTAINERS=$(jq '[.[] | select((.author_association == "CONTRIBUTOR" or .author_association == "MEMBER") and .author.login != "apollo-cla" and .author.login != "netlify" and .author.login != "github-actions")] | length' <<< $PR_REVIEW_COMMENTS)
      
      # get number of comments by maintainers within the first 3 days
      # NB: manually filter out apollo-cla bot, but otherwise include all users
      # with CONTRIBUTOR association
      PR_COMMENTS=$(jq '. | [.comments[] | select((.authorAssociation == "CONTRIBUTOR" or .authorAssociation == "MEMBER") and .author.login != "apollo-cla" and .author.login != "netlify" and .author.login != "github-actions")] | length' <<< $PR_DETAILS)

      if [ "$PR_COMMENTS" = "0" ] && [ "$PR_REVIEW_COMMENTS_BY_MAINTAINERS" = "0" ]; then
        PRS_SLACK_BOT_MESSAGE="${PRS_SLACK_BOT_MESSAGE}\n*<${PR_URL//\"}|${pr//,}>*"
        echo "PR without a reply in 72 hours: ${pr//,}"
        NUM_PRS_TO_REPLY_TO=$((NUM_PRS_TO_REPLY_TO+1))
      else
        echo "PR with a reply in 72 hours: ${pr//,}"
      fi
    fi
  done
fi

if [ "$NUM_PRS_TO_REPLY_TO" = "0" ]; then
  PRS_SLACK_BOT_MESSAGE="\nAll caught up :tada:"
fi

echo "PRS_SLACK_BOT_MESSAGE=${PRS_SLACK_BOT_MESSAGE}" >> "$GITHUB_OUTPUT"