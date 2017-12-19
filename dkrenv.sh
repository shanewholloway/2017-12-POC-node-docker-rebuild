#!/bin/bash

function cmd_create {
  cmd_build
  docker service create --detach=false --name=$DKRENV_SVC $DKRENV_IMG
}
function cmd_update {
  cmd_build
  docker service update --detach=false --image $DKRENV_IMG:latest $DKRENV_SVC
}
function cmd_start {
  DKR_IDS=$(docker ps -q --filter "label=com.docker.swarm.service.name=$DKRENV_SVC")
  if [[ -z "$DKR_IDS" ]] ; then
    cmd_create ;
  else
    cmd_update ;
  fi
}
function cmd_stop {
  docker service rm $DKRENV_SVC 2&> /dev/null
}


function cmd_exec {
  DKR_IDS=$(docker ps -q --filter "label=com.docker.swarm.service.name=$DKRENV_SVC")
  docker exec -it $DKR_IDS bash
}
function cmd_logs {
  docker service logs $DKRENV_SVC --follow
}



function cmd_build {
  docker build -t $DKRENV_IMG:latest .
  docker push $DKRENV_IMG:latest
}

function cmd_build_devel {
  # Use the primary Dockerfile build target to create $DKRENV_IMG:build
  docker build --target build -t $DKRENV_IMG:build .

  # Add any localized devel overrides to the build image, creating $DKRENV_IMG:devel
  docker build -f ./Dockerfile.devel --build-arg DKRENV_IMG=$DKRENV_IMG -t $DKRENV_IMG:devel .
}

function cmd_watch {
  cmd_start

  cmd_build_devel

  # Watch for dist changes; upon change run the live entrypoint of this script
  nodemon -Id 1 \
    -w ./approot/dist \
    -w ./approot/deps/*/dist \
    --exec "bash $0 live"
}

function cmd_live {
  # Apply changes atop the $DKRENV_IMG:devel to create the new $DKRENV_IMG:live
  docker build -f ./Dockerfile.live --build-arg DKRENV_IMG=$DKRENV_IMG -t $DKRENV_IMG:live .

  # Update the service to use $DKRENV_IMG:live
  docker push $DKRENV_IMG:live
  docker service update --image $DKRENV_IMG:live --detach=false $DKRENV_SVC
}



if [[ -n "$npm_package_dkrenv_svc" ]] ; then export DKRENV_SVC=$npm_package_dkrenv_svc ; fi
if [[ -n "$npm_package_dkrenv_img" ]] ; then export DKRENV_IMG=$npm_package_dkrenv_img ; fi
if [[ -z "$DKRENV_SVC" || -z "$DKRENV_IMG" ]] ; then exec npm -s run :dkrenv -- $1; fi

case "$1" in
  start) cmd_start ;;
  stop) cmd_stop ;;
  create) cmd_create ;;
  update) cmd_update ;;

  logs) cmd_logs ;;
  exec) cmd_exec ;;

  build) cmd_build ;;
  devel) cmd_build_devel ;;
  watch) cmd_watch ;;
  live) cmd_live ;;

  *)
    echo $"Usage: $0 {start|stop|update|build|watch|logs|exec}"
    exit 1 ;;
esac ;

exit 0

