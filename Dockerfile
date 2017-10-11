FROM dapp:latest

USER root
ENV USER root
RUN mkdir -p /opt/inbot-dapp

WORKDIR /opt/inbot-dapp

RUN git init
RUN git config --global user.email "jenkins@inbot.io"
RUN git config --global user.name "Jenkins"

RUN mkdir /etc/nix
RUN touch /etc/nix/nix.conf
RUN echo "build-users-group =" > /etc/nix/nix.conf
RUN curl https://nixos.org/nix/install | bash
RUN /nix/var/nix/profiles/default/bin/nix-env -i ethabi jshon bc

RUN dapp install ds-token

COPY Dappfile ./Dappfile
COPY Makefile ./Makefile
COPY deploy.sh ./deploy.sh
COPY src/ ./src

RUN dapp test

CMD ["/bin/bash"]