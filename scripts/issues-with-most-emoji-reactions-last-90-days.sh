#!/usr/bin/env bash

ISSUES_CREATED_LAST_90_DAYS=$(gh issue list --search "${FILTERED_OUT_LABELS} ${FILTERED_OUT_USERS} created:>=${DATE_90_DAYS_AGO} sort:reactions" --state all --limit 10 --json number,reactionGroups,url,title)

echo $ISSUES_CREATED_LAST_90_DAYS
INDEX=1
MESSAGE=""

for row in $(echo "${ISSUES_CREATED_LAST_90_DAYS}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${row} | base64 --decode | jq -r ${1}
    }

    ISSUE_NUMBER=$(_jq '.number')
    ISSUE_REACTIONS=$(_jq '.reactionGroups')
    ISSUE_URL=$(_jq '.url')
    ISSUE_TITLE=$(_jq '.title')

    EMOJI_STRING=""

    for reaction in $(echo "${ISSUE_REACTIONS}" | jq -r '.[] | @base64'); do
        _jq() {
         echo ${reaction} | base64 --decode | jq -r ${1}
        }

        # get ReactionContent enum value and convert to lowercase
        REACTION_CONTENT=$(_jq '.content' | tr [:upper:] [:lower:])
        REACTION_TOTAL_COUNT=$(_jq '.users.totalCount')

        echo "Reaction content: $REACTION_CONTENT"

        # remap ReactionContent to Slack parsable emoji strings
        # which just requires mapping thumbs up/down, since
        # all other enum values already are valid Slack emoji strings
        # https://docs.github.com/en/graphql/reference/enums#reactioncontent
        EMOJI_REMAPPED=""

        if [ "$REACTION_CONTENT" == "thumbs_up" ]; then
          EMOJI_REMAPPED=":+1:"
        elif [ "$REACTION_CONTENT" == "thumbs_down" ]; then
          EMOJI_REMAPPED=":-1:"
        elif [ "$REACTION_CONTENT" == "hooray" ]; then
          EMOJI_REMAPPED=":tada:"
        else
          EMOJI_REMAPPED=":${REACTION_CONTENT}:"
        fi

        EMOJI_STRING="${EMOJI_STRING} ${EMOJI_REMAPPED} (${REACTION_TOTAL_COUNT})"
        echo "Reaction users: $REACTION_TOTAL_COUNT"
    done

    echo "Emoji string: $EMOJI_STRING"
    if [ "$EMOJI_STRING" ]; then
      # if no reactions, then don't include in message
      MESSAGE="${MESSAGE}${INDEX}. *<${ISSUE_URL}|#${ISSUE_NUMBER}>*${EMOJI_STRING} - ${ISSUE_TITLE}\n"
      INDEX=$((INDEX+1))
    fi
done

QUOTES_ESCAPED_MESSAGE=$(echo $MESSAGE | tr \" \')

echo "WEEKLY_TOP_EMOJI_UPVOTED_ISSUES=${QUOTES_ESCAPED_MESSAGE}" >> "$GITHUB_OUTPUT"
