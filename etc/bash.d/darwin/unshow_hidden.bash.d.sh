#!/usr/bin/env bash

function unshow_hidden() {
    defaults write com.apple.Finder AppleShowAllFiles FALSE
    killall Finder
}

export -f unshow_hidden