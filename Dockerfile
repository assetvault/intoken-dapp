FROM node:8.0.0-alpine

USER root
ENV USER root
RUN mkdir -p /opt/inbot-dapp
WORKDIR /opt/inbot-dapp

RUN apk add -t .gyp --no-cache git python g++ make \
    && npm install -g truffle \
    && npm install zeppelin-solidity \
    && apk del .gyp

COPY . .

EXPOSE 8080
ENTRYPOINT []