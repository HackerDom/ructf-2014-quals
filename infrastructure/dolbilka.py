def gen_config(vms, nodes, clients):
    services = []
    for vm in vms:
        if vm.http:
            services.append('http:%s' % vm.name)
        if vm.tcp_ports != None:
            for port in vm.tcp_ports:
                services.append('tcp:%s:%s' % (vm.name, port))
        if vm.udp_ports != None:
            for port in vm.udp_ports:
                services.append('udp:%s:%s' % (vm.name, port))

    services = services * int(clients)
    for i in range(0, len(services)):
       node = 1 + i % int(nodes)
       print '%d:%s' % (node, services[i])
