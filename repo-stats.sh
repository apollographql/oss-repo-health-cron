#!/usr/bin/env bash

####
# Copyright (c) 2016-2021
#   Jakob Westhoff <jakob@westhoffswelt.de>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#  - Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#  - Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUsed AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVIsed OF THE POSSIBILITY OF SUCH DAMAGE.
####

_prettytable_char_top_left="┌"
_prettytable_char_horizontal="─"
_prettytable_char_vertical="│"
_prettytable_char_bottom_left="└"
_prettytable_char_bottom_right="┘"
_prettytable_char_top_right="┐"
_prettytable_char_vertical_horizontal_left="├"
_prettytable_char_vertical_horizontal_right="┤"
_prettytable_char_vertical_horizontal_top="┬"
_prettytable_char_vertical_horizontal_bottom="┴"
_prettytable_char_vertical_horizontal="┼"


# Escape codes

# Default colors
_prettytable_color_blue="0;34"
_prettytable_color_green="0;32"
_prettytable_color_cyan="0;36"
_prettytable_color_red="0;31"
_prettytable_color_purple="0;35"
_prettytable_color_yellow="0;33"
_prettytable_color_gray="1;30"
_prettytable_color_light_blue="1;34"
_prettytable_color_light_green="1;32"
_prettytable_color_light_cyan="1;36"
_prettytable_color_light_red="1;31"
_prettytable_color_light_purple="1;35"
_prettytable_color_light_yellow="1;33"
_prettytable_color_light_gray="0;37"

# Somewhat special colors
_prettytable_color_black="0;30"
_prettytable_color_white="1;37"
_prettytable_color_none="0"

function _prettytable_prettify_lines() {
    cat - | sed -e "s@^@${_prettytable_char_vertical}@;s@\$@	@;s@	@	${_prettytable_char_vertical}@g"
}

function _prettytable_fix_border_lines() {
    cat - | sed -e "1s@ @${_prettytable_char_horizontal}@g;3s@ @${_prettytable_char_horizontal}@g;\$s@ @${_prettytable_char_horizontal}@g"
}

function _prettytable_colorize_lines() {
    local color="$1"
    local range="$2"
    local ansicolor="$(eval "echo \${_prettytable_color_${color}}")"

    cat - | sed -e "${range}s@\\([^${_prettytable_char_vertical}]\\{1,\\}\\)@"$'\E'"[${ansicolor}m\1"$'\E'"[${_prettytable_color_none}m@g"
}

function prettytable() {
    local cols="${1}"
    local color="${2:-none}"
    local input="$(cat -)"
    local header="$(echo -e "${input}"|head -n1)"
    local body="$(echo -e "${input}"|tail -n+2)"
    {
        # Top border
        echo -n "${_prettytable_char_top_left}"
        for i in $(seq 2 ${cols}); do
            echo -ne "\t${_prettytable_char_vertical_horizontal_top}"
        done
        echo -e "\t${_prettytable_char_top_right}"

        echo -e "${header}" | _prettytable_prettify_lines

        # Header/Body delimiter
        echo -n "${_prettytable_char_vertical_horizontal_left}"
        for i in $(seq 2 ${cols}); do
            echo -ne "\t${_prettytable_char_vertical_horizontal}"
        done
        echo -e "\t${_prettytable_char_vertical_horizontal_right}"

        echo -e "${body}" | _prettytable_prettify_lines

        # Bottom border
        echo -n "${_prettytable_char_bottom_left}"
        for i in $(seq 2 ${cols}); do
            echo -ne "\t${_prettytable_char_vertical_horizontal_bottom}"
        done
        echo -e "\t${_prettytable_char_bottom_right}"
    } | column -t -s $'\t' | _prettytable_fix_border_lines | _prettytable_colorize_lines "${color}" "2"
}

# if [ "$0" = "$BASH_SOURCE" ]; then
#     # Execute function if called as a script instead of being sourced.
#     prettytable $*
# fi

function main() {
  BASE_BRANCH="main"
  LIMIT="1000"
  DATE_TODAY=$(date +"%Y-%m-%d")
  echo "today's date: ${DATE_TODAY}"

  DATE_90_DAYS_AGO=$(date -j -v-90d '+%Y-%m-%d')
  DATE_91_DAYS_AGO=$(date -j -v-91d '+%Y-%m-%d')
  DATE_181_DAYS_AGO=$(date -j -v-181d '+%Y-%m-%d')

  echo "90 days ago: ${DATE_90_DAYS_AGO}"
  echo "91 days ago: ${DATE_91_DAYS_AGO}"
  echo "181 days ago: ${DATE_181_DAYS_AGO}"

  APOLLO_GRAPHQL_ORG_MEMBERS=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /orgs/apollographql/members --paginate --jq '[.[] | .login]')

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

  COMMUNITY_PRS_MERGED_LAST_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_90_DAYS_AGO}..${DATE_TODAY} base:${BASE_BRANCH} ${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS}" --limit ${LIMIT} --json author --jq 'length')
  COMMUNITY_PRS_MERGED_PREV_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_181_DAYS_AGO}..${DATE_91_DAYS_AGO} base:${BASE_BRANCH} ${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS}" --limit ${LIMIT} --json author --jq 'length')
  COMMUNITY_PRS_MERGED_PERCENTAGE_CHANGE=$(bc <<< "scale=2; ($COMMUNITY_PRS_MERGED_LAST_90_DAYS-$COMMUNITY_PRS_MERGED_PREV_90_DAYS)/$COMMUNITY_PRS_MERGED_PREV_90_DAYS * 100")

  # Total PRs merged in past 90 days
  PRS_MERGED_LAST_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_90_DAYS_AGO}..${DATE_TODAY} ${FILTERED_OUT_LABELS}" --limit ${LIMIT} --json author --jq 'length')
  PRS_MERGED_PREV_90_DAYS=$(gh pr list --search "is:closed merged:${DATE_181_DAYS_AGO}..${DATE_91_DAYS_AGO} ${FILTERED_OUT_LABELS}" --limit ${LIMIT} --json author --jq 'length')
  PRS_MERGED_PERCENTAGE_CHANGE=$(bc <<< "scale=2; ($PRS_MERGED_LAST_90_DAYS-$PRS_MERGED_PREV_90_DAYS)/$PRS_MERGED_PREV_90_DAYS * 100")

  # Issues closed within the past 30 days
  ISSUES_CLOSED_LAST_90_DAYS=$(gh issue list --search "closed:${DATE_90_DAYS_AGO}..${DATE_TODAY}" --limit ${LIMIT} --json author --jq 'length')
  ISSUES_CLOSED_PREV_90_DAYS=$(gh issue list --search "closed:${DATE_181_DAYS_AGO}..${DATE_91_DAYS_AGO}" --limit ${LIMIT} --json author --jq 'length')
  ISSUES_CLOSED_PERCENTAGE_CHANGE=$(bc <<< "scale=2; ($ISSUES_CLOSED_LAST_90_DAYS-$ISSUES_CLOSED_PREV_90_DAYS)/$ISSUES_CLOSED_PREV_90_DAYS * 100")

  echo "Community PRs merged in past 90 days vs prev 90 days (delta): ${COMMUNITY_PRS_MERGED_PERCENTAGE_CHANGE}%"
  echo "Total PRs merged in past 90 days vs prev 90 days (delta): ${PRS_MERGED_PERCENTAGE_CHANGE}%"
  echo "Issues closed in past 90 days vs prev 90 days (delta): ${ISSUES_CLOSED_PERCENTAGE_CHANGE}%"

  # Percentage of issues opened by an external contributor in the past 90 days that have a maintainer response within 72 hours

  ISSUES_CREATED_LAST_90_DAYS=$(gh issue list --search "${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS} created:${DATE_90_DAYS_AGO}..${DATE_TODAY}" --limit 1000 --json number --jq '[.[] | .number]')
  NUM_ISSUES_CREATED=$(jq '. | length' <<< $ISSUES_CREATED_LAST_90_DAYS)
  NUM_ISSUES_REPLIED_TO=0

  echo "Issues created last 90 days: ${ISSUES_CREATED_LAST_90_DAYS}"
  echo "Num issues created last 90 days: ${NUM_ISSUES_CREATED}"

  for issue in $(echo -e $ISSUES_CREATED_LAST_90_DAYS | jq -s 'flatten(1)')
  do
    if [ "$issue" = "[" ] || [ "$issue" = "]" ]; then
      :
    else
      ISSUE_DETAILS=$(gh issue view ${issue//,} --json createdAt,comments)

      ISSUE_OPENED_DATE=$(jq '. | .createdAt' <<< $ISSUE_DETAILS)

      echo "Issue number: ${issue//,}"
      echo "Issue opened date: ${ISSUE_OPENED_DATE}"

      # get relative datetime 3 days after issue opened
      THREE_DAYS_AFTER_ISSUE_OPENED=$(date -j -v+3d -f "%Y-%m-%dT%H:%M:%SZ" "${ISSUE_OPENED_DATE//\"}" "+%Y-%m-%dT%H:%M:%SZ")

      echo "3 days after issue opened: ${THREE_DAYS_AFTER_ISSUE_OPENED}"

      # get number of comments by maintainers within the first 3 days
      # NB: manually filter out apollo-cla bot, but otherwise include all users
      # with MEMBER association (i.e. Apollo GraphQL org members)
      ISSUE_COMMENTS=$(jq --arg DATE "$THREE_DAYS_AFTER_ISSUE_OPENED" '. | [.comments[] | select(.authorAssociation == "MEMBER" and .author.login != "apollo-cla" and .createdAt <= $DATE)] | length' <<< $ISSUE_DETAILS)

      echo "Issue comments: ${ISSUE_COMMENTS}"

      if [ "$ISSUE_COMMENTS" = "0" ]; then
        echo "Issue without a reply in 72 hours: ${issue//,}"
      else
        echo "Issue with a reply in 72 hours: ${issue//,}"
        NUM_ISSUES_REPLIED_TO=$((NUM_ISSUES_REPLIED_TO+1))
      fi
    fi
  done

  PERCENTAGE_ISSUES_REPLIED_TO=$(bc <<< "scale=2; ($NUM_ISSUES_REPLIED_TO/$NUM_ISSUES_CREATED) * 100")
  echo "Issues replied to within 72 hours: ${PERCENTAGE_ISSUES_REPLIED_TO}%"

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
