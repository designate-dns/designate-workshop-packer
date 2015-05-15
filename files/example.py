#!/usr/bin/env python

import requests
from designateclient.client import Client
from designateclient import exceptions
from keystoneclient import session
from keystoneclient.auth.identity import v2

url = 'http://myexternalip.com'
try:
    r = requests.head(url)
    ip = r.headers['my-external-ip']
except Exception:
    ip = '127.0.0.1'

user = 'admin'
project = 'admin'
password = 'password'


auth = v2.Password(auth_url='http://127.0.0.1:5000/v2.0',
                   username=user,
                   password=password,
                   tenant_id='96c0fbc191524f508bbbf460f67e4a5f')

sess = session.Session(auth=auth)

client = Client('2', session=sess, http_log_debug=True, region_name='regionOne')

try:
    client.recordsets.create('example.com.', 'me.example.com.', 'A', [ip], 'Auto-Generated Record')
except exceptions.Conflict:
    values = {
        'type': 'A',
        'records': [ip],
        'description': 'Auto-Generated Record'
    }
    client.recordsets.update('example.com.', 'me.example.com.', values)
