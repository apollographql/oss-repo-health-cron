#!/usr/bin/env bash

PRS_CREATED_LAST_90_DAYS=$(gh pr list --search "${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS} created:${DATE_90_DAYS_AGO}..${DATE_TODAY}" --state all --limit 1000 --json number --jq '[.[] | .number]')
NUM_PRS_CREATED=$(jq '. | length' <<< $PRS_CREATED_LAST_90_DAYS)
NUM_PRS_REPLIED_TO=0

echo "Community PRs created in the last 90 days: $NUM_PRS_CREATED"

if [ $NUM_PRS_CREATED = "0" ]; then
  echo "No PRs to process. Exiting."
  PERCENTAGE_PRS_REPLIED_TO="N/A"
else
  for pr in $(echo -e $PRS_CREATED_LAST_90_DAYS | jq -s 'flatten(1)')
  do
    if [ "$pr" = "[" ] || [ "$pr" = "]" ]; then
      :
    else
      PR_DETAILS=$(gh pr view ${pr//,} --json createdAt,comments)

      PR_OPENED_DATE=$(jq '. | .createdAt' <<< $PR_DETAILS)

      # get relative datetime 3 days after issue opened
      THREE_DAYS_AFTER_PR_OPENED=$(date -u -d"${PR_OPENED_DATE//\"} +3 days" "+%Y-%m-%dT%H:%M:%SZ")
      
      # PR reviews, review comments and comments must be fetched separately:
      # - if a maintainer reviews a PR (using the review UI) and leaves comments without either approving or requesting changes,
      #   they will be returned by the /pulls/:id/comments endpoint
      PR_REVIEW_COMMENTS=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/apollographql/${REPOSITORY}/pulls/${pr//,}/comments")
      # - if a PR is approved with or without a comment, it will appear under the /pulls/:id/reviews endpoint
      PR_REVIEWS=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/apollographql/${REPOSITORY}/pulls/${pr//,}/reviews")
      
      # Note the casing of authorAssociation/author_association and createdAt/created_at differs between gh CLI calls and REST API calls
      PR_REVIEW_COMMENTS_BY_MAINTAINERS=$(jq --arg DATE "$THREE_DAYS_AFTER_PR_OPENED" '[.[] | select((.author_association == "CONTRIBUTOR" or .author_association == "MEMBER") and .author.login != "apollo-cla" and .author.login != "netlify" and .author.login != "github-actions" and .created_at <= $DATE)] | length' <<< $PR_REVIEW_COMMENTS)
      PR_REVIEWS_BY_MAINTAINERS=$(jq --arg DATE "$THREE_DAYS_AFTER_PR_OPENED" '[.[] | select((.author_association == "CONTRIBUTOR" or .author_association == "MEMBER") and .author.login != "apollo-cla" and .author.login != "netlify" and .author.login != "github-actions" and .created_at <= $DATE)] | length' <<< $PR_REVIEWS)
      
      # - if a comment if left on a PR without a review, it will appear under the comments key in the response from `gh pr view`, which we parse below
      # get number of comments by org members within the first 3 days
      PR_COMMENTS=$(jq --arg DATE "$THREE_DAYS_AFTER_PR_OPENED" '. | [.comments[] | select((.authorAssociation == "CONTRIBUTOR" or .authorAssociation == "MEMBER") and .author.login != "apollo-cla" and .author.login != "netlify" and .author.login != "github-actions" and .createdAt <= $DATE)] | length' <<< $PR_DETAILS)

      if [ "$PR_COMMENTS" = "0" ] && [ "$PR_REVIEW_COMMENTS_BY_MAINTAINERS" = "0" ] && [ "$PR_REVIEWS_BY_MAINTAINERS" = "0" ]; then
        echo "PR without a reply in 72 hours: ${pr//,}"
      else
        echo "PR with a reply in 72 hours: ${pr//,}"
        NUM_PRS_REPLIED_TO=$((NUM_PRS_REPLIED_TO+1))
      fi
    fi
  done
  echo "Number of PRs created in the last 90 days: $NUM_PRS_CREATED"
  PERCENTAGE_PRS_REPLIED_TO=$(bc <<< "scale=4; ($NUM_PRS_REPLIED_TO/$NUM_PRS_CREATED) * 100" | sed '/\./ s/\.\{0,1\}0\{1,\}$//')
  PERCENTAGE_PRS_REPLIED_TO="${PERCENTAGE_PRS_REPLIED_TO}%"
fi

echo "PRs replied to within 72 hours: ${PERCENTAGE_PRS_REPLIED_TO}%"

echo "PERCENTAGE_PRS_REPLIED_TO=${PERCENTAGE_PRS_REPLIED_TO}" >> "$GITHUB_OUTPUT"
echo "NUM_PRS_REPLIED_TO=${NUM_PRS_REPLIED_TO}" >> "$GITHUB_OUTPUT"
echo "NUM_PRS_CREATED=${NUM_PRS_CREATED}" >> "$GITHUB_OUTPUT"
