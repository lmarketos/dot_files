#!/bin/bash

stow  -v -t /home/louis home
source ~/.bashrc
stow  -v -t ${XDG_CONFIG_HOME} config
stow  -v -t ${XDG_BIN_HOME} bin
