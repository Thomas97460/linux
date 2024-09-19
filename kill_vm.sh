#!/bin/bash

pids=$(lsof -i | grep qemu-syst | awk '{print $2}' | sort | uniq)
for pid in $pids; do
  echo "Killing process with PID: $pid"
  kill -9 $pid
done
rm -rf *.fd *.qcow2*
echo "Tous les processus qemu-system ont été terminés."