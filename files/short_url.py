import argparse
from randstr import randstr

from designateclient.v2.client import Client
from designateclient import shell

from keystoneclient import session as keystone_session

from pprint import pprint


def get_auth():
    user = 'admin'
    project = 'admin'
    password = 'password'

    return v2.Password(auth_url='http://127.0.0.1:5000/v2.0',
                       username=user,
                       password=password,
                       tenant_id='96c0fbc191524f508bbbf460f67e4a5f')


def get_client(auth):
    endpoint = 'http://127.0.0.1:9001/v2'
    session = keystone_session.Session(auth=auth)
    return Client(session=session, endpoint_override=endpoint)


def find_zone(client, name):
    zones = client.zones.list(criterion={'name': name})
    if zones:
        return zones[0]
    return None


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('zone')
    parser.add_argument('url')
    return parser.parse_args()


def main():
    args = get_args()
    auth = get_auth()
    client = get_client(auth)
    zone = find_zone(client, args.zone)

    if not zone:
        print('%s not found' % args.zone)
        return

    name = '%s.%s' % (randstr(), args.zone)
    pprint(client.recordsets.create(zone['id'], name, 'CNAME', [str(args.url)]))
    print('Created %s CNAME for %s' % (name, args. url))


if __name__ == '__main__':
    main()
