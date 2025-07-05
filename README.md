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
## Post-installation
The installer places a template configuration at `/etc/zt-router.conf` if one
is not already present. Edit this file to match your network setup before
starting the service:

```bash
sudo nano /etc/zt-router.conf
```
