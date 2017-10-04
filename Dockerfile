FROM dapp:latest
RUN sudo mkdir -p /src/inbot-dapp

WORKDIR /src/inbot-dapp
COPY . .

RUN sudo dapp build

CMD [ "sudo", "dapp", "test"]