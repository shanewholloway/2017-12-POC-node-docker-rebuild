#!/bin/bash
export DKR_DST=127.0.0.1:5003/test/live

echo ; echo
echo '## Rebuild live docker image'; echo
docker build --target live -f ./Dockerfile.watch -t $DKR_DST .

echo ; echo
echo '## Pushing live docker image'; echo
docker push $DKR_DST

echo ; echo
echo '## Updating docker service with live image'; echo
docker service update test-live --image $DKR_DST --detach=false 

