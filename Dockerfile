FROM node:9.3.0 as nodejs_base


FROM nodejs_base as build_base
WORKDIR /usr/src/app
COPY approot/package.json approot/*package-lock.json approot/*yarn.lock /usr/src/app/


FROM build_base as build_deps_prod
RUN NODE_ENV=production npm install --prod


FROM build_base as build_deps_dev
RUN NODE_ENV=development npm install
COPY approot/ /usr/src/app/
RUN npm -s run build


FROM build_deps_dev as devel


FROM debian:jessie as final
WORKDIR /usr/src/app
CMD [ "/usr/local/bin/node", "./dist" ]
COPY --from=nodejs_base /usr/local/bin/node /usr/local/bin/node
COPY --from=build_deps_prod /usr/src/app/ /usr/src/app/
COPY --from=build_deps_dev /usr/src/app/dist/ /usr/src/app/dist/

