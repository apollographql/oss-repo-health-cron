#!/usr/bin/env bash

PRS_CREATED_LAST_3_DAYS=$(gh pr list --search "${FILTERED_OUT_LABELS} created:${DATE_3_DAYS_AGO}..${DATE_TODAY}" --limit 1000 --json number --jq '[.[] | .number]')
PRS_SLACK_BOT_MESSAGE=""

for pr in $(echo -e $PRS_CREATED_LAST_3_DAYS | jq -s 'flatten(1)')
do
  if [ "$pr" = "[" ] || [ "$pr" = "]" ]; then
    :
  else
    PR_DETAILS=$(gh pr view ${pr//,} --json comments,url)
    PR_URL=$(jq '. | .url' <<< $PR_DETAILS)

    # get number of comments by maintainers within the first 3 days
    # NB: manually filter out apollo-cla bot, but otherwise include all users
    # with CONTRIBUTOR association
    PR_COMMENTS=$(jq '. | [.comments[] | select(.authorAssociation == "CONTRIBUTOR" and .author.login != "apollo-cla")] | length' <<< $PR_DETAILS)

    if [ "$PR_COMMENTS" = "0" ]; then
      PRS_SLACK_BOT_MESSAGE="${PRS_SLACK_BOT_MESSAGE}\n*<${PR_URL//\"}|${pr//,}>*"
      echo "PR without a reply in 72 hours: ${pr//,}"
    else
      echo "PR with a reply in 72 hours: ${pr//,}"
      NUM_PRS_REPLIED_TO=$((NUM_PRS_REPLIED_TO+1))
    fi
  fi
done

echo "PRS_SLACK_BOT_MESSAGE=${PRS_SLACK_BOT_MESSAGE}" >> "$GITHUB_OUTPUT"