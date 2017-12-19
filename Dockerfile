FROM node:9.3.0 as nodejs_base


FROM nodejs_base as deps_base
WORKDIR /usr/src/app
COPY approot/package.json approot/*package-lock.json approot/*yarn.lock /usr/src/app/


FROM deps_base as dependencies
RUN NODE_ENV=production npm install --prod


FROM deps_base as build
RUN NODE_ENV=development npm install
COPY approot/ /usr/src/app/
RUN npm -s run build


FROM debian:jessie as final
WORKDIR /usr/src/app
CMD [ "/usr/local/bin/node", "./dist" ]
COPY --from=nodejs_base /usr/local/bin/node /usr/local/bin/node
COPY --from=dependencies /usr/src/app/ /usr/src/app/
COPY --from=build /usr/src/app/dist/ /usr/src/app/dist/

