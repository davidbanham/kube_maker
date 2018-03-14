#!/bin/sh

UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

if [ $LOCAL = $REMOTE ]; then
    echo "Up-to-date"
elif [ $LOCAL = $BASE ]; then
    echo "Need to pull"
    exit 1
elif [ $REMOTE = $BASE ]; then
    echo "Need to push"
    exit 1
else
    echo "Diverged"
    exit 1
fi
