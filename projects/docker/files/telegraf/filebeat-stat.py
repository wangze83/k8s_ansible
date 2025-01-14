#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import absolute_import, division, print_function, with_statement


import json
import os
import socket
import traceback


MEASUREMENT = 'filebeat_registry'


if __name__ == '__main__':
    hostname = socket.getfqdn()
    registry_set = [
            ('/data/usr/filebeat/kube-filebeat.registry', 'kafka'),
            ('/data/usr/filebeat-stage/kube-filebeat.registry', 'logstash'),
        ]

    for registry_file, output_label in registry_set:
        with open(registry_file) as f:
            data = json.load(f)
            for d in data:
                try:
                    if 'POD' in d['source']:
                        continue
                    if not os.path.exists(d['source']):
                        continue
                    if d['ttl'] == -2:
                        # Excluded in filebeat config
                        continue
                    s = os.stat(d['source'])
                    if d['FileStateOS']['inode'] == s.st_ino:
                        container_name = os.path.basename(d['source'])[:-69]      # `-` + 64 bytes hash key + `.log`
                        inode = s.st_ino
                        size = s.st_size
                        lag = s.st_size - d['offset']
                        print('{0},host={1},container={2},inode={3},output={4} size={5:d}i,lag={6:d}i'.format(
                                MEASUREMENT, hostname, container_name, inode, output_label, size, lag))
                except:
                    #  traceback.print_exc()
                    pass

