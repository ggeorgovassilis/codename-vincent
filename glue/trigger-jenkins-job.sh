#!/bin/bash

ISSUEID="$1"
ISSUETITLE="$2"
ISSUECONTENT="$3"

[[ -z $ISSUEID ]] && echo "missing parameter issueid" && exit 1
[[ -z $ISSUETITLE ]] && echo "missing parameter issuetitle" && exit 2
[[ -z $ISSUECONTENT ]] && echo "missing parameter issuecontent" && exit 3


export http_proxy=""

JENKINS="http://jenkins:password@jenkins.cnvc"
export JENKINS

echo getting auth token from jenkins
CRUMB=$(curl -s "$JENKINS"'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')

echo submitting issue $ISSUEID to jenkins
TMP=`curl -s -D - -X POST "$JENKINS/job/testjob/buildWithParameters" \
  --form "issueid=$ISSUEID" \
  --form "title=$ISSUETITLE" \
  --form "content=$ISSUECONTENT" \
  -H "$CRUMB" \
  --form json='{"parameter":[{"name":"issueid","value":"$ISSUEID"}, {"name":"title","value":"$ISSUETITLE"},{"name":"content","value":"$ISSUECONTENT"}]}'`

JOBID=`echo "$TMP" | grep Location | cut -d "/" -f 6`

echo Jenkins job $JOBID created for issue $ISSUEID, waiting for job to terminate
STATUS=""
while [ "$STATUS" != 200 ]
do
  sleep 2
  STATUS=`curl -s -o /dev/null -w "%{http_code}" http://jenkins.cnvc/job/testjob/$JOBID/consoleText`
done

echo Reading results for job $JOBID
JOBSTATUS=`curl -s $JENKINS/job/testjob/$JOBID/api/json | jq --raw-output '.result'`
LOGS=`curl -s $JENKINS/job/testjob/$JOBID/consoleText`

echo Job $JOBID finished with status $JOBSTATUS
echo Logs:
echo "$LOGS"
