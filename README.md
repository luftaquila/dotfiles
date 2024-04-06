# dotfiles

## Prerequisites

### Linux

```sh
sudo apt-get update && sudo apt-get -y install curl
```

### MacOS

```sh
brew update && brew install curl
```

## Download

```sh
curl -L https://raw.githubusercontent.com/luftaquila/dotfiles/main/init.sh > init.sh && chmod +x init.sh
```

## Run

```sh
./init.sh
./init.sh auto # confirm all user prompts
./init.sh all  # do all stages without confirm
```
