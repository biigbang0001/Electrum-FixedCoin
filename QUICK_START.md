# 🚀 Quick Start - 3 Steps Installation

## Installation in 3 Commands

```bash
# 1. Download
git clone https://github.com/yourusername/electrumx-fixedcoin.git
cd electrumx-fixedcoin

# 2. Make executable
chmod +x *.sh

# 3. Install
sudo ./install_electrumx_fixedcoin.sh
```

## ⚠️ BEFORE INSTALLATION

Configure FixedCoin with `txindex=1`:

```bash
# Edit config
sudo nano /var/fixedcoin/data/fixedcoin.conf
```

Add:
```ini
server=1
txindex=1
rpcuser=your_rpc_username
rpcpassword=your_secure_rpc_password
rpcport=24761
```

Then:
```bash
sudo /var/fixedcoin/bin/fixedcoind -reindex -daemon
```

## ✅ Verification

```bash
# Status
sudo systemctl status electrumx

# Logs
sudo journalctl -u electrumx -f

# Test
echo '{"id": 1, "method": "server.version", "params": ["test", "1.4"]}' | nc -q 1 localhost 50001
```

## 🔧 Useful Commands

```bash
sudo systemctl start electrumx     # Start
sudo systemctl stop electrumx      # Stop
sudo systemctl restart electrumx   # Restart
```

## 📊 Ports

- TCP: 50001
- **SSL: 50002** (recommended)
- WSS: 50004

## 🔐 SSL Let's Encrypt (Optional)

During installation, choose option [1] for Let's Encrypt and provide:
- Your domain name (e.g., electrumx.yourdomain.com)
- Your email address

---

**Full documentation**: [README.md](README.md)
