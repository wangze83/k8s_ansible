#!/usr/bin/env python3

import argparse
import collections
import datetime
import json
import string
import sys
from hashlib import md5
from urllib.parse import urlencode
from urllib.request import urlopen


def expand_hostname_range(line=None):
    all_hosts = []
    if line:
        (head, nrange, tail) = line.replace('[', '|', 1).replace(']', '|', 1).split('|')
        bounds = nrange.split(":")
        if len(bounds) != 2 and len(bounds) != 3:
            raise AnsibleError("host range must be begin:end or begin:end:step")
        beg = bounds[0]
        end = bounds[1]
        if len(bounds) == 2:
            step = 1
        else:
            step = bounds[2]
        if not beg:
            beg = "0"
        if not end:
            raise AnsibleError("host range must specify end value")
        if beg[0] == '0' and len(beg) > 1:
            rlen = len(beg)  # range length formatting hint
            if rlen != len(end):
                raise AnsibleError("host range must specify equal-length begin and end formats")

            def fill(x):
                return str(x).zfill(rlen)  # range sequence

        else:
            fill = str

        try:
            i_beg = string.ascii_letters.index(beg)
            i_end = string.ascii_letters.index(end)
            if i_beg > i_end:
                raise AnsibleError("host range must have begin <= end")
            seq = list(string.ascii_letters[i_beg:i_end + 1:int(step)])
        except ValueError:  # not an alpha range
            seq = range(int(beg), int(end) + 1, int(step))

        for rseq in seq:
            hname = ''.join((head, fill(rseq), tail))

            if '[' in hname:
                all_hosts.extend(expand_hostname_range(hname))
            else:
                all_hosts.append(hname)

        return all_hosts


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('hostname', metavar='HOST', type=str, nargs=1)
    args = parser.parse_args()

    if '[' in args.hostname[0]:
        hostname = ','.join(expand_hostname_range(args.hostname[0]))
    else:
        hostname = args.hostname[0]

    mid = 4110
    secret_key = 'e39b79eaaf14a22a483e94aa32a4a423'

    params = collections.OrderedDict()
    params['hostname'] = hostname
    params['t'] = int(datetime.datetime.now().timestamp())

    qs = urlencode(params)
    sign = md5((md5(qs.encode()).hexdigest() + secret_key).encode()).hexdigest()
    url = 'http://wz.net:8wz'.format(mid, sign, qs)

    res = urlopen(url, timeout=3)
    d = json.loads(res.read())
    #  print(json.dumps(d, indent=2))
    if d['errno'] != 0:
        print(d)
        sys.exit(1)
    try:
        for data in d['data']:
            print('{0}: {1}'.format(data['hostname'], data['rackname']))
            #  print('{0}: {1}'.format(data['hostname'], data['warranty_date']))
            #  print('{0} {1}'.format(data['hostname'], data['innerIp']))
            #  print(json.dumps(data, indent=2))
    except Exception:
        print(json.dumps(d, indent=2))
        sys.exit(2)
