#!/bin/bash
echo ; echo
echo "## Starting watcher operation" ; echo

npm run watch > watch.log &

while :
do
  echo ; echo
  echo '## Waiting for CHANGE' ; echo
  npx nodemon --exitcrash -C -q -d 1 -w ./dist/ --exec false

  echo ; echo
  echo '## cat watch.log'
  cat watch.log
  date > watch.log

  echo ; echo
  echo '## Rebuilding docker $DKR_DST'; echo
  cat > ./dist/Dockerfile << EOF
FROM $DKR_SRC
COPY . /usr/src/app/dist
EOF

  docker build -t $DKR_DST ./dist

  echo ; echo
  echo '## Updating docker service'; echo

  docker push 127.0.0.1:5003/test/live 
  docker service update test-live --detach=false --image 127.0.0.1:5003/test/live 
done
