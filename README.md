# zt-router

ZeroTier router service for Raspberry Pi and Debian-based systems.

## Features

- NAT and routing between LAN subnets and ZeroTier
- Configurable via `/etc/zt-router.conf`
- Auto-detection of ZeroTier interface
- Persistent iptables rules
- Installable via `.deb` package

## Install

```bash
sudo apt install ./zt-router_1.0_all.deb
```
## Important
Make sure it works by 

```bash
sudo chmod +x /usr/local/bin/zt-router.sh
```
and remember to edit config include if name in your config file 

```
vim /etc/zt-router.conf
```
