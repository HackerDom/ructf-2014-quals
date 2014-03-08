import socket

def init(table, chain):
    print ('if iptables -t %s -L %s 2>/dev/null >/dev/null; '
        'then iptables -t %s -F %s; '
        'else iptables -t %s -N %s; fi' % (table, chain,
                                           table, chain,
                                           table, chain))

def delete(table, chain):
    print ('if iptables -t %s -L %s 2>/dev/null >/dev/null; '
        'then iptables -t %s -F %s; iptables -t %s -X %s; fi' % (table, chain,
                                                                 table, chain,
                                                                 table, chain))


def gen_nat(vms, addr, chain):
    init('nat', chain)
    def do_gen(ports, proto):
        for vm in filter(lambda vm: getattr(vm, ports) != None, vms):
            for port in getattr(vm, ports):
                print ("iptables -t nat -A %s -d %s -p %s -m state"
                    " --state NEW --dport %s -j DNAT --to %s" % (
                        chain, addr, proto, port, vm.addr))
    do_gen('tcp_ports', 'tcp')
    do_gen('udp_ports', 'udp')

def gen_fwd(vms, addr, chain, prefix):
    init('filter', chain)
    def do_gen(ports, proto):
        for vm in filter(lambda vm: getattr(vm, ports) != None, vms):
            if len(getattr(vm, ports)) != 0:
                vm_chain = prefix + vm.name
                init('filter', vm_chain)
                for port in getattr(vm, ports):
                    print ("iptables -A %s -d %s -p %s -m state"
                        " --state NEW --dport %s -j %s" % (
                            chain, addr, proto, port, vm_chain))
    do_gen('tcp_ports', 'tcp')
    do_gen('udp_ports', 'udp')

def cn2chain(cn):
    return 'user_%s' % cn

def ipp2src(ipp_ip):
    octets = ipp_ip.split('.')
    octets[3] = str(int(octets[3]) + 2)
    return '.'.join(octets)

def gen_user_chains(vms, ipp_name, iface, target):
    users = {}
    with open(ipp_name, 'r') as ipp:
        for line in ipp:
            user, ip = line.strip().split(',')
            if not user in users:
                users[user] = []
            users[user].append(ipp2src(ip))
    for vm in vms:
        if not vm.admin_cn in users:
            users[vm.admin_cn] = []
    for user in users:
        chain = cn2chain(user)
        init('filter', chain)
        for ip in users[user]:
            print ('iptables -A %s -i %s -s %s -p tcp -m state --state NEW '
                '-j %s' % (chain, iface, ip, target))
            print ('iptables -A %s -i %s -s %s -p udp -m state --state NEW '
                '-j %s' % (chain, iface, ip, target))

def gen_int_access(vms, chain):
    init('filter', chain)
    CNs = set(map(lambda vm: vm.admin_cn,
                  filter(lambda vm: vm.admin_cn != '-', vms)))
    for cn in CNs:
        print 'iptables -A %s -j %s' % (chain, cn2chain(cn))

def gen_xen_vnc(vms, chain):
    init('filter', chain)
    for vm in vms:
        if vm.admin_cn != '-':
            dest = socket.gethostbyname_ex('%s.urgu.org' % vm.host)[2][0]
            print ('iptables -A %s -d %s -p tcp --dport %d -m state --state NEW '
                '-j %s' % (chain, dest, 6000 + vm.ID, cn2chain(vm.admin_cn)))

def get_ports(vm):
    if vm.http: print 'tcp:80'
    for port in vm.tcp_ports: print 'tcp:%s' % port
    for port in vm.udp_ports: print 'udp:%s' % port
