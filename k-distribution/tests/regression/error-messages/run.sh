#!/bin/bash

for i in */*.k.out; do
  echo "// $i"
  kompile "${i%.out}" 2>&1 | grep -v 'Location\|Source' | diff - "$i"
done >>x.k
