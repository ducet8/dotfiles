#!/usr/bin/env bash

function show_hidden() {
    defaults write com.apple.Finder AppleShowAllFiles TRUE
    killall Finder
}

export -f show_hidden