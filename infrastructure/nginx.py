def gen(vms):
    for vm in filter(lambda vm: vm.http, vms):
        print """server {
    server_name %s.quals.ructf.org;
    listen 80;

    access_log  /var/log/nginx/ructf2014q-%s.access.log;
    error_log   /var/log/nginx/ructf2014q-%s.error.log;

    proxy_set_header    X-Forwarded-For $remote_addr;
    proxy_set_header    Host            $host;

    location / {
        proxy_pass      http://%s;
    }
}
""" % (vm.name, vm.name, vm.name, vm.addr)
