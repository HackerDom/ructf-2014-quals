class VM:
    def __init__(self, cfg_line):
        [ID,
         self.host,
         self.name,
         self.admin,
         self.admin_cn,
         self.cpus,
         self.mem,
         self.disk,
         net_spec,
         self.os] = map(str.strip, cfg_line.split(','))
        self.ID = int(ID)

        self.http = False
        self.tcp_ports = None
        self.udp_ports = None

        if net_spec.startswith('ext'):
            [self.iface, self.addr] = net_spec.split(':', 2)
        elif net_spec.startswith('int'):
            [self.iface, self.addr] = [net_spec, '172.16.16.%d' % self.ID]
        elif net_spec == 'http':
            [self.iface, self.addr] = ['int', '172.16.16.%d' % self.ID]
            self.http = True
        elif net_spec.startswith('tcp') or net_spec.startswith('udp'):
            [self.iface, self.addr] = ['int', '172.16.16.%d' % self.ID]
            ports = net_spec.split(':')[1].split('|')
            if net_spec.startswith('tcp'):
                self.tcp_ports = ports
            else:
                self.udp_ports = ports
