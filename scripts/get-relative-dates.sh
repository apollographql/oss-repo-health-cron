#!/usr/bin/env bash

DATE_TODAY=$(date +"%Y-%m-%d")
DATE_3_DAYS_AGO=$(date -j -v-3d '+%Y-%m-%d')
DATE_90_DAYS_AGO=$(date -j -v-90d '+%Y-%m-%d')
DATE_91_DAYS_AGO=$(date -j -v-91d '+%Y-%m-%d')
DATE_181_DAYS_AGO=$(date -j -v-181d '+%Y-%m-%d')

echo "BASE_BRANCH=main" >> "$GITHUB_ENV"
echo "LIMIT=1000" >> "$GITHUB_ENV"

echo "DATE_TODAY=${DATE_TODAY}" >> "$GITHUB_ENV"
echo "DATE_3_DAYS_AGO=${DATE_3_DAYS_AGO}" >> "$GITHUB_ENV"
echo "DATE_90_DAYS_AGO=${DATE_90_DAYS_AGO}" >> "$GITHUB_ENV"
echo "DATE_91_DAYS_AGO=${DATE_91_DAYS_AGO}" >> "$GITHUB_ENV"
echo "DATE_181_DAYS_AGO=${DATE_181_DAYS_AGO}" >> "$GITHUB_ENV"