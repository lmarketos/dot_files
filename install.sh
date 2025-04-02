#!/bin/bash

stow  -v -t /home/louis home
source ~/.bashrc
mkdir -p ${XDG_CONFIG_HOME}
mkdir -p ${XDG_BIN_HOME}
stow  -v -t ${XDG_CONFIG_HOME} config
stow  -v -t ${XDG_BIN_HOME} bin
mkdir -p ${XDG_CONFIG_HOME}/tmux/plugins
stow -v -t ${XDG_CONFIG_HOME}/tmux/plugins deps
