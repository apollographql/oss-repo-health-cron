#!/usr/bin/env bash

PRS_MERGED_LAST_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_90_DAYS_AGO}..${DATE_TODAY} ${FILTERED_OUT_LABELS}" --limit 1000 --json author --jq 'length')
PRS_MERGED_PREV_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_181_DAYS_AGO}..${DATE_91_DAYS_AGO} ${FILTERED_OUT_LABELS}" --limit 1000 --json author --jq 'length')
PRS_MERGED_PERCENTAGE_CHANGE=$(bc <<< "scale=2; ($PRS_MERGED_LAST_90_DAYS-$PRS_MERGED_PREV_90_DAYS)/$PRS_MERGED_PREV_90_DAYS * 100")

echo "Total PRs merged in last 90 days (${DATE_TODAY}-${DATE_90_DAYS_AGO}): ${PRS_MERGED_LAST_90_DAYS}"
echo "Total PRs merged in previous 90 day period (${DATE_91_DAYS_AGO} to ${DATE_181_DAYS_AGO}): ${PRS_MERGED_PREV_90_DAYS}"
echo "Percentage change: ${PRS_MERGED_PERCENTAGE_CHANGE}"