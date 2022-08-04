#!/usr/bin/env bash
# 2022.08.04 - ducet8@outlook.com

function show_hidden() {
    defaults write com.apple.Finder AppleShowAllFiles TRUE
    killall Finder
}

export -f show_hidden