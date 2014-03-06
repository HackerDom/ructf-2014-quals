def gen_nagios(vms):
    print """
define host {
    name                            ructf2014q-vm ; The name of this host template
    notifications_enabled           1             ; Host notifications are enabled
    event_handler_enabled           1             ; Host event handler is enabled
    flap_detection_enabled          1             ; Flap detection is enabled
    failure_prediction_enabled      1             ; Failure prediction is enabled
    process_perf_data               1             ; Process performance data
    retain_status_information       1             ; Retain status information across program restarts
    retain_nonstatus_information    1             ; Retain non-status information across program restarts
    check_command                   check-host-alive
    max_check_attempts              10
    notification_interval           0
    notification_period             24x7
    notification_options            d,u,r
    register                        0
}

define contact {
    name                            ructf2014q-admin
    service_notification_period     24x7
    host_notification_period        24x7
    service_notification_options    w,u,c,r
    host_notification_options       d,r
    service_notification_commands   notify-service-by-email
    host_notification_commands      notify-host-by-email
    register                        0
}

define hostgroup {
    hostgroup_name ructf2014q-vms
    alias          RuCTF2014 Quals VMs
}
"""

    for admin in set(map(lambda vm: vm.admin, vms) + ['andrey.malets@gmail.com']):
        print """
define contact {
    use             ructf2014q-admin
    contact_name    ructf2014q_%s
    email           %s
}
""" % (admin.partition('@')[0], admin)

    for vm in vms:
        print """
define host {
    use        ructf2014q-vm
    host_name  %s
    alias      %s (%s, %s)
    hostgroups ructf2014q-vms
    address    %s
    contacts   ructf2014q_%s, ructf2014q_last_g, ructf2014q_andrey.malets
}
""" % (vm.name, vm.name, vm.admin, vm.os, vm.addr, vm.admin.partition('@')[0])
        if vm.os in ['debian', 'debian32', 'arch']:
            print """
define service {
    use                 generic-service
    host_name           %s
    service_description SSH server
    check_command       check_ssh
    contacts            ructf2014q_%s, ructf2014q_last_g, ructf2014q_andrey.malets
}
""" % (vm.name, vm.admin.partition('@')[0])
