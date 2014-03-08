#!/bin/bash

curl -XDELETE http://localhost:9200/es/
curl -XPOST   http://localhost:9200/es/user/admin -d '{"pass":"50450af7579d8f54411c6029d7362008"}'
curl -XPOST   http://localhost:9200/es/url/ -d '{"name":"admin","url":"/super/secret/flag"}'