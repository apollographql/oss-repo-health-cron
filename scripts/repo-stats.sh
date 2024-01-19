#!/usr/bin/env bash

function main() {
  # BASE_BRANCH="main"
  # LIMIT="1000"
  # DATE_TODAY=$(date +"%Y-%m-%d")
  # echo "today's date: ${DATE_TODAY}"

  # DATE_90_DAYS_AGO=$(date -j -v-90d '+%Y-%m-%d')
  # DATE_91_DAYS_AGO=$(date -j -v-91d '+%Y-%m-%d')
  # DATE_181_DAYS_AGO=$(date -j -v-181d '+%Y-%m-%d')

  # echo "90 days ago: ${DATE_90_DAYS_AGO}"
  # echo "91 days ago: ${DATE_91_DAYS_AGO}"
  # echo "181 days ago: ${DATE_181_DAYS_AGO}"

  # APOLLO_GRAPHQL_ORG_MEMBERS=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /orgs/apollographql/members --paginate --jq '[.[] | .login]')

  # echo "Apollo GraphQL org members: ${APOLLO_GRAPHQL_ORG_MEMBERS}"

  # # Filter out arbitrary users here, in addition to Apollo GraphQL org members
  # FILTERED_OUT_USERS="-author:peakematt-2, -author:app/github-actions,"
  # # Filter out arbitrary labels here
  # FILTERED_OUT_LABELS="-label:\":christmas_tree: dependencies\""

  # # with the --paginate arg we receive multiple arrays so we need to flatten
  # for user in $(echo -e $APOLLO_GRAPHQL_ORG_MEMBERS | jq -s 'flatten(1)')
  # do
  #   if [ "$user" = "[" ] || [ "$user" = "]" ]; then
  #     :
  #   else
  #     FILTERED_OUT_USERS+=" -author:${user}"
  #   fi
  # done

  # COMMUNITY_PRS_MERGED_LAST_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_90_DAYS_AGO}..${DATE_TODAY} base:${BASE_BRANCH} ${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS}" --limit ${LIMIT} --json author --jq 'length')
  # COMMUNITY_PRS_MERGED_PREV_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_181_DAYS_AGO}..${DATE_91_DAYS_AGO} base:${BASE_BRANCH} ${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS}" --limit ${LIMIT} --json author --jq 'length')
  # COMMUNITY_PRS_MERGED_PERCENTAGE_CHANGE=$(bc <<< "scale=2; ($COMMUNITY_PRS_MERGED_LAST_90_DAYS-$COMMUNITY_PRS_MERGED_PREV_90_DAYS)/$COMMUNITY_PRS_MERGED_PREV_90_DAYS * 100")

  # Total PRs merged in past 90 days
  # PRS_MERGED_LAST_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_90_DAYS_AGO}..${DATE_TODAY} ${FILTERED_OUT_LABELS}" --limit ${LIMIT} --json author --jq 'length')
  # PRS_MERGED_PREV_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_181_DAYS_AGO}..${DATE_91_DAYS_AGO} ${FILTERED_OUT_LABELS}" --limit ${LIMIT} --json author --jq 'length')
  # PRS_MERGED_PERCENTAGE_CHANGE=$(bc <<< "scale=2; ($PRS_MERGED_LAST_90_DAYS-$PRS_MERGED_PREV_90_DAYS)/$PRS_MERGED_PREV_90_DAYS * 100")

  # Issues closed within the past 30 days
  # ISSUES_CLOSED_LAST_90_DAYS=$(gh issue list --search "closed:${DATE_90_DAYS_AGO}..${DATE_TODAY}" --limit ${LIMIT} --json author --jq 'length')
  # ISSUES_CLOSED_PREV_90_DAYS=$(gh issue list --search "closed:${DATE_181_DAYS_AGO}..${DATE_91_DAYS_AGO}" --limit ${LIMIT} --json author --jq 'length')
  # ISSUES_CLOSED_PERCENTAGE_CHANGE=$(bc <<< "scale=2; ($ISSUES_CLOSED_LAST_90_DAYS-$ISSUES_CLOSED_PREV_90_DAYS)/$ISSUES_CLOSED_PREV_90_DAYS * 100")

  # echo "Community PRs merged in past 90 days vs prev 90 days (delta): ${COMMUNITY_PRS_MERGED_PERCENTAGE_CHANGE}%"
  # echo "Total PRs merged in past 90 days vs prev 90 days (delta): ${PRS_MERGED_PERCENTAGE_CHANGE}%"
  # echo "Issues closed in past 90 days vs prev 90 days (delta): ${ISSUES_CLOSED_PERCENTAGE_CHANGE}%"

  # Percentage of issues opened by an external contributor in the past 90 days that have a maintainer response within 72 hours

  # ISSUES_CREATED_LAST_90_DAYS=$(gh issue list --search "${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS} created:${DATE_90_DAYS_AGO}..${DATE_TODAY}" --limit 1000 --json number --jq '[.[] | .number]')
  # NUM_ISSUES_CREATED=$(jq '. | length' <<< $ISSUES_CREATED_LAST_90_DAYS)
  # NUM_ISSUES_REPLIED_TO=0

  # echo "Issues created last 90 days: ${ISSUES_CREATED_LAST_90_DAYS}"
  # echo "Num issues created last 90 days: ${NUM_ISSUES_CREATED}"

  # for issue in $(echo -e $ISSUES_CREATED_LAST_90_DAYS | jq -s 'flatten(1)')
  # do
  #   if [ "$issue" = "[" ] || [ "$issue" = "]" ]; then
  #     :
  #   else
  #     ISSUE_DETAILS=$(gh issue view ${issue//,} --json createdAt,comments)

  #     ISSUE_OPENED_DATE=$(jq '. | .createdAt' <<< $ISSUE_DETAILS)

  #     echo "Issue number: ${issue//,}"
  #     echo "Issue opened date: ${ISSUE_OPENED_DATE}"

  #     # get relative datetime 3 days after issue opened
  #     THREE_DAYS_AFTER_ISSUE_OPENED=$(date -j -v+3d -f "%Y-%m-%dT%H:%M:%SZ" "${ISSUE_OPENED_DATE//\"}" "+%Y-%m-%dT%H:%M:%SZ")

  #     echo "3 days after issue opened: ${THREE_DAYS_AFTER_ISSUE_OPENED}"

  #     # get number of comments by maintainers within the first 3 days
  #     # NB: manually filter out apollo-cla bot, but otherwise include all users
  #     # with MEMBER association (i.e. Apollo GraphQL org members)
  #     ISSUE_COMMENTS=$(jq --arg DATE "$THREE_DAYS_AFTER_ISSUE_OPENED" '. | [.comments[] | select(.authorAssociation == "MEMBER" and .author.login != "apollo-cla" and .createdAt <= $DATE)] | length' <<< $ISSUE_DETAILS)

  #     echo "Issue comments: ${ISSUE_COMMENTS}"

  #     if [ "$ISSUE_COMMENTS" = "0" ]; then
  #       echo "Issue without a reply in 72 hours: ${issue//,}"
  #     else
  #       echo "Issue with a reply in 72 hours: ${issue//,}"
  #       NUM_ISSUES_REPLIED_TO=$((NUM_ISSUES_REPLIED_TO+1))
  #     fi
  #   fi
  # done

  # PERCENTAGE_ISSUES_REPLIED_TO=$(bc <<< "scale=2; ($NUM_ISSUES_REPLIED_TO/$NUM_ISSUES_CREATED) * 100")
  # echo "Issues replied to within 72 hours: ${PERCENTAGE_ISSUES_REPLIED_TO}%"

  # Percentage of PRs opened by an external contributor in the past 30 days that have a maintainer response within 72 hours
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
}

main
