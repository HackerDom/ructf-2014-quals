def gen_interfaces(vm):
    dijkstra_int = '172.16.16.254'
    dijkstra_ext = '194.226.244.126'
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
    post-up ip route add 172.16.0.0/16 via %s
    pre-down ip route del 172.16.0.0/16 via %s; exit 0
""" % (vm.addr, vm.network, router, dijkstra_int, dijkstra_int)
    elif vm.iface == 'ext':
        print """
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address %s
    netmask %s
    gateway %s
""" % (vm.addr, vm.network, dijkstra_ext)
    else:
        raise Exception('unknown iface %s' % vm.iface)
