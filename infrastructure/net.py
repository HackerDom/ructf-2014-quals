def gen_interfaces(vm):
    dijkstra = '172.16.16.254'
    ms = '194.226.244.114'
    router = '172.16.16.252'
    if vm.iface == 'int':
        print """
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address %s
    netmask %s
    gateway %s
    post-up ip route add 172.16.19.0/24 via %s; exit 0
    pre-down ip route del 172.16.19.0/24 via %s; exit 0
""" % (vm.addr, vm.network, router, dijkstra, dijkstra, dijkstra)
    elif vm.iface == 'ext':
        print """
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address %s
    netmask %s
    gateway %s
""" % (vm.addr, vm.network, ms)
    else:
        raise Exception('unknown iface %s' % vm.iface)
