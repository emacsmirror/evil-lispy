#!/usr/bin/env bash

TERM=dumb SHELL=sh cask exec emacs \
    -Q \
    -batch \
    -f package-initialize \
    -l buttercup \
    -l "tests/setup.el" \
    -f buttercup-run-discover \
    "tests/"
