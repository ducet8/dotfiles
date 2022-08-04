#!/usr/bin/env bash
# 2022.08.04 - ducet8@outlook.com

function unshow_hidden() {
    defaults write com.apple.Finder AppleShowAllFiles FALSE
    killall Finder
}

export -f unshow_hidden