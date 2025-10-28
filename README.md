# ElectrumX Server for FixedCoin

Automated installation of an ElectrumX server for FixedCoin on Ubuntu 22.04 / Debian 11-12.

Uses **KomodoPlatform/electrumx-1** for better altcoin compatibility.

**Version**: 1.0.8

---

## ⚠️ Prerequisites

### 1. FixedCoin Node Required
You must have a **synchronized FixedCoin node** with:
- `txindex=1` in `fixedcoin.conf`
- RPC enabled with username and password

### 2. Domain DNS (for Let's Encrypt SSL)
**IMPORTANT**: If you want to use Let's Encrypt, your domain must **already point to your server IP** before running the script:

```
DNS A Record: electrumx.yourdomain.com → 123.45.67.89 (your server IP)
```

Verify before installation:
```bash
ping electrumx.yourdomain.com
# Should display your server IP
```

### 3. Firewall Ports
Make sure these ports are open in your hosting provider's firewall:
- **50001** (TCP)
- **50002** (SSL)
- **50004** (WSS)

---

## 🚀 Installation

### Download the script

```bash
wget https://raw.githubusercontent.com/biigbang0001/Electrum-FixedCoin/main/install_electrumx_fixedcoin.sh
chmod +x install_electrumx_fixedcoin.sh
```

### Run the installation

```bash
sudo ./install_electrumx_fixedcoin.sh
```

---

## 📋 Installation Options

If an existing installation is detected, the script offers 4 options:

### Option 1: Remove and reinstall (Recommended)
```
[1] Remove existing installation and install fresh
```
- Completely removes the existing installation
- Installs a clean version
- **Use this option if something went wrong**
- ⚠️ Warning: Deletes database (reindexing required)

### Option 2: Keep installation
```
[2] Keep existing installation and exit
```
- Does nothing and exits
- Use if your current installation is working

### Option 3: Multiple instances (Advanced)
```
[3] Install additional instance (advanced)
```
- Not supported by this script
- Requires manual configuration

### Option 4: Update (Keep data)
```
[4] Upgrade to KomodoPlatform version (keep data)
```
- Updates source code only
- Preserves database and configuration
- Use to migrate from spesmilo to KomodoPlatform

---

## 🔐 SSL Configuration

The script asks if you want Let's Encrypt:

### Option 1: Let's Encrypt (Recommended for production)
```
[1] Yes - Let's Encrypt certificate (public server with domain)
```
- Official and free SSL certificate
- Automatic renewal every 90 days
- **Requires domain pointing to your server**

### Option 2: Self-signed certificate (Local testing)
```
[2] No - Self-signed certificate (local testing)
```
- Self-signed certificate
- For local testing only
- Wallets will show a warning

---

## 🔧 FixedCoin Configuration

The script will ask for:

1. **Path to fixedcoin-cli** (default: `/var/fixedcoin/bin/fixedcoin-cli`)
2. **Data directory** (default: `/var/fixedcoin/data`)
3. **RPC Username** (default: `rpcuser`)
4. **RPC Password** (default: `rpcpassword`)
5. **RPC Port** (default: `24761`)

Verify these parameters match your FixedCoin configuration.

---

## ✅ Post-Installation Verification

### Check the service

```bash
# Service status
systemctl status electrumx

# Real-time logs
journalctl -u electrumx -f

# Indexing progress
journalctl -u electrumx -f | grep height
```

### Test connectivity

```bash
# Local test
echo '{"id": 1, "method": "server.version"}' | nc -q 1 localhost 50001

# External test (from your PC)
nc -zv electrumx.yourdomain.com 50002
```

### Useful commands

```bash
# Start service
systemctl start electrumx

# Stop service
systemctl stop electrumx

# Restart service
systemctl restart electrumx

# View logs
journalctl -u electrumx -n 100
```

---

## 🔗 Connect from Wallet

Once indexing is complete, connect your Electrum wallet:

```bash
electrum --server electrumx.yourdomain.com:50002:s
```

Or in wallet settings:
- **Server**: `electrumx.yourdomain.com`
- **Port**: `50002`
- **Protocol**: `SSL`

---

## 🛠️ Troubleshooting

### Installation fails or freezes

**Solution**: Uninstall and reinstall

```bash
# Rerun the script
sudo ./install_electrumx_fixedcoin.sh

# Choose Option 1: Remove existing installation
# Type "yes" to confirm
```

### Server not accessible from outside

1. **Check UFW** (server firewall)
```bash
sudo ufw status
# Ports 50001, 50002, 50004 must be ALLOW
```

2. **Check hosting provider firewall**
   - OVH: Panel → Network → Firewall
   - Hetzner: Cloud Console → Firewalls
   - DigitalOcean: Networking → Firewalls

3. **Verify port is listening**
```bash
netstat -tlnp | grep 5000
# Should show: 0.0.0.0:50001, 0.0.0.0:50002, 0.0.0.0:50004
```

### Let's Encrypt fails

**Cause**: Domain is not pointing to server IP

**Solution**:
1. Check DNS: `ping electrumx.yourdomain.com`
2. Wait for DNS propagation (up to 24h)
3. Rerun script and choose Option 1 (reinstall)

### Indexing is slow

This is normal! Full indexing can take several hours depending on:
- Blockchain size
- Server performance
- Disk speed

Monitor progress:
```bash
journalctl -u electrumx -f | grep height
```

---

## 📁 Files and Directories

### Configuration
- `/var/electrum/electrumx.conf` - Main configuration
- `/var/electrum/banner.txt` - Server banner

### Data
- `/var/electrum/db` - Database (can be large)
- `/var/electrum/logs` - Logs
- `/var/electrum/ssl` - SSL certificates

### Source code
- `/home/electrumx/electrumx-source` - ElectrumX code (KomodoPlatform)
- `/home/electrumx/electrumx-venv` - Python virtual environment

### Service
- `/etc/systemd/system/electrumx.service` - Systemd service

---

## 🔄 Update

To update ElectrumX to the latest version:

```bash
# Rerun the script
sudo ./install_electrumx_fixedcoin.sh

# Choose Option 4: Upgrade to KomodoPlatform version
```

This updates the code without touching the database.

---

## 📊 Technical Specifications

- **ElectrumX**: Version 1.18.0 (KomodoPlatform fork)
- **Python**: 3.11+
- **Database**: LevelDB
- **SSL**: Let's Encrypt or self-signed
- **Ports**: 50001 (TCP), 50002 (SSL), 50004 (WSS)

### Recommended server configuration
- **CPU**: 2 cores minimum
- **RAM**: 4 GB minimum (8 GB recommended)
- **Disk**: 20 GB minimum (SSD recommended)
- **OS**: Ubuntu 22.04 or Debian 11/12

---

## 🆘 Support

### Detailed logs
```bash
# View last 200 lines
journalctl -u electrumx -n 200

# Search for errors
journalctl -u electrumx | grep -i error
```

### Complete reinstallation
If nothing works, reinstall everything:

```bash
# 1. Uninstall
sudo ./install_electrumx_fixedcoin.sh
# Choose Option 1 and confirm with "yes"

# 2. Manual cleanup (if needed)
sudo rm -rf /var/electrum
sudo rm -rf /home/electrumx
sudo userdel -r electrumx
sudo rm -f /etc/systemd/system/electrumx.service
sudo systemctl daemon-reload

# 3. Reinstall
sudo ./install_electrumx_fixedcoin.sh
```

---

## 📜 License

MIT License

---

## 👥 Contributing

Developed for the **FixedCoin** community.

**Installation script**: v1.0.8  
**Last update**: October 28, 2025

---

## 🔗 Useful Links

- **FixedCoin**: [Official website](https://fixedcoin.org)
- **ElectrumX**: [KomodoPlatform/electrumx-1](https://github.com/KomodoPlatform/electrumx-1)
- **Electrum Wallet**: [electrum.org](https://electrum.org)

---

**Successful installation? Don't forget to ⭐ the repo!**
