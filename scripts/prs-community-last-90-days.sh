#!/usr/bin/env bash

COMMUNITY_PRS_MERGED_LAST_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_90_DAYS_AGO}..${DATE_TODAY} base:main ${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS}" --limit 1000 --json author --jq 'length')
COMMUNITY_PRS_MERGED_PREV_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_181_DAYS_AGO}..${DATE_91_DAYS_AGO} base:main ${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS}" --limit 1000 --json author --jq 'length')
COMMUNITY_PRS_MERGED_PERCENTAGE_CHANGE=$(bc <<< "scale=2; ($COMMUNITY_PRS_MERGED_LAST_90_DAYS-$COMMUNITY_PRS_MERGED_PREV_90_DAYS)/$COMMUNITY_PRS_MERGED_PREV_90_DAYS * 100")

echo "Community PRs merged in last 90 days (${DATE_TODAY}-${DATE_90_DAYS_AGO}): ${COMMUNITY_PRS_MERGED_LAST_90_DAYS}"
echo "Community PRs merged in previous 90 day period (${DATE_91_DAYS_AGO} to ${DATE_181_DAYS_AGO}): ${COMMUNITY_PRS_MERGED_PREV_90_DAYS}"
echo "Percentage change: ${COMMUNITY_PRS_MERGED_PERCENTAGE_CHANGE}"