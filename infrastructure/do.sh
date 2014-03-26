#!/bin/bash

BASE=`dirname $0`
MAIN="python $BASE/main.py"
SERIAL="python $BASE/dns/serial.py"

ssh='ssh -l root'

list() {
    $MAIN list "$1" "$2" "$3"
}

gen_xen() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        $ssh $host "mkdir -p /root/ructf2014-quals" </dev/null
        $MAIN gen_xen $host $vm "$2" </dev/null \
            | $ssh $host "cat >/root/ructf2014-quals/ructf2014q-$vm.cfg"
    done
}

gen_lvm() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        size=$($MAIN get_attr $vm disk)
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

add_startup() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        $ssh $host "ln -sf /root/ructf2014-quals/ructf2014q-$vm.cfg\
                    /etc/xen/auto/" </dev/null
   done
}

remove_startup() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        $ssh $host "rm -f /etc/xen/auto/ructf2014q-$vm.cfg" </dev/null
   done
}

check_res() {
    $MAIN check_res
}

gen_user_chains() {
    ipp=/etc/openvpn/runc/ipp.txt
    iface=tun0
    target=UaA

    $MAIN gen_user_chains $ipp $iface $target | sh -s
}


gen_int_access() {
    chain=ructf2014q-int
    extra_cns=bay,bosonojka5,victor.samun
    $MAIN gen_int_access $chain $extra_cns | sh -s
}

gen_xen_vnc() {
    chain=ructf2014q-xen
    $MAIN gen_xen_vnc $chain | sh -s
}

gen_iptables() {
    gen_user_chains
    gen_int_access
    gen_xen_vnc
    echo "don't forget to /etc/init.d/iptables save active"
}

gen_nagios() {
    file=/var/lib/cfg/nagios/ructf2014q.cfg
    $MAIN gen_nagios > $file.new
    if ! [ -e $file ] || ! cmp $file.new $file; then
        mv $file.new $file
        /etc/init.d/nagios3 reload
    fi
}

gather_ssh() {
    list ":" | while read line; do
        vm=${line##*:}
        addr=$($MAIN addr $vm)
        os=$($MAIN get_attr $vm os)
        if [ "$os" == debian ] || [ "$os" == debian32 ] || [ "$os" == arch ]; then
            $ssh -o StrictHostKeyChecking=no $addr hostname </dev/null
        fi
    done
}

setup_iptables() {
    custom="$2"
    list "$1" | while read line; do
        vm=${line##*:}
        addr=$($MAIN addr $vm)
        os=$($MAIN get_attr $vm os)
        base=$(dirname $0)
        if [ "$os" == debian ] || [ "$os" == debian32 ]; then
            scp $base/iptables/init root@$addr:/etc/init.d/iptables
            scp $base/iptables/default root@$addr:/etc/default/iptables
            $ssh $addr update-rc.d iptables defaults </dev/null
            $ssh $addr mkdir -p /var/lib/iptables </dev/null

            $ssh $addr "\
                iptables -P INPUT ACCEPT; iptables -P OUTPUT ACCEPT; \
                iptables -F INPUT; iptables -F OUTPUT; \
                \
                if ! iptables -L custom-input &>/dev/null; then \
                    iptables -N custom-input; \
                fi; \
                iptables -A INPUT -j custom-input; \
                iptables -A INPUT -i lo -j ACCEPT; \
                \
                if ! iptables -L custom-output &>/dev/null; then \
                    iptables -N custom-output; \
                fi; \
                iptables -A OUTPUT -j custom-output; \
                iptables -A OUTPUT -o lo -j ACCEPT; \
                \
                iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT; \
                iptables -A INPUT -p icmp -j ACCEPT; \
                iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT; \
                \
                iptables -A OUTPUT -p icmp -j ACCEPT; \
                iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT; \
                :                                       DNS 1; \
                iptables -A OUTPUT -p udp --dport 53 -d 194.226.244.126 \
                    -m state --state NEW -j ACCEPT; \
                :                                       DNS 2; \
                iptables -A OUTPUT -p udp --dport 53 -d 194.226.235.22 \
                    -m state --state NEW -j ACCEPT; \
                :                                       mirror.yandex.ru; \
                iptables -A OUTPUT -p tcp --dport 80 -d 213.180.204.183 \
                    -m state --state NEW -j ACCEPT;
            " </dev/null

            if [ "$custom" == custom ]; then
                $MAIN get_ports $vm | while read portspec; do
                    proto=${portspec%%:*}
                    port=${portspec##*:}
                    $ssh $addr "iptables -A INPUT -p $proto --dport $port \
                                -m state --state NEW -j ACCEPT" </dev/null
                done
            fi

            $ssh $addr "\
                iptables -P INPUT DROP; iptables -P OUTPUT DROP; \
                iptables -P FORWARD DROP; \
                /etc/init.d/iptables save active
            " </dev/null
        fi
    done
}

router=194.226.244.113
vm_prefix=ructf2014q_

router_setup_nat() {
    chain=ructf2014q
    $MAIN gen_nat $router $chain | $ssh $router "sh -s"
    $ssh $router '/etc/init.d/iptables save active'
}

router_setup_fwd() {
    chain=ructf2014q
    $MAIN gen_fwd $chain $vm_prefix | $ssh $router "sh -s"
    $ssh $router '/etc/init.d/iptables save active'
}

router_gen_nginx() {
    ban=$(dirname $0)/ban
    list ":" | while read line; do
        vm=${line##*:}
        config=/etc/nginx/sites-available/ructf2014q-$vm
        $MAIN gen_nginx $vm $ban | $ssh $router "cat > $config"
    done
}

nudge_services() {
    if [ "$iptables_needs_save" ]; then
        $ssh $router '/etc/init.d/iptables save active'
    fi
    if [ "$nginx_needs_reload" ]; then
        $ssh $router '/etc/init.d/nginx reload'
    fi
}

router_enable() {
    ban=$(dirname $0)/ban
    vms=($(list $1))
    for line in ${vms[@]}; do
        vm=${line##*:}
        if [ "$($MAIN get_attr $vm tcp_ports)" != '[]' ] || \
           [ "$($MAIN get_attr $vm udp_ports)" != '[]' ]; then
            iptables_needs_save=1
            chain=$vm_prefix$vm
            { echo -n "iptables -F $chain; "
              if [ -e "$ban/$vm" ]; then
                IFS=$'\n' bans=($(cat "$ban/$vm")); IFS=$' '
                for banned in ${bans[@]}; do
                    echo -n "iptables -A $chain -s $banned -j DROP; "
                done
              fi
              echo "iptables -A $chain -j UaA"
            } | $ssh $router 'sh -s'
        elif [ "$($MAIN get_attr $vm http)" == True ]; then
            nginx_needs_reload=1
            config=/etc/nginx/sites-available/ructf2014q-$vm
            $MAIN gen_nginx $vm $ban | $ssh $router "cat > $config"
            $ssh $router "ln -sf $config /etc/nginx/sites-enabled/"
        fi
    done
    nudge_services
}

router_disable() {
    vms=($(list $1))
    for line in ${vms[@]}; do
        vm=${line##*:}
        if [ "$($MAIN get_attr $vm tcp_ports)" != '[]' ] || \
           [ "$($MAIN get_attr $vm udp_ports)" != '[]' ]; then
            iptables_needs_save=1
            chain=$vm_prefix$vm
            $ssh $router "iptables -F $chain"
        elif [ "$($MAIN get_attr $vm http)" == True ]; then
            nginx_needs_reload=1
            link=/etc/nginx/sites-enabled/ructf2014q-$vm
            $ssh $router "rm -f $link"
        fi
    done
    nudge_services
}

setup_interfaces() {
    vms=($(list $1))
    for line in ${vms[@]}; do
        vm=${line##*:}
        os=$($MAIN get_attr $vm os)
        addr=$($MAIN get_attr $vm addr)
        if [ "$os" == 'debian' ] || [ "$os" == 'debian32' ] && \
            [ "$vm" != router ]; then
            $MAIN gen_interfaces $vm | $ssh $addr \
                'cat > /etc/network/interfaces'
            $ssh $addr "ifdown -a; ifup -a"
        fi
    done
}

pssh() {
    patt=$1; shift
    os=$1; shift
    vms=($(list $patt $os addr | cut -f3 -d:))
    echo "$*" | parallel-ssh -l root -i -I -H "${vms[*]}"
}

pscp() {
    patt=$1
    os=$2
    localfile=$3
    remotefile=$4
    list $patt $os addr | cut -f3 -d: | parallel-scp -v -h /dev/stdin \
        -l root $localfile $remotefile
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
    $MAIN customize $vm | $ssh $host "cat > $script"
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

backup() {
  host=$1
  backup=$(dirname $0)/backup.sh
  user=backup-ructf2014q
  IFS=$'\n' vms=($(list $1: linux)); IFS=$' '
  for line in ${vms[@]}; do
      vm=${line##*:}
      addr=$($MAIN get_attr $vm addr)
      su $user -c "$backup $addr $vm"
  done
}

setup_debian() {
    list "$1" | while read line; do
        host=${line%%:*}
        vm=${line##*:}
        os=$($MAIN get_attr $vm os)
        if [ "$os" == 'debian' ] || [ "$os" == 'debian32' ]; then
            prepare_partition $host $vm
            debootstrap $host $vm $os
            customize $host $vm
        fi
    done
}

gen_dolbilka() {
    # TODO(uzer): just for example
    clients=5

    partition=managed
    dolbilka_cfg=/tmp/ructf2014q-dolbilka.cfg
    knock=/tmp/ructf2014q-knock.sh

    nodes=$(tempfile)
    sinfo -p $partition -t idle -h -o '%n' > $nodes
    nnodes=$(sinfo -p $partition -t idle -h -o '%n' | wc -l)

    cfg=$(tempfile)
    $MAIN gen_dolbilka $nnodes $clients > $cfg

    parallel-scp -v -h $nodes $cfg $dolbilka_cfg
    parallel-scp -v -h $nodes $(dirname $0)/knock.sh $knock

    rm $nodes $cfg
}

dolbim() {
    partition=managed
    knock=/tmp/ructf2014q-knock.sh
    srun -D/ -N1-100 -p $partition $knock
}

cmp_files() {
    set +e; cmp -s $1 $2; local rv=$?; set -e
    return $rv
}

gen_dns() {
    DATA=/var/lib/cfg
    RELOAD=0

    gen_zone() {
        CMD=$1
        ZONE=$2
        TEMPLATE=$BASE/dns/$ZONE.master.template

        local SFILE=$DATA/$ZONE.serial
        local CUR=$DATA/$ZONE.master
        local OLD=$CUR.old NEW=$CUR.new

        set +e; SOLD=$($SERIAL get $SFILE 2>/dev/null); rv=$?; set -e
        if [ $rv -ne 0 ]; then
            RELOAD=1
            local SNEW=$($SERIAL inc $SFILE)
            $MAIN $CMD $TEMPLATE $SNEW > $CUR
        else
            $MAIN $CMD $TEMPLATE $SOLD > $OLD
            if ! cmp_files $CUR $OLD; then
                RELOAD=1
                rm $OLD
                SNEW=$($SERIAL inc $SFILE)
                $MAIN $CMD $TEMPLATE $SNEW > $NEW
                mv $NEW $CUR
            else
                rm $OLD
            fi
        fi
    }

    gen_zone gen_int_dns i.quals.ructf.org
    gen_zone gen_ext_dns quals.ructf.org

    if [ $RELOAD -ne 0 ]; then
        /etc/init.d/bind9 reload
    fi
}

$@
