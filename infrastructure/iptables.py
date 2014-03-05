def gen(vms, table, addr):
    print "iptables -t nat -F %s" % table
    def do_gen(ports, proto):
        for vm in filter(lambda vm: getattr(vm, ports) != None, vms):
            for port in getattr(vm, ports):
                print ("iptables -t nat -A %s -d %s -p %s -m state"
                    " --state NEW --dport %s -j DNAT --to %s" % (
                        table, addr, proto, port, vm.addr))
    do_gen('tcp_ports', 'tcp')
    do_gen('udp_ports', 'udp')
