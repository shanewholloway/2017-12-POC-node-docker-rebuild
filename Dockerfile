FROM node:9.3.0 as nodejs_base


FROM nodejs_base as build_base
ENV V_NODE_PRUNE=1.0.1
WORKDIR /usr/src/app
RUN curl -sSL "https://github.com/tj/node-prune/releases/download/v${V_NODE_PRUNE}/node-prune_${V_NODE_PRUNE}_linux_amd64.tar.gz" \
    | tar -xzO "node-prune" > /usr/local/bin/node-prune \
 && chmod +x /usr/local/bin/node-prune
COPY approot/package.json approot/*package-lock.json approot/*yarn.lock /usr/src/app/


FROM build_base as build_deps_prod
RUN NODE_ENV=production npm install --prod \
 && node-prune


FROM build_base as build_deps_dev
RUN NODE_ENV=development npm install
COPY approot/ /usr/src/app/
RUN npm -s run build


FROM debian:jessie as final
WORKDIR /usr/src/app
CMD [ "/usr/local/bin/node", "./dist" ]
COPY --from=nodejs_base /usr/local/bin/node /usr/local/bin/node
COPY --from=build_deps_prod /usr/src/app/ /usr/src/app/
COPY --from=build_dist /usr/src/app/dist/ /usr/src/app/dist/

