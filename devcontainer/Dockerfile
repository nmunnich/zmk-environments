FROM ubuntu:noble-20250925

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
  && curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install linux --init none --no-confirm

ENV PATH=/nix/var/nix/profiles/default/bin:${PATH}

RUN apt-get install -y --no-install-recommends \
  git \
  openssh-client \
  procps \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*
