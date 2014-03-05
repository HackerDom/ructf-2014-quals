#!/bin/bash

MAIN=`dirname $0`/main.py

list() {
    python $MAIN list "$1"
}

gen_xen() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        ssh $host "mkdir -p /root/ructf2014-quals" </dev/null
        python $MAIN gen_xen $host $vm "$2" </dev/null \
            | ssh $host "cat >/root/ructf2014-quals/ructf2014q-$vm.cfg"
    done
}

gen_lvm() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        size=$(python $MAIN get_attr $vm disk)
        ssh $host "[ -e /dev/data/ructf2014q-$vm ] || lvcreate -L${size}G -nructf2014q-$vm data" \
            </dev/null
   done
}

startvms() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        ssh $host "xm create /root/ructf2014-quals/ructf2014q-$vm.cfg" </dev/null
   done
}

stopvms() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        ssh $host "xm shutdown ructf2014q-$vm.cfg" </dev/null
   done
}

killvms() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        ssh $host "xm destroy ructf2014q-$vm.cfg" </dev/null
   done
}

check_res() {
    python $MAIN check_res
}

$@
