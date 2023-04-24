# Overview: Abell 250

Example management repo for Nebula hosts

* __Network Name__: Fake Abell 250
* __IP Allocation Convention__:
    ```
    Overall             10.250.0.0  / 16
    Applications        10.250.1.0  / 24
    Bespoke             10.250.2.0  / 24
    Networking          10.250.31.0 / 24
    ```

# Requirements

* PHP 7.4+
* Nebula: https://github.com/slackhq/nebula/releases (*tested with 1.6.1*)
* Pogo: https://github.com/totten/pogo/releases (*tested with 0.5.0*)

# Initialization

```
cd certs
nebula-cert ca -name 'Fake Abell 250' -duration 87360h
cd ..

./bin/abell add lighthouse my-lighthouse --ip='10.250.31.2/16'

./bin/abell add workstation my-desktop1  --ip='10.250.2.1/16'
./bin/abell add workstation my-laptop1   --ip='10.250.2.2/16'
./bin/abell add server my-vm1            --ip='10.250.2.3/16'
./bin/abell add server my-vm2            --ip='10.250.2.4/16'
./bin/abell add server my-server1        --ip='10.250.2.5/16'
```

These commands generate keys and installation-files in [`./hosts`](./hosts). Each host has:

* PKI Files (`host.key`, `host.pub`, `host.crt`)
* Installer files (extractable `abell-250-hostname.tar.gz` or executable `abell-250-hostname.bin`)

# Add a new host

1. Run `abell add` to generate an identity
    ```bash
    abell add <type> <owner-name> --ip=<ip>/<mask>
    abell add server foo --ip=10.250.99.99/16
    ```
2. Copy the generated `hosts/foo/abell-*.bin` to the new host. Run it.
3. (Recommended) Add `ab250.civi.io` to the DNS search-path for the host
    * MacOS: Use "System Preferences => Network"
    * Ubuntu: In ``, add or update `Domains=ab250.civi.io` (*space-delimited list*) and run `systemctl restart systemd-resolved`
    * Other Unix: Update `/etc/resolv.conf`
4. Add DNS for `*.ab250.civi.io`
