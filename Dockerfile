FROM node:8.0.0-alpine

USER root
ENV USER root
RUN mkdir -p /opt/inbot-dapp
WORKDIR /opt/inbot-dapp

RUN apk add -t .gyp --no-cache git python g++ make \
    && npm install -g truffle \
    && npm install -g ganache-cli \
    && npm install zeppelin-solidity \
    && apk del .gyp

COPY . .

CMD ganache-cli & truffle test