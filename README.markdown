# Proof of Concept for a rapid iteration docker service development environment

### Try it

Start a local Docker Registry so you can rapidly develop a Docker Swarm based service.

```shell
% npm -s run dkr-registry-init
```

Start the docker service by building it and starting the watch process

```shell
% npm -s run watch
```

In another window, run docker logs with follow to see the program's output:

```shell
% npm -s run logs
```

In yet another window, start the babel-based compile watcher:

```shell
% cd approot
% npm -s run watch
```

Then open your favorite editor and make a change to `approot/code/index.jsy`.

Babel should compile the file from JSY into standard javascript in the
`approot/dist/` folder.  The outer `dkrenv.sh watch` process will observe the
change to the `approot/dist/` folder and kick off a Docker image build for the
smaller change, push it to the local docker registry, and then update the
service with the new image delta.

