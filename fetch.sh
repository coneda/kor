#!/bin/bash -e

REPO=$1

git archive --format=tar --remote=$REPO master | tar xf -
