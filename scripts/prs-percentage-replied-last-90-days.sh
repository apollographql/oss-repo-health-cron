#!/usr/bin/env bash

PRS_CREATED_LAST_90_DAYS=$(gh pr list --search "${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS} created:${DATE_90_DAYS_AGO}..${DATE_TODAY}" --limit 1000 --json number --jq '[.[] | .number]')
NUM_PRS_CREATED=$(jq '. | length' <<< $PRS_CREATED_LAST_90_DAYS)
NUM_PRS_REPLIED_TO=0

echo "PRs created last 90 days: ${PRS_CREATED_LAST_90_DAYS}"
echo "Num PRs created last 90 days: ${NUM_PRS_CREATED}"

for pr in $(echo -e $PRS_CREATED_LAST_90_DAYS | jq -s 'flatten(1)')
do
  if [ "$pr" = "[" ] || [ "$pr" = "]" ]; then
    :
  else
    PR_DETAILS=$(gh pr view ${pr//,} --json createdAt,comments)

    PR_OPENED_DATE=$(jq '. | .createdAt' <<< $PR_DETAILS)

    echo "Issue number: ${pr//,}"
    echo "Issue opened date: ${PR_OPENED_DATE}"

    # get relative datetime 3 days after issue opened
    THREE_DAYS_AFTER_PR_OPENED=$(date -j -v+3d -f "%Y-%m-%dT%H:%M:%SZ" "${PR_OPENED_DATE//\"}" "+%Y-%m-%dT%H:%M:%SZ")

    echo "3 days after PR opened: ${THREE_DAYS_AFTER_PR_OPENED}"

    # get number of comments by maintainers within the first 3 days
    # NB: manually filter out apollo-cla bot, but otherwise include all users
    # with MEMBER association (i.e. Apollo GraphQL org members)
    PR_COMMENTS=$(jq --arg DATE "$THREE_DAYS_AFTER_PR_OPENED" '. | [.comments[] | select(.authorAssociation == "MEMBER" and .author.login != "apollo-cla" and .createdAt <= $DATE)] | length' <<< $PR_DETAILS)

    echo "PR comments: ${PR_COMMENTS}"

    if [ "$PR_COMMENTS" = "0" ]; then
      echo "PR without a reply in 72 hours: ${pr//,}"
    else
      echo "PR with a reply in 72 hours: ${pr//,}"
      NUM_PRS_REPLIED_TO=$((NUM_PRS_REPLIED_TO+1))
    fi
  fi
done

PERCENTAGE_PRS_REPLIED_TO=$(bc <<< "scale=2; ($NUM_PRS_REPLIED_TO/$NUM_PRS_CREATED) * 100")
echo "PRs replied to within 72 hours: ${PERCENTAGE_PRS_REPLIED_TO}%"

echo "PERCENTAGE_PRS_REPLIED_TO=${PERCENTAGE_PRS_REPLIED_TO}" >> "$GITHUB_ENV"