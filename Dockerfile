###################
# BUILD FOR LOCAL DEVELOPMENT
###################
FROM node:18-alpine As development

WORKDIR /usr/src/app

COPY --chown=node:node package.json ./
COPY --chown=node:node yarn.lock ./

RUN yarn

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:hydrogen-alpine AS build-production

WORKDIR /usr/src/app

COPY --chown=node:node package.json ./
COPY --chown=node:node yarn.lock ./
COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules
COPY --chown=node:node . .

ENV NODE_ENV production

RUN yarn build

RUN yarn install --frozen-lockfile --production && yarn cache clean

USER node

###################
# PRODUCTION
###################

FROM node:hydrogen-alpine AS production

LABEL maintainer="Alejandro Hernández <hola@alejandroherr.io>"


COPY --chown=node:node package.json ./
COPY --chown=node:node --from=build-production /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build-production /usr/src/app/dist ./dist

CMD [ "yarn", "start:prod" ]