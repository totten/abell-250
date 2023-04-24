#!/usr/bin/env bash

./bin/abell add lighthouse my-lighthouse --ip='10.250.31.2/16' -f

./bin/abell add workstation my-desktop1  --ip='10.250.2.1/16' -f
./bin/abell add workstation my-laptop1   --ip='10.250.2.2/16' -f
./bin/abell add server my-vm1            --ip='10.250.2.3/16' -f
./bin/abell add server my-vm2            --ip='10.250.2.4/16' -f
./bin/abell add server my-server1        --ip='10.250.2.5/16' -f
