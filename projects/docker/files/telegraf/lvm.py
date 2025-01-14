#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import absolute_import, division, print_function, with_statement

import socket
import traceback
import subprocess


MEASUREMENT = 'lvm_thin'


if __name__ == '__main__':
    hostname = socket.getfqdn()

    out = subprocess.check_output(['lvs', '--noheadings', '--separator', '\t', '-o', '+segtype'])
    # LV VG Attr LSize Pool Origin Data% Meta% Move Log Cpy%Sync Convert Type
    for line in out.splitlines():
        data = line.strip().split('\t')
        try:
            if not len(data) == 13:
                raise ValueError
            if not data[12].startswith('thin'):
                continue
            lv = data[0]
            vg = data[1]
            size = data[3][:-1]     # 100.00g
            data_percent = data[6] or '0'
            metadata_percent = data[7] or '0'
            segtype = data[12]
            print('{0},host={1},lv={2},vg={3},segtype={4} size={5},data={6},metadata={7}'.format(
                    MEASUREMENT, hostname,
                    lv, vg, segtype,
                    size, data_percent, metadata_percent))
        except Exception:
            pass

