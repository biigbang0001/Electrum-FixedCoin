# ElectrumX for FixedCoin

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-orange.svg)](https://ubuntu.com)
[![Debian](https://img.shields.io/badge/Debian-11%2F12-red.svg)](https://www.debian.org/)
[![Tested](https://img.shields.io/badge/Status-Production%20Tested-green.svg)](https://electrumx.fixedcoin.org)

**Automated installation of an ElectrumX server for FixedCoin on Ubuntu 22.04 / Debian 11-12**

ElectrumX is a server for Electrum wallets that allows querying the blockchain without downloading the entire chain. This package automatically installs and configures ElectrumX for FixedCoin with its specific parameters.

---

## ✨ Features

- ✅ **Fully automated installation** - One command setup
- ✅ **Python virtual environment** - Clean, isolated installation
- ✅ **FixedCoin-specific configuration** - Correct address prefixes (P2PKH=0x01, P2SH=0x00)
- ✅ **Systemd service** - Auto-restart and monitoring
- ✅ **SSL support** - Self-signed or Let's Encrypt certificates
- ✅ **Firewall configuration** - UFW auto-configuration
- ✅ **Log rotation** - Automatic log management
- ✅ **Peer discovery** - Connects to FixedCoin network

---

## 📋 Prerequisites

- ✅ **Ubuntu 22.04 LTS** or **Debian 11/12**
- ✅ **FixedCoin installed and synced** (with `txindex=1`)
- ✅ **At least 4 GB RAM**
- ✅ **At least 50 GB free disk space**
- ✅ **sudo/root access**

---

## ⚙️ FixedCoin Configuration (REQUIRED)

**Before installing ElectrumX**, configure your FixedCoin node:

```bash
# 1. Edit FixedCoin configuration
sudo nano /var/fixedcoin/data/fixedcoin.conf
```

**Add these lines (CRITICAL):**

```ini
server=1
txindex=1
rpcuser=your_rpc_username
rpcpassword=your_secure_rpc_password
rpcport=24761
rpcallowip=127.0.0.1
```

```bash
# 2. Restart FixedCoin with reindexing (IF txindex was missing)
sudo systemctl stop fixedcoin
sudo /var/fixedcoin/bin/fixedcoind -datadir=/var/fixedcoin/data -reindex -daemon

# 3. Verify txindex is active (wait for reindex to complete)
/var/fixedcoin/bin/fixedcoin-cli -datadir=/var/fixedcoin/data getindexinfo
```

You should see:
```json
{
  "txindex": {
    "synced": true,
    "best_block_height": 524
  }
}
```

---

## 🚀 Installation

### Quick Install (3 Steps)

```bash
# 1. Download
git clone https://github.com/yourusername/electrumx-fixedcoin.git
cd electrumx-fixedcoin

# 2. Make executable
chmod +x *.sh

# 3. Install
sudo ./install_electrumx_fixedcoin.sh
```

The installation takes approximately **5-10 minutes** and automatically configures:
- ✅ ElectrumX installation from GitHub
- ✅ **FixedCoin class with correct parameters** (P2PKH=0x01, P2SH=0x00)
- ✅ Systemd service with auto-restart
- ✅ SSL certificate (self-signed or Let's Encrypt)
- ✅ Firewall (UFW)
- ✅ Log rotation
- ✅ Hourly monitoring

---

## ✅ Verification

```bash
# Check service status
sudo systemctl status electrumx

# View logs
sudo journalctl -u electrumx -f

# Test JSON-RPC
echo '{"id": 1, "method": "server.version", "params": ["test", "1.4"]}' | nc -q 1 localhost 50001
```

**Success indicators:**

```
INFO:Controller:using FixedCoin mainnet
INFO:BlockProcessor:caught up to height 524
INFO:SessionManager:SSL server listening on all_interfaces:50002
```

---

## 🎯 FixedCoin-Specific Parameters

The script automatically configures the **correct** FixedCoin parameters:

```python
# Source: chainparams.cpp - base58Prefixes
P2PKH_VERBYTE = 0x01  # Decimal 1 → Addresses "Q..."
P2SH_VERBYTES = 0x00  # Decimal 0 → Addresses "1..."
WIF_BYTE = 0x80       # Standard Bitcoin
XPUB = 0x0488B21E     # Standard Bitcoin
XPRV = 0x0488ADE4     # Standard Bitcoin
GENESIS_HASH = '000008e19a0f9124269e897bdcff8ef981fa2d563431df80ca27bc4a1373efd6'
```

**⚠️ FixedCoin uses INVERTED prefixes compared to standard Bitcoin!**

---

## 📊 Server Information

### Ports

| Service | Port | Description |
|---------|------|-------------|
| TCP | 50001 | Unencrypted connections |
| **SSL** | **50002** | **Encrypted connections (recommended)** |
| WSS | 50004 | Secure WebSocket |
| RPC | 8000 | Internal RPC (localhost only) |

### Important Files

```
/var/electrum/
├── db/                    # Indexed database
├── logs/                  # Server logs
├── ssl/                   # SSL certificates
│   ├── server.crt
│   └── server.key
├── electrumx.conf        # Main configuration
└── banner.txt            # Server banner

/home/electrumx/
├── electrumx-source/     # Source code
└── electrumx-venv/       # Python virtual environment
    └── bin/
        └── electrumx_server
```

---

## 🔧 Usage

### Essential Commands

```bash
# Start
sudo systemctl start electrumx

# Stop
sudo systemctl stop electrumx

# Restart
sudo systemctl restart electrumx

# Real-time logs
sudo journalctl -u electrumx -f

# Follow indexing
sudo journalctl -u electrumx | grep height
```

---

## 🔐 SSL Let's Encrypt (Public Server)

To replace the self-signed certificate with a valid Let's Encrypt certificate:

During installation, choose option [1] for Let's Encrypt and provide:
- Your domain name (e.g., electrumx.yourdomain.com)
- Your email address

The script will:
- ✅ Configure nginx
- ✅ Obtain Let's Encrypt certificate
- ✅ Copy to ElectrumX
- ✅ Configure automatic renewal
- ✅ Restart ElectrumX

---

## 🧪 Testing

### JSON-RPC Tests

```bash
# Test server.version
echo '{"id": 1, "method": "server.version", "params": ["test", "1.4"]}' | nc -q 1 localhost 50001

# Test blockchain.headers.subscribe
echo '{"id": 2, "method": "blockchain.headers.subscribe", "params": []}' | nc -q 1 localhost 50001
```

**Expected response:**
```json
{"jsonrpc": "2.0", "result": ["ElectrumX 1.16.0", "1.4"], "id": 1}
```

---

## 📈 Performance

### Default Configuration

```
Cache: 2000 MB
Max Sessions: 1000
File Limit: 16384
Max Memory: 8 GB
```

### Optimization (Powerful Server)

Edit `/var/electrum/electrumx.conf`:

```bash
# For 8GB+ RAM
CACHE_MB=4000
MAX_SESSIONS=2000

# For 16GB+ RAM
CACHE_MB=8000
MAX_SESSIONS=5000
```

Then: `sudo systemctl restart electrumx`

---

## ⚠️ Important Notes

### Initial Indexing

Complete indexing will take **several hours**. This is normal!

Monitor progress:
```bash
sudo journalctl -u electrumx -f | grep height
```

### FixedCoin Addresses

FixedCoin uses **unique** prefixes:
- **Legacy (P2PKH)**: Addresses starting with **"Q"**
- **Script (P2SH)**: Addresses starting with **"1"**

This is different from standard Bitcoin!

### Peer Discovery

The server is configured to connect only to the FixedCoin network:
- Peer: `electrumx.fixedcoin.org:50002`
- Peer discovery: `self` (doesn't announce to Bitcoin network)

---

## 🛠️ Troubleshooting

### Service won't start

```bash
# View errors
sudo journalctl -u electrumx -n 50 --no-pager

# Check FixedCoin
/var/fixedcoin/bin/fixedcoin-cli -datadir=/var/fixedcoin/data getblockchaininfo
```

### Error "Cannot connect to daemon"

Check RPC credentials:

```bash
cat /var/fixedcoin/data/fixedcoin.conf | grep rpc
```

Must match in `/var/electrum/electrumx.conf`:
```
DAEMON_URL=http://your_rpc_username:your_rpc_password@127.0.0.1:24761/
```

### Error "txindex not enabled"

```bash
# 1. Stop FixedCoin
sudo systemctl stop fixedcoin

# 2. Add txindex=1
echo "txindex=1" | sudo tee -a /var/fixedcoin/data/fixedcoin.conf

# 3. Reindex (IMPORTANT)
sudo /var/fixedcoin/bin/fixedcoind -datadir=/var/fixedcoin/data -reindex -daemon

# 4. Wait for completion, then verify
/var/fixedcoin/bin/fixedcoin-cli -datadir=/var/fixedcoin/data getindexinfo
```

### Connecting to Bitcoin servers instead of FixedCoin

If you see errors like `marking bad: (bad height 920,764 (ours: 532))`, this means ElectrumX is trying to connect to Bitcoin servers.

**Solution:** The configuration includes `PEER_DISCOVERY=self` which prevents this. If you still see these errors, they will stop after a few minutes as ElectrumX realizes these are incompatible peers.

---

## 📚 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Quick installation guide
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Detailed troubleshooting
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

---

## 🔐 Security

- ✅ Non-privileged user service
- ✅ Filesystem isolation
- ✅ Resource limits configured
- ✅ Firewall auto-configured
- ✅ Automatic log rotation

### Recommendations

- Use SSL (port 50002) for public connections
- Replace self-signed certificate with Let's Encrypt
- Keep system updated: `sudo apt update && sudo apt upgrade`
- Monitor logs regularly
- NEVER share RPC credentials

---

## 🤝 Contributing

Contributions are welcome! Please open an Issue or Pull Request on GitHub.

---

## 📝 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## 🆘 Support

### If you encounter problems:

1. **Check logs**: `sudo journalctl -u electrumx -n 100`
2. **Review troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. **Open GitHub Issue**: Include logs and system info

---

## ✅ Post-Installation Checklist

- [ ] Service active: `systemctl is-active electrumx`
- [ ] Indexing in progress: `journalctl -u electrumx -f`
- [ ] Ports open: `netstat -tuln | grep 5000`
- [ ] FixedCoin synced with txindex active
- [ ] SSL certificate present: `ls -la /var/electrum/ssl/`
- [ ] Monitoring active: `crontab -l | grep electrumx`

---

## 🎉 Congratulations!

Your ElectrumX server for FixedCoin is operational!

**Connect from an Electrum wallet:**

```bash
electrum --server YOUR_IP:50002:s
```

Or in the interface:
- Tools → Network → Server
- Enter: `YOUR_IP:50002`
- Check "Use SSL"

---

**Developed for the FixedCoin community** 🚀

**Production server**: `electrumx.fixedcoin.org:50002`

**Based on ElectrumX** - [GitHub](https://github.com/spesmilo/electrumx)
