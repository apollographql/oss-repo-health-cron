#!/usr/bin/env bash

APOLLO_GRAPHQL_ORG_MEMBERS=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" -H "Authorization: Bearer ${{ secrets.GH_TOKEN }}" /orgs/apollographql/members --paginate --jq '[.[] | .login]')

echo "Apollo GraphQL org members: ${APOLLO_GRAPHQL_ORG_MEMBERS}"

# Filter out arbitrary users here, in addition to Apollo GraphQL org members
FILTERED_OUT_USERS="-author:peakematt-2, -author:app/github-actions,"
# Filter out arbitrary labels here
FILTERED_OUT_LABELS="-label:\":christmas_tree: dependencies\""

# with the --paginate arg we receive multiple arrays so we need to flatten
for user in $(echo -e $APOLLO_GRAPHQL_ORG_MEMBERS | jq -s 'flatten(1)')
do
  if [ "$user" = "[" ] || [ "$user" = "]" ]; then
    :
  else
    FILTERED_OUT_USERS+=" -author:${user}"
  fi
done

echo "FILTERED_OUT_USERS=${FILTERED_OUT_USERS}" >> "$GITHUB_ENV"
echo "FILTERED_OUT_LABELS=${FILTERED_OUT_LABELS}" >> "$GITHUB_ENV"