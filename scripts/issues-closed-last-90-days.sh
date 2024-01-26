#!/usr/bin/env bash

ISSUES_CLOSED_LAST_90_DAYS=$(gh issue list --search "closed:${DATE_90_DAYS_AGO}..${DATE_TODAY}" --limit 1000 --json author --jq 'length')
ISSUES_CLOSED_PREV_90_DAYS=$(gh issue list --search "closed:${DATE_181_DAYS_AGO}..${DATE_91_DAYS_AGO}" --limit 1000 --json author --jq 'length')
ISSUES_CLOSED_PERCENTAGE_CHANGE=$(bc <<< "scale=4; ($ISSUES_CLOSED_LAST_90_DAYS-$ISSUES_CLOSED_PREV_90_DAYS)/$ISSUES_CLOSED_PREV_90_DAYS * 100" | sed '/\./ s/\.\{0,1\}0\{1,\}$//')

echo "Issues closed in last 90 days (${DATE_TODAY}-${DATE_90_DAYS_AGO}): ${ISSUES_CLOSED_LAST_90_DAYS}"
echo "Issues closed in previous 90 day period (${DATE_91_DAYS_AGO} to ${DATE_181_DAYS_AGO}): ${ISSUES_CLOSED_PREV_90_DAYS}"
echo "Percentage change: ${ISSUES_CLOSED_PERCENTAGE_CHANGE}"