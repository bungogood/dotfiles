# Dotfiles
This repository contains dotfile used for system config. Using the config alias files can be added to this repository.

## Requirements

- git
- curl

## Installation

```sh
curl -Lks https://raw.githubusercontent.com/Bungogood/dotfiles/master/.dotfiles/install.sh | /bin/bash
```

## Docker

```sh
docker build -t dotfiles ~/.dotfiles
docker run --rm -it dotfiles
```

## References

- https://www.atlassian.com/git/tutorials/dotfiles
- https://bitbucket.org/durdn/cfg.git