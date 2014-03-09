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
    check_interval                  1
}

define service {
    name                            ructf2014q-service ; The 'name' of this service template
    active_checks_enabled           1       ; Active service checks are enabled
    passive_checks_enabled          1       ; Passive service checks are enabled/accepted
    parallelize_check               1       ; Active service checks should be parallelized (disabling this can lead to major performance problems)
    obsess_over_service             1       ; We should obsess over this service (if necessary)
    check_freshness                 0       ; Default is to NOT check service 'freshness'
    notifications_enabled           1       ; Service notifications are enabled
    event_handler_enabled           1       ; Service event handler is enabled
    flap_detection_enabled          1       ; Flap detection is enabled
    failure_prediction_enabled      1       ; Failure prediction is enabled
    process_perf_data               1       ; Process performance data
    retain_status_information       1       ; Retain status information across program restarts
    retain_nonstatus_information    1       ; Retain non-status information across program restarts
    notification_interval           0       ; Only send notifications on status change by default.
    is_volatile                     0
    check_period                    24x7
    normal_check_interval           1
    retry_check_interval            1
    max_check_attempts              3
    notification_period             24x7
    notification_options            w,u,c,r
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
define command {
    command_name    no-backup-report
    command_line    $USER1$/check_dummy 2 "CRITICAL: Results of backup job were not reported!"
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
    contacts   ructf2014q_%s, ructf2014q_last_g, ructf2014q_andrey.malets, ructf2014q_dimmoborgir
}
""" % (vm.name, vm.name, vm.admin, vm.os, vm.addr, vm.admin.partition('@')[0])
        if vm.os in ['debian', 'debian32', 'arch']:
            print """
define service {
    use                 ructf2014q-service
    host_name           %s
    service_description SSH server
    check_command       check_ssh
    contacts   ructf2014q_%s, ructf2014q_last_g, ructf2014q_andrey.malets, ructf2014q_dimmoborgir
}
""" % (vm.name, vm.admin.partition('@')[0])
            print """
define service {
    use                     ructf2014q-service
    host_name               %s
    service_description     backup
    active_checks_enabled   0
    passive_checks_enabled  1
    check_freshness         1
    freshness_threshold     12000
    check_command           no-backup-report
    contacts   ructf2014q_%s, ructf2014q_last_g, ructf2014q_andrey.malets, ructf2014q_dimmoborgir
}
""" % (vm.name, vm.admin.partition('@')[0])

        if vm.http:
            print """
define service {
    use                 ructf2014q-service
    host_name           %s
    service_description Web server
    check_command       check_http
    contacts   ructf2014q_%s, ructf2014q_last_g, ructf2014q_andrey.malets, ructf2014q_dimmoborgir
}
""" % (vm.name, vm.admin.partition('@')[0])
