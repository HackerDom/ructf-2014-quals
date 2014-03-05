#!/usr/bin/env python

import nginx, vm
import re, socket, sys

CFG='vms.cfg'

cmds = {}

def cmd(fn):
    cmds[fn.__name__] = lambda cfg, args: fn(cfg, args)

@cmd
def list(vms, args):
    [host_patt, vm_patt] = args[0].split(':')
    print str.join('\n', map(lambda vm: '%s:%s' % (vm.host, vm.name), filter(
        lambda vm: (re.match(host_patt, vm.host) != None and
                    re.match(vm_patt, vm.name) != None), vms)))

@cmd
def get_attr(vms, args):
    match = filter(lambda vm: vm.name == args[0], vms)
    if len(match) != 1:
        raise Exception(match)
    print getattr(match[0], args[1])

@cmd
def gen_xen(vms, args):
    host_ip = socket.gethostbyname_ex(args[0])[2][0]
    match = filter(lambda vm: vm.host == args[0] and vm.name == args[1], vms)
    if len(match) != 1:
        raise Exception(match)
    vm = match[0]
    if args[2] == 'setup' and not vm.os.startswith('debian'):
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
        disk_str = ('"phy://dev/data/ructf2014q-%s,ioemu:hda,w",' % vm.name +
            '"file://root/arch.iso,hdc:cdrom,r"')
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
def gen_nginx(vms, _):
    return nginx.gen(vms)

if __name__ == '__main__':
    with open(CFG, 'r') as cfg:
        vms = map(vm.VM, filter(lambda line:
            len(line.strip()) != 0 and not line.startswith('#'), cfg))

    [cmd, args] = [sys.argv[1], sys.argv[2:]]
    if cmd in cmds:
        cmds[cmd](vms, args)
    else:
        print >> sys.stderr, cmds.keys()
