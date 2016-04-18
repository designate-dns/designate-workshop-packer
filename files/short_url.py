#!/usr/bin/env python

import os
import argparse
import random

from designateclient.v2.client import Client
from designateclient import shell

from keystoneclient import session as keystone_session
from keystoneclient.auth.identity import generic

from pprint import pprint

ALPHA = 'abcdefghijklmnopqrstuvwxyz'
NUMS = '0123456789'
CHARS = ALPHA + NUMS


def randstr(length=7, chars=CHARS):
    return ''.join(random.choice(chars) for i in range(length))


def get_auth():
    auth = generic.Password(
        auth_url=shell.env('OS_AUTH_URL'),
        username=shell.env('OS_USERNAME'),
        password=shell.env('OS_PASSWORD'),
        tenant_name=shell.env('OS_TENANT_NAME')
    )

    return auth


def get_client(auth):
    endpoint = 'http://127.0.0.1:9001/v2'

    session = keystone_session.Session(auth=auth)
    return Client(session=session, endpoint_override=endpoint)


def find_zone(client, name):
    zones = client.zones.list(criterion={'name': name})
    if zones:
        return zones[0]
    return None


def create_zone(client, name):
    zone = client.zones.create(name, email='admin@%s' % name.strip('.'))
    return zone


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--create', action='store_true',
                        help='Create the zone')
    parser.add_argument('zone')
    parser.add_argument('url')
    return parser.parse_args()


def main():
    args = get_args()
    auth = get_auth()
    client = get_client(auth)
    zone = find_zone(client, args.zone)

    if not zone:
        if args.create:
            zone = create_zone(client, args.zone)
        else:
            print('%s not found' % args.zone)
            return

    name = '%s.%s' % (randstr(), args.zone)
    pprint(client.recordsets.create(zone['id'], name, 'CNAME', [str(args.url)]))
    print('Created %s CNAME for %s' % (name, args. url))

if __name__ == '__main__':
    main()
