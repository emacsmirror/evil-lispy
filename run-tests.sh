#!/usr/bin/env sh

set +x # show executed commands
set +e # exit on error

cask

TERM=dumb SHELL=sh cask exec emacs \
    -Q \
    -batch \
    -f package-initialize \
    -l buttercup \
    --directory "." \
    -l evil-lispy \
    -l "tests/setup.el" \
    -f buttercup-run-discover \
    "tests/"
