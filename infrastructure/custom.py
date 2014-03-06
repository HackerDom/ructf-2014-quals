def customize(vms, vm, keypath):
    if vm.addr.startswith('172.16.16.'):
        gateway = '172.16.16.254'
    elif vm.addr.startswith('194.226.244.'):
        gateway = '194.226.244.126'
    else:
        raise Exception('cannot calc gateway for %s' % vm.addr)
    print """#!/bin/bash

cat > /etc/network/interfaces <<END
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address %s
    netmask %s
    gateway %s
END
""" % (vm.addr, vm.network, gateway)

    admins = ['uzer', 'last_g', vm.admin.partition('@')[0]]
    print """mkdir -p /root/.ssh
             touch /root/.ssh/authorized_keys
             chmod 600 /root/.ssh/authorized_keys
             cat > /root/.ssh/authorized_keys <<END"""
    for admin in admins:
        with open ('%s/%s' % (keypath, admin), 'r') as key:
            print key.read().strip()
    print """END
"""
    print "echo %s > /etc/hostname" % (vm.name)
