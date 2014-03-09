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
        self.http, self.tcp_ports, self.udp_ports = [False, [], []]

        for token in net_spec.split('+'):
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
