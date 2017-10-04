FROM dapp:latest
RUN sudo mkdir -p /src/inbot-dapp

WORKDIR /src/inbot-dapp
COPY . .
COPY ./.git .git

RUN sudo dapp install ds-token
RUN sudo dapp build

CMD [ "sudo", "dapp", "test"]
