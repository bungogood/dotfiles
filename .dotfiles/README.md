# Dotfiles
This repository contains dotfile used for system config. Using the `config` alias files can be added to this repository.

## Requirements

- git
- curl

## Installation

```sh
curl -Lks https://raw.githubusercontent.com/Bungogood/dotfiles/master/.dotfiles/install.sh | /bin/bash
```

## Adding Changes

```sh
config add <file>
config commit -m "Updaing <file>"
config push
```

## Update Dotfiles

```sh
config pull
```

## Docker Preview
This runs the install script in an alpine container to test the install and any changes.

```sh
docker build -t dotfiles ~/.dotfiles
docker run --rm -it dotfiles
```

## References

- https://www.atlassian.com/git/tutorials/dotfiles
- https://bitbucket.org/durdn/cfg.git
- https://askubuntu.com/questions/466198/how-do-i-change-the-color-for-directories-with-ls-in-the-console
