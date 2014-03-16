#!/usr/bin/env python

import custom, dns, dolbilka, iptables, nagios, nginx, net, vm
import os, re, socket, sys

CFG=os.path.dirname(os.path.realpath(__file__)) + '/vms.cfg'

cmds = {}

def find(vms, name):
    match = filter(lambda vm: vm.name == name, vms)
    if len(match) != 1:
        raise Exception(match)
    return match[0]

def cmd(fn):
    cmds[fn.__name__] = lambda cfg, args: fn(cfg, args)

@cmd
def list(vms, args):
    [host_patt, vm_patt] = args[0].split(':')
    match = lambda vm: True
    if len(args) > 1 and len(args[1]) != 0:
        filters = { 'debian' : lambda vm: vm.os in ['debian', 'debian32'],
                    'arch'   : lambda vm: vm.os == 'arch',
                    'linux'  : lambda vm: vm.os in ['debian', 'debian32', 'arch']}
        patt = args[1]
        if patt in filters:
            match = filters[patt]
        else:
            raise Exception('unknown filter pattern %s' % patt)
    attr = None if len(args) < 3 or len(args[2]) == 0 else args[2]
    print str.join('\n', map(lambda vm: ('%s:%s' % (vm.host, vm.name))
                                         if attr == None
                                         else ('%s:%s:%s' % (vm.host, vm.name, getattr(vm, attr))),
        filter(lambda vm: (re.match(host_patt, vm.host) != None and
            re.match(vm_patt, vm.name) != None and match(vm)), vms)))

@cmd
def get_attr(vms, args):
    print getattr(find(vms, args[0]), args[1])

@cmd
def addr(vms, args):
    vm = find(vms, args[0])
    print vm.addr

@cmd
def vnc(vms, args):
    vm = find(vms, args[0])
    print '%s.urgu.org:%d' % (vm.host, 6000 + vm.ID)

@cmd
def gen_nagios(vms, _):
    return nagios.gen_nagios(vms)

@cmd
def gen_xen(vms, args):
    host_ip = socket.gethostbyname_ex(args[0])[2][0]
    match = filter(lambda vm: vm.host == args[0] and vm.name == args[1], vms)
    if len(match) != 1:
        raise Exception(match)
    vm = match[0]
    if args[2] == 'setup' and vm.os == '2k8r2':
        bootdev = 'd'
    else:
        bootdev = 'c'

    bridge = {'int': 'br5', 'ext': 'br2'}[vm.iface]

    if vm.os == 'debian' or vm.os == 'debian32':
        disk_str = '"phy://dev/data/ructf2014q-%s,ioemu:hda,w"' % vm.name
    elif vm.os == '2k8r2':
        disk_str = ('"phy://dev/data/ructf2014q-%s,ioemu:hda,w",' % vm.name +
            '"file://root/2k8r2.iso,hdc:cdrom,r"')
    elif vm.os == 'arch':
        disk_str = ('"phy://dev/data/ructf2014q-%s,ioemu:hda,w",' % vm.name)
            #'"file://root/arch.iso,hdc:cdrom,r"')
    print """
kernel="/usr/lib/xen-4.1/boot/hvmloader"
builder="hvm"
memory="%s"
device_model="/usr/lib/xen-4.1/bin/qemu-dm"
boot="%s"
vif=["bridge=%s,mac=00:0c:29:ab:cd:%02d"]

disk=[%s]
vcpus="%s"

vncconsole=0
vnc=1
vnclisten="%s:%d"
"""     % (vm.mem,
           bootdev,
           bridge, int(vm.ID),
           disk_str,
           vm.cpus,
           host_ip, 100 + int(vm.ID))

@cmd
def check_res(vms, _):
    capacity = {'h': {'cpus':  2, 'disk': 80,  'mem':  5000},
                'm': {'cpus':  8, 'disk': 440, 'mem': 10000},
                't': {'cpus': 12, 'disk': 600, 'mem': 50000}}
    hosts = set(map(lambda vm: vm.host, vms))
    resources = {}
    for host in hosts:
        resources[host] = {}
        resources[host]['cpus'] = 0
        resources[host]['mem']  = 0
        resources[host]['disk'] = 0
    for vm in vms:
        resources[vm.host]['cpus'] += int(vm.cpus)
        resources[vm.host]['mem']  += int(vm.mem)
        resources[vm.host]['disk'] += int(vm.disk)

    for host in hosts:
        for res in capacity[host]:
            if resources[host][res] > capacity[host][res]:
                print '%s on %s exceeded: %d over %d' % (
                    res, host,
                    resources[host][res],
                    capacity[host][res])

@cmd
def gen_nat(vms, args):
    return iptables.gen_nat(vms, *args)

@cmd
def gen_fwd(vms, args):
    return iptables.gen_fwd(vms, *args)

@cmd
def gen_user_chains(vms, args):
    return iptables.gen_user_chains(vms, *args)

@cmd
def gen_int_access(vms, args):
    return iptables.gen_int_access(vms, *args)

@cmd
def gen_xen_vnc(vms, args):
    return iptables.gen_xen_vnc(vms, *args)

@cmd
def gen_nginx(vms, vm):
    return nginx.gen(find(vms, args[0]), args[1])

@cmd
def customize(vms, args):
    return custom.customize(
        vms,
        find(vms, args[0]),
        os.path.dirname(os.path.realpath(__file__)) + '/keys')

@cmd
def gen_interfaces(vms, args):
    return net.gen_interfaces(find(vms, args[0]))

@cmd
def get_ports(vms, args):
    return iptables.get_ports(find(vms, args[0]))

@cmd
def gen_dolbilka(vms, args):
    return dolbilka.gen_config(vms, *args)

@cmd
def gen_ext_dns(vms, args):
    return dns.gen_ext_dns(vms, *args)

@cmd
def gen_int_dns(vms, args):
    return dns.gen_int_dns(vms, *args)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print >> sys.stderr, cmds.keys()
        sys.exit(1)

    with open(CFG, 'r') as cfg:
        vms = map(vm.VM, filter(lambda line:
            len(line.strip()) != 0 and not line.startswith('#'), cfg))

    [cmd, args] = [sys.argv[1], sys.argv[2:]]
    if cmd in cmds:
        cmds[cmd](vms, args)
    else:
        print >> sys.stderr, cmds.keys()
        sys.exit(1)
