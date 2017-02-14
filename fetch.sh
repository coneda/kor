#!/bin/bash -e

REPO=$1
BRANCH=${2:-master}

git archive --format=tar --remote=$REPO $BRANCH | tar xf -
