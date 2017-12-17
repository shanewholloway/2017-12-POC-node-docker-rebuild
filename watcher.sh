#!/bin/bash
if [[ -z "$DKR_DST" ]]; then
  export WATCHER_NAME=WATCHER_${PWD//\//_}

  export VOL_CODE=$PWD/approot/code/:/usr/src/app/code/

  export DKR_SRC=127.0.0.1:5003/test
  export DKR_DEV_BASE=$DKR_SRC/dev
  export DKR_WATCHER=$DKR_SRC/watcher
  export DKR_DST=$DKR_SRC/live


  echo ; echo
  echo "Building FINAL"; echo

  docker build --target final -t $DKR_SRC .

  echo ; echo
  echo "Building DEV environment"; echo
  docker build --target build_deps_dev -t $DKR_DEV_BASE .

  echo ; echo
  echo "Building WATCH environment"; echo
  cat > ./Dockerfile.watcher << EOF
FROM $DKR_DEV_BASE
COPY --from=docker /usr/local/bin/docker /usr/local/bin/docker
COPY watcher.sh /usr/src/app
CMD bash watcher.sh
EOF

  docker build -f ./Dockerfile.watcher -t $DKR_WATCHER .
  # cat ./Dockerfile.watcher
  rm ./Dockerfile.watcher

  echo ; echo
  echo "Running WATCH environment"; echo

  export VOL_DOCKER=/var/run/docker.sock:/var/run/docker.sock
  docker rm -f $WATCHER_NAME || true
  docker run --rm -t --name $WATCHER_NAME \
    -v $VOL_DOCKER \
    -v $VOL_CODE \
    -e "DKR_SRC=$DKR_SRC" -e "DKR_DST=$DKR_DST" \
    $DKR_WATCHER

  exit 0
else


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
  done

fi
