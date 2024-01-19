#!/usr/bin/env bash

COMMUNITY_PRS_MERGED_LAST_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_90_DAYS_AGO}..${DATE_TODAY} base:${BASE_BRANCH} ${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS}" --limit ${LIMIT} --json author --jq 'length')
COMMUNITY_PRS_MERGED_PREV_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_181_DAYS_AGO}..${DATE_91_DAYS_AGO} base:${BASE_BRANCH} ${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS}" --limit ${LIMIT} --json author --jq 'length')
COMMUNITY_PRS_MERGED_PERCENTAGE_CHANGE=$(bc <<< "scale=2; ($COMMUNITY_PRS_MERGED_LAST_90_DAYS-$COMMUNITY_PRS_MERGED_PREV_90_DAYS)/$COMMUNITY_PRS_MERGED_PREV_90_DAYS * 100")

echo "COMMUNITY_PRS_MERGED_LAST_90_DAYS=${COMMUNITY_PRS_MERGED_LAST_90_DAYS}" >> "$GITHUB_ENV"
echo "COMMUNITY_PRS_MERGED_PREV_90_DAYS=${COMMUNITY_PRS_MERGED_PREV_90_DAYS}" >> "$GITHUB_ENV"
echo "COMMUNITY_PRS_MERGED_PERCENTAGE_CHANGE=${COMMUNITY_PRS_MERGED_PERCENTAGE_CHANGE}" >> "$GITHUB_ENV"