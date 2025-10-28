# 🔧 Troubleshooting Guide

## Common Issues

### ❌ Service won't start

```bash
# View errors
sudo journalctl -u electrumx -n 50 --no-pager

# Check FixedCoin
/var/fixedcoin/bin/fixedcoin-cli -datadir=/var/fixedcoin/data getblockchaininfo

# Check txindex
/var/fixedcoin/bin/fixedcoin-cli -datadir=/var/fixedcoin/data getindexinfo
```

**Solutions**:
1. Ensure FixedCoin is running
2. Verify `txindex=1` is in fixedcoin.conf
3. Check RPC credentials

---

### ❌ Error "Cannot connect to daemon"

**Cause**: ElectrumX cannot connect to FixedCoin

**Solution**:
```bash
# Check config
cat /var/fixedcoin/data/fixedcoin.conf | grep rpc

# Should contain:
# rpcuser=your_rpc_username
# rpcpassword=your_rpc_password
# rpcport=24761
```

Verify that `/var/electrum/electrumx.conf` contains:
```
DAEMON_URL=http://your_rpc_username:your_rpc_password@127.0.0.1:24761/
```

---

### ❌ Error "txindex not enabled"

**Solution**:
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

---

### ❌ No client connections

```bash
# Check ports
sudo netstat -tuln | grep -E ":(50001|50002|50004)"

# Open ports
sudo ufw allow 50001/tcp
sudo ufw allow 50002/tcp
sudo ufw allow 50004/tcp
```

---

### ❌ Slow indexing

**This is normal!** Indexing can take several hours.

**Monitor progress**:
```bash
sudo journalctl -u electrumx -f | grep height
```

**Optimize** (if you have lots of RAM):
```bash
sudo nano /var/electrum/electrumx.conf
# Increase CACHE_MB=4000
sudo systemctl restart electrumx
```

---

### ❌ Error "genesis block hash mismatch"

**Cause**: Incorrect FixedCoin parameters in coins.py

**Solution**: The script automatically adds the correct parameters. If you see this error, verify the FixedCoin class in `/home/electrumx/electrumx-source/electrumx/lib/coins.py`

---

### ❌ Connecting to Bitcoin servers

If you see errors like:
```
ERROR:PeerManager:[electrum.hsmiths.com:50002 SSL] marking bad: (bad height 920,764 (ours: 532))
```

**Explanation**: ElectrumX is discovering Bitcoin peers and marking them as incompatible. This is normal and will stop after a few minutes.

**Why it happens**: ElectrumX's peer discovery tries to find compatible servers. When it finds Bitcoin servers, it marks them as "bad" because they have different blockchain heights.

**The fix is automatic**: The configuration includes `PEER_DISCOVERY=self` which prevents announcing to other networks. The errors will stop once ElectrumX finishes its initial peer scan.

**To verify**:
```bash
grep "PEER_DISCOVERY" /var/electrum/electrumx.conf
# Should show: PEER_DISCOVERY=self
```

---

### ❌ Invalid SSL certificate

**For test server**: Self-signed certificate is normal

**For public server**: Use Let's Encrypt during installation (option [1])

---

### ❌ Python virtual environment issues on Debian 12

**Error**: `No module named pip.__main__`

**Solution**: The script uses a Python virtual environment which solves this. If you still have issues:

```bash
# Ensure python3-venv is installed
sudo apt install python3-venv

# Recreate virtual environment
sudo rm -rf /home/electrumx/electrumx-venv
sudo -u electrumx python3 -m venv /home/electrumx/electrumx-venv
sudo -u electrumx bash -c "
    source /home/electrumx/electrumx-venv/bin/activate
    pip install --upgrade pip
    cd /home/electrumx/electrumx-source
    pip install -e .
"
```

---

## 🔍 Diagnostic Tools

### Full Check

```bash
# Service status
sudo systemctl status electrumx

# Real-time logs
sudo journalctl -u electrumx -f

# Last 100 lines
sudo journalctl -u electrumx -n 100 --no-pager

# Search for errors
sudo journalctl -u electrumx | grep -i error

# Process
ps aux | grep electrumx

# Connections
sudo netstat -tn | grep -E ":(50001|50002|50004)"

# Resources
htop
```

---

## 📞 Support

If the problem persists:

1. Check logs: `sudo journalctl -u electrumx -n 200 > logs.txt`
2. Get system info: `uname -a; lsb_release -a`
3. Open GitHub Issue with these files

---

## ✅ Troubleshooting Checklist

Before asking for help:

- [ ] FixedCoin is running
- [ ] txindex=1 enabled and synced
- [ ] Service electrumx active
- [ ] No critical errors in logs
- [ ] Ports open (50001, 50002, 50004)
- [ ] Disk space >10GB
- [ ] Available RAM >2GB
- [ ] Python virtual environment exists at `/home/electrumx/electrumx-venv`

---

**Happy troubleshooting!** 🔧
