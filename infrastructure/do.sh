#!/bin/bash

MAIN=`dirname $0`/main.py

ssh='ssh -l root'

list() {
    python $MAIN list "$1"
}

gen_xen() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        $ssh $host "mkdir -p /root/ructf2014-quals" </dev/null
        python $MAIN gen_xen $host $vm "$2" </dev/null \
            | $ssh $host "cat >/root/ructf2014-quals/ructf2014q-$vm.cfg"
    done
}

gen_lvm() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        size=$(python $MAIN get_attr $vm disk)
        $ssh $host "[ -e /dev/data/ructf2014q-$vm ] || lvcreate -L${size}G -nructf2014q-$vm data" \
            </dev/null
   done
}

startvms() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        $ssh $host "xm create /root/ructf2014-quals/ructf2014q-$vm.cfg" </dev/null
   done
}

stopvms() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        $ssh $host "xm shutdown ructf2014q-$vm.cfg" </dev/null
   done
}

killvms() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        $ssh $host "xm destroy ructf2014q-$vm.cfg" </dev/null
   done
}

check_res() {
    python $MAIN check_res
}

gen_user_chains() {
    ipp=/etc/openvpn/runc/ipp.txt
    iface=tun0
    target=UaA

    python $MAIN gen_user_chains $ipp $iface $target | sh -s
}

gen_int_access() {
    chain=ructf2014q-int
    python $MAIN gen_int_access $chain | sh -s
}

gen_xen_vnc() {
    chain=ructf2014q-xen
    python $MAIN gen_xen_vnc $chain | sh -s
}

gen_iptables() {
    gen_user_chains
    gen_int_access
    gen_xen_vnc
}

gen_nagios() {
    file=/var/lib/cfg/nagios/ructf2014q.cfg
    python $MAIN gen_nagios > $file.new
    if ! [ -e $file ] || ! cmp $file.new $file; then
        mv $file.new $file
        /etc/init.d/nagios3 reload
    fi
}

prepare_partition() {
    host=$1
    vm=$2
    disk=/dev/data/ructf2014q-$vm
    $ssh $host <<END
        parted -s $disk 'mklabel msdos'
        parted -s $disk 'mkpart primary ext4 0% 100%'
        partition=\$(kpartx -l $disk | cut -f1 -d' ')
        kpartx -a $disk
        mkfs.ext4 /dev/mapper/\$partition
        kpartx -d $disk
END
}

debootstrap() {
    include='openssh-server,augeas-tools,htop,mc,less,vim,grub2,ifupdown,locales'
    host=$1
    vm=$2
    os=$3
    if [ "$os" == 'debian' ]; then arch=amd64; kernel=linux-image-3.2.0-4-amd64
    elif [ "$os" == 'debian32' ]; then arch=i386; kernel=linux-image-3.2.0-4-686-pae
    else echo >&2 "wrong os: $os"; exit 1; fi
    suite=stable
    mirror='http://mirror.yandex.ru/debian/'
    target="/root/ructf2014-quals/ructf2014q-$vm"
    disk=/dev/data/ructf2014q-$vm
    $ssh $host <<END
        grub_dev=\$(readlink -f $disk)
        partition=\$(kpartx -l $disk | cut -f1 -d' ')
        kpartx -a $disk
        mkdir -p $target
        mount /dev/mapper/\${partition} $target
        debootstrap \
            --include=$include,$kernel --arch=$arch \
            $suite $target $mirror
        chroot $target bash -c "mount dev /dev -t devtmpfs; \
                                mount proc /proc -t proc; \
                                mount sys /sys -t sysfs; \
                                echo '(hd0) \$grub_dev' > /boot/grub/device.map; \
                                grub-install \$grub_dev; \
                                update-grub; \
                                umount /{dev,proc,sys}"
        umount $target
        kpartx -d $disk
END
}

customize() {
    host=$1
    vm=$2
    script="/root/ructf2014-quals/ructf2014q-$vm.custom"
    python $MAIN customize $vm | $ssh $host "cat > $script"
    disk=/dev/data/ructf2014q-$vm
    target="/root/ructf2014-quals/ructf2014q-$vm"
    $ssh $host <<END
        partition=\$(kpartx -l $disk | cut -f1 -d' ')
        kpartx -a $disk
        mount /dev/mapper/\${partition} $target
        cp $script $target/root/customize.sh
        chmod +x $target/root/customize.sh
        chroot $target /root/customize.sh
        umount $target
        kpartx -d $disk
END
}

setup_debian() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        os=$(python $MAIN get_attr $vm os)
        if [ "$os" == 'debian' ] || [ "$os" == 'debian32' ]; then
            prepare_partition $host $vm
            debootstrap $host $vm $os
            customize $host $vm
        fi
    done
}

$@
