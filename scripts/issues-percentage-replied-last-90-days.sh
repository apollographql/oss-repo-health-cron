#!/usr/bin/env bash

ISSUES_CREATED_LAST_90_DAYS=$(gh issue list --search "${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS} created:${DATE_90_DAYS_AGO}..${DATE_TODAY}" --limit 1000 --json number --jq '[.[] | .number]')
NUM_ISSUES_CREATED=$(jq '. | length' <<< $ISSUES_CREATED_LAST_90_DAYS)
NUM_ISSUES_REPLIED_TO=0

if [ "$ISSUES_CREATED_LAST_90_DAYS" != [] ]; then
  for issue in $(echo -e $ISSUES_CREATED_LAST_90_DAYS | jq -s 'flatten(1)')
  do
    if [ "$issue" = "[" ] || [ "$issue" = "]" ]; then
      :
    else
      ISSUE_DETAILS=$(gh issue view ${issue//,} --json createdAt,comments)

      ISSUE_OPENED_DATE=$(jq '. | .createdAt' <<< $ISSUE_DETAILS)

      # get relative datetime 3 days after issue opened
      THREE_DAYS_AFTER_ISSUE_OPENED=$(date -j -v+3d -f "%Y-%m-%dT%H:%M:%SZ" "${ISSUE_OPENED_DATE//\"}" "+%Y-%m-%dT%H:%M:%SZ")

      # get number of comments by maintainers within the first 3 days
      # NB: manually filter out apollo-cla bot, but otherwise include all users
      # with CONTRIBUTOR association
      ISSUE_COMMENTS=$(jq --arg DATE "$THREE_DAYS_AFTER_ISSUE_OPENED" '. | [.comments[] | select((.authorAssociation == "CONTRIBUTOR" or .authorAssociation == "MEMBER") and .author.login != "apollo-cla" and .author.login != "netlify" and .author.login != "github-actions" and .createdAt <= $DATE)] | length' <<< $ISSUE_DETAILS)

      if [ "$ISSUE_COMMENTS" = "0" ]; then
        echo "Issue without a reply in 72 hours: ${issue//,}"
      else
        echo "Issue with a reply in 72 hours: ${issue//,}"
        NUM_ISSUES_REPLIED_TO=$((NUM_ISSUES_REPLIED_TO+1))
      fi
    fi
  done
fi

PERCENTAGE_ISSUES_REPLIED_TO=$(bc <<< "scale=4; ($NUM_ISSUES_REPLIED_TO/$NUM_ISSUES_CREATED)" | sed '/\./ s/\.\{0,1\}0\{1,\}$//')
echo "Issues replied to within 72 hours: ${PERCENTAGE_ISSUES_REPLIED_TO}%"

echo "PERCENTAGE_ISSUES_REPLIED_TO=${PERCENTAGE_ISSUES_REPLIED_TO}" >> "$GITHUB_OUTPUT"
echo "NUM_ISSUES_REPLIED_TO=${NUM_ISSUES_REPLIED_TO}" >> "$GITHUB_OUTPUT"
echo "NUM_ISSUES_CREATED=${NUM_ISSUES_CREATED}" >> "$GITHUB_OUTPUT"