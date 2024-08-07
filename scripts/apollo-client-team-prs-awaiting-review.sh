#!/usr/bin/env bash

declare -a REPOSITORIES=( \
  "apollo-client"\
  "apollo-client-devtools"\
  "apollo-client-nextjs"\
  "vscode-graphql"\
  "graphql-testing-library"\
  "graphql-tag"\
  "spotify-showcase"\
  "react-apollo-error-template"\
  "docs"\
  )

TEAM_NAME="client-typescript"

# fetch team members
TEAM_MEMBERS=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" -H "Authorization: Bearer $GH_TOKEN" "/orgs/apollographql/teams/${TEAM_NAME}/members" --paginate --jq '[.[] | .login]')

# filter out draft PRs
GITHUB_SEARCH_STRING="-is:draft"

TEAM_PRS_AWAITING_REVIEW_MARKDOWN=""
NUM_PRS_AWAITING_REVIEW=0
JQ_SEARCH_STRING=""

# build a search string from the members of the team and the team slug
# to also capture reviews requested of the team via CODEOWNERS
for user in $(echo -e $TEAM_MEMBERS | jq -s 'flatten(1)')
do
  if [ "$user" = "[" ] || [ "$user" = "]" ]; then
    :
  else
    GITHUB_SEARCH_STRING+=" author:${user}"

    JQ_SEARCH_STRING+=" .reviewRequests[].login == ${user//,} or"
  fi
done

JQ_SEARCH_STRING+=' .reviewRequests[].slug == "apollographql/client-typescript"'

# Map over the repositories, fetching a list of PRs that:
#    - were authored by team members
#    - have pending reviews from team members/the GH team itself
# This will also capture e.g. a PR where only one member has a pending review,
# even if other team members have already commented.
for repo in "${REPOSITORIES[@]}"
do
  PR_DETAILS=$(gh pr list -R apollographql/${repo} --search "$GITHUB_SEARCH_STRING" --json author,title,reviewRequests,reviewDecision,headRepository,url)

  AWAITING_REVIEW_FROM_TS_TEAM=$(jq "[.[] | select(${JQ_SEARCH_STRING})]" <<< $PR_DETAILS)

  UNIQUE_AWAITING_REVIEWS=$(jq -M '. |= unique_by(.title)' <<< $AWAITING_REVIEW_FROM_TS_TEAM)

  for pr in "${UNIQUE_AWAITING_REVIEWS[@]}"
  do
    if [ "$pr" = "[]" ]; then
      :
    else
      AUTHOR=$(jq ".[].author.login" <<< $pr)
      REPO=$(jq ".[].headRepository.name" <<< $pr)
      PR_URL=$(jq ".[].url" <<< $pr)
      TITLE=$(jq ".[].title" <<< $pr)

      NUM_PRS_AWAITING_REVIEW=$((NUM_PRS_AWAITING_REVIEW+1))
      TEAM_PRS_AWAITING_REVIEW_MARKDOWN="${TEAM_PRS_AWAITING_REVIEW_MARKDOWN}\n<${PR_URL//\"}|[${REPO//\"}] ${TITLE//\"} (${AUTHOR//\"})>"
    fi
  done
done

if [ "$NUM_PRS_AWAITING_REVIEW" = "0" ]; then
  TEAM_PRS_AWAITING_REVIEW_MARKDOWN="\nAll caught up :tada:"
fi

echo "TEAM_PRS_AWAITING_REVIEW_MARKDOWN=${TEAM_PRS_AWAITING_REVIEW_MARKDOWN}" >> "$GITHUB_OUTPUT"