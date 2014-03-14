#!/bin/bash

trap 'kill -KILL $(jobs -p)' SIGINT SIGTERM SIGKILL

dolbilka_cfg=/tmp/ructf2014q-dolbilka.cfg
IFS=$'\n' targets=($(grep "^$SLURM_NODEID:" $dolbilka_cfg | grep http | cut -f2- -d:))
for target in ${targets[@]}; do
    host=${target##*:}
    ab -r -n 1000000 http://$host.quals.ructf.org/ &
done

wait
