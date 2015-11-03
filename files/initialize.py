#!/usr/bin/env python

import os
import argparse

from designateclient.v2.client import Client

from keystoneclient import session as keystone_session

from pprint import pprint


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

    pool_id = '794ccc2c-d751-44fe-b57f-8894c9f5c842'

    endpoint = ENDPOINT + '/v2/pools/' + pool_id

    data = {
        'ns_records': [
            {
                'hostname': 'ns1.example.org.',
                'priority': 1
            },
            {
                'hostname': 'ns3.example.org.',
                'priority': 2
            }
        ],
    }

    resp = client.session.patch(endpoint, json=data)
    if not resp.ok:
        pprint(dict(resp.headers))
        resp.raise_for_status()


if __name__ == '__main__':
    main()
