#!/usr/bin/env python
import requests

from designateclient import shell
from designateclient.v2.client import Client
from designateclient import exceptions
from keystoneclient import session as keystone_session
from keystoneclient.auth.identity import generic


url = 'http://myexternalip.com'
try:
    r = requests.head(url)
    ip = r.headers['my-external-ip']
except Exception:
    ip = '127.0.0.1'

auth = generic.Password(
        auth_url=shell.env('OS_AUTH_URL'),
        username=shell.env('OS_USERNAME'),
        password=shell.env('OS_PASSWORD'),
        tenant_name=shell.env('OS_TENANT_NAME')
    )

endpoint = 'http://127.0.0.1:9001/v2'
session = keystone_session.Session(auth=auth)
client = Client(session=session, endpoint_override=endpoint)

try:
    client.recordsets.create('example.com.', 'me.example.com.', 'A', [ip], 'Auto-Generated Record')
except exceptions.Conflict:
    values = {
        'type': 'A',
        'records': [ip],
        'description': 'Auto-Generated Record'
    }
    client.recordsets.update('example.com.', 'me.example.com.', values)
