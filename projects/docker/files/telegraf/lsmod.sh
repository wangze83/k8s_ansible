# /bin/bash

lsmod | grep ttm_ipv4 | wc -l | xargs -I {} echo lsmod,module=ttm_ipv4,host=`hostname` loaded={}i `date +%s `000000000
