#!/bin/sh

for f in tests/*; do
    if [ -d "$f" ]; then
        echo "# Test ${f}"
        ./ws "$f"/data.csv "$f"/user.txt "$f"/view0.csv "$f"/changes.txt
        echo
    fi
done
