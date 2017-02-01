#!/bin/bash

ISSUEID="$1"
STATUS="$2"
LOGS="$3"
GITLABTOKEN=tq_xwN_vaTqtertsYxnU

[[ -z $ISSUEID ]] && echo "missing parameter issueid" && exit 1
[[ -z $STATUS ]] && echo "missing parameter status" && exit 2
[[ -z $LOGS ]] && echo "missing parameter logs" && exit 3


export http_proxy=""

GITLAB="http://gitlab.cnvc"
export GITLAB

echo Updating Gitlab issue $ISSUEID with logs $LOGS
TMP=`curl -s -X POST "$GITLAB/api/v3/projects/1/issues/$ISSUEID/notes" \
  --form "private_token=$GITLABTOKEN" \
  --form "body=$LOGS"`

echo "$TMP"

TMP=`curl -s -X PUT "$GITLAB/api/v3/projects/1/issues/$ISSUEID" \
  --form "private_token=$GITLABTOKEN" \
  --form "labels=$STATUS"`
 

echo "$TMP"

