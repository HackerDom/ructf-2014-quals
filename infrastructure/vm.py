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
         in_net_spec,
         out_net_spec,
         self.os] = map(str.strip, cfg_line.split(','))
        self.ID = int(ID)
        self.http, self.tcp_ports, self.udp_ports = [False, [], []]
        self.out_ports = []

        for token in in_net_spec.split('+'):
            if token.startswith('ext'):
                self.iface, self.addr = token.split(':', 2)
                self.network = '255.255.255.240'
            elif (token in ['int', 'http'] or
                    token.startswith('tcp') or
                    token.startswith('udp')):
                self.iface, self.addr = ['int', '172.16.16.%d' % self.ID]
                self.network = '255.255.255.0'
                if token == 'http': self.http = True
                if token.startswith('tcp') or token.startswith('udp'):
                    proto, portspec = token.split(':', 2)
                    ports = portspec.split('|')
                    setattr(self, '%s_ports' % proto, ports)
            else:
                raise Exception('unknown netspec token: %s' % token)

        if len(out_net_spec) > 0:
            for token in out_net_spec.split('+'):
                proto, port = token.split(':', 2)
                if proto in ['tcp', 'udp']:
                    self.out_ports.append((proto, port))
                else:
                    raise Exception('unknown netspec token: %s' % token)
