import jinja2

def gen_ext_dns(vms, tname, serial):
    router = filter(lambda vm: vm.name == 'router', vms)[0]
    with open(tname, 'r') as tfile:
        print jinja2.Template(tfile.read()).render(vms=vms,
                                                   serial=serial,
                                                   router=router)

def gen_int_dns(vms, tname, serial):
    with open(tname, 'r') as tfile:
        print jinja2.Template(tfile.read()).render(vms=vms,
                                                   serial=serial)
