#!/usr/bin/env python

import os
import argparse

from designateclient.v2.client import Client

from keystoneclient import session as keystone_session

from pprint import pprint

ALPHA = 'abcdefghijklmnopqrstuvwxyz'
NUMS = '0123456789'
CHARS = ALPHA + NUMS


def randstr(length=7, chars=CHARS):
    return ''.join(random.choice(chars) for i in range(length))


def get_auth():
    user = os.environ['OS_USERNAME']
    password = os.environ['OS_PASSWORD']
    tenant_id = os.environ['OS_TENANT_ID']

    return v2.Password(auth_url='http://127.0.0.1:5000/v2.0',
                       username=user,
                       password=password,
                       tenant_id=tenant_id)


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
    zone = c.zones.create(name, email='admin@%s' % name)
    return zone


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--create', action='store_true',
                        help='Create the zone'))
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
