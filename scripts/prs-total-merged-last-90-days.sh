#!/usr/bin/env bash

PRS_MERGED_LAST_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_90_DAYS_AGO}..${DATE_TODAY} ${FILTERED_OUT_LABELS}" --limit ${LIMIT} --json author --jq 'length')
PRS_MERGED_PREV_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_181_DAYS_AGO}..${DATE_91_DAYS_AGO} ${FILTERED_OUT_LABELS}" --limit ${LIMIT} --json author --jq 'length')
PRS_MERGED_PERCENTAGE_CHANGE=$(bc <<< "scale=2; ($PRS_MERGED_LAST_90_DAYS-$PRS_MERGED_PREV_90_DAYS)/$PRS_MERGED_PREV_90_DAYS * 100")

echo "PRS_MERGED_LAST_90_DAYS=${PRS_MERGED_LAST_90_DAYS}" >> "$GITHUB_ENV"
echo "PRS_MERGED_PREV_90_DAYS=${PRS_MERGED_PREV_90_DAYS}" >> "$GITHUB_ENV"
echo "PRS_MERGED_PERCENTAGE_CHANGE=${PRS_MERGED_PERCENTAGE_CHANGE}" >> "$GITHUB_ENV"