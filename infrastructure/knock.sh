#!/bin/bash

trap 'kill -KILL $(jobs -p)' SIGINT SIGTERM SIGKILL

dolbilka_cfg=/tmp/ructf2014q-dolbilka.cfg
grep "^$SLURM_NODEID:" $dolbilka_cfg | grep http | cut -f2- -d: | while read line; do
    echo "$HOSTNAME will do ab on $line"
done
