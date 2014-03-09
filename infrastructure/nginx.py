def gen(vm, bandir):
    bans = []
    try:
        with open('%s/%s' % (bandir, vm.name), 'r') as banfile:
            bans = map(str.strip, [ban for ban in banfile])
    except:
        pass
    if vm.http:
        print """
server {
    server_name %s.quals.ructf.org;
    listen 80;

    access_log  /var/log/nginx/ructf2014q-%s.access.log;
    error_log   /var/log/nginx/ructf2014q-%s.error.log;

    proxy_set_header    X-Forwarded-For $remote_addr;
    proxy_set_header    Host            $host;

    location / {
        proxy_pass      http://%s;
        %s
    }
}
""" % (vm.name,
       vm.name,
       vm.name,
       vm.addr,
       '\n        '.join(map(lambda ban: 'deny            %s;' % ban, bans)))
