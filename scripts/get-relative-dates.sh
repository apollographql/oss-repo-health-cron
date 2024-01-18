#!/usr/bin/env bash

DATE_2_DAYS_IN_FUTURE=$(date -d "+2 days" '+%Y-%m-%d')
DATE_TOMORROW=$(date -d "+1 day" '+%Y-%m-%d')
DATE_TODAY=$(date +"%Y-%m-%d")
DATE_YESTERDAY=$(date -d "-1 day" '+%Y-%m-%d')

DATE_2_DAYS_AGO=$(date -d "-2 days" '+%Y-%m-%d')
DATE_3_DAYS_AGO=$(date -d "-3 days" '+%Y-%m-%d')
DATE_7_DAYS_AGO=$(date -d "-7 days" '+%Y-%m-%d')
DATE_90_DAYS_AGO=$(date -d "-90 days" '+%Y-%m-%d')
DATE_91_DAYS_AGO=$(date -d "-91 days" '+%Y-%m-%d')
DATE_181_DAYS_AGO=$(date -d "-181 days" '+%Y-%m-%d')


echo "DATE_2_DAYS_IN_FUTURE=${DATE_2_DAYS_IN_FUTURE}" >> "$GITHUB_ENV"
echo "DATE_TOMORROW=${DATE_TOMORROW}" >> "$GITHUB_ENV"
echo "DATE_TODAY=${DATE_TODAY}" >> "$GITHUB_ENV"
echo "DATE_YESTERDAY=${DATE_YESTERDAY}" >> "$GITHUB_ENV"

echo "DATE_2_DAYS_AGO=${DATE_2_DAYS_AGO}" >> "$GITHUB_ENV"
echo "DATE_3_DAYS_AGO=${DATE_3_DAYS_AGO}" >> "$GITHUB_ENV"
echo "DATE_7_DAYS_AGO=${DATE_7_DAYS_AGO}" >> "$GITHUB_ENV"
echo "DATE_90_DAYS_AGO=${DATE_90_DAYS_AGO}" >> "$GITHUB_ENV"
echo "DATE_91_DAYS_AGO=${DATE_91_DAYS_AGO}" >> "$GITHUB_ENV"
echo "DATE_181_DAYS_AGO=${DATE_181_DAYS_AGO}" >> "$GITHUB_ENV"
