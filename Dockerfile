FROM dapp:latest

USER root
ENV USER root
RUN mkdir -p /opt/inbot-dapp

WORKDIR /opt/inbot-dapp

RUN git init
RUN git config --global user.email "jenkins@inbot.io"
RUN git config --global user.name "Jenkins"

COPY Dappfile ./Dappfile
COPY Makefile ./Makefile
COPY src/ ./src

RUN dapp install ds-token
RUN dapp build

CMD [ "dapp", "test"]