# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.4] - 2025-10-25 - Production Ready

### Added
- **FixedCoin peer discovery**: Added `PEERS` configuration to connect to FixedCoin network
- **Peer isolation**: Set `PEER_DISCOVERY=self` to prevent connecting to Bitcoin network
- **Professional documentation**: All documentation in English
- **Security**: Removed personal information from default configurations

### Changed
- **Default RPC credentials**: Changed to generic `rpcuser`/`rpcpassword`
- **Documentation language**: All files now in English
- **Peer configuration**: Explicit FixedCoin peer: `electrumx.fixedcoin.org s50002`

### Fixed
- **Bitcoin peer connection**: ElectrumX no longer tries to connect to Bitcoin servers
- **Peer discovery**: Configured to only use FixedCoin network
- **Documentation**: Clarified that Bitcoin peer errors are temporary and expected

### Technical Details
- Added `PEERS` list in FixedCoin class in coins.py
- Configured `PEER_DISCOVERY=self` in electrumx.conf
- Added `PEER_ANNOUNCE=` (empty) to disable announcement

---

## [1.0.3] - 2025-10-25 - Debian 12 Fix (Virtual Environment)

### Fixed
- **CRITICAL**: Fixed Debian 12 compatibility using Python virtual environment
  - Error resolved: `No module named pip.__main__`
  - Cause: Debian 12 implements PEP 668 which blocks system pip
  - Solution: Created isolated venv at `/home/electrumx/electrumx-venv`

### Added
- Python virtual environment support (venv)
- Complete isolation of Python packages
- Compatible with system Python (no additional installation needed)

### Changed
- Installation method: `pip install --user` → Python venv
- Service binary path: `~/.local/bin/electrumx_server` → `~/electrumx-venv/bin/electrumx_server`
- Python packages: System installation → Isolated in venv

### Technical Details
```bash
# Old method (v1.0.2) - Doesn't work on Debian 12
sudo -u electrumx python3 -m pip install --user electrumx

# New method (v1.0.3) - Works everywhere
sudo -u electrumx python3 -m venv /home/electrumx/electrumx-venv
sudo -u electrumx bash -c "source /home/electrumx/electrumx-venv/bin/activate && pip install electrumx"
```

### Tested On
- ✅ Debian 12 (bookworm) - **NOW WORKS**
- ✅ Ubuntu 22.04 LTS
- ✅ Debian 11 (bullseye)

---

## [1.0.2] - 2025-10-25 - Debian 12 Attempt

### Fixed
- Fixed `ExecStart` in systemd service
  - Before: `ExecStart=/home/electrumx/.local/bin/electrumx_server`
  - After: `ExecStart=/usr/bin/python3 /home/electrumx/.local/bin/electrumx_server`

### Added
- Support for Debian 11/12
- Automatic OS detection

### Note
⚠️ This version was superseded by v1.0.3 which properly fixes Debian 12 compatibility using Python virtual environment.

---

## [1.0.1] - 2025-10-25 - Initial Production Release

### Added
- Complete automated ElectrumX installation for FixedCoin
- **Correct FixedCoin parameters** (P2PKH=0x01, P2SH=0x00)
- Systemd service with auto-restart
- SSL certificate support (self-signed + Let's Encrypt script)
- Hourly automatic monitoring
- Log rotation configured
- UFW firewall auto-configuration

### Features
#### Scripts
1. **install_electrumx_fixedcoin.sh** - Main installation
2. **test_electrumx.sh** - JSON-RPC tests
3. **setup_letsencrypt.sh** - Automatic SSL configuration
4. **check_electrumx_health.sh** - Complete diagnostic
5. **electrumx_helper.sh** - Interactive assistant (16 commands)
6. **uninstall_electrumx_fixedcoin.sh** - Clean uninstallation

#### Configuration
**Ports**:
- TCP: 50001
- SSL: 50002
- WSS: 50004
- Internal RPC: 8000

**Resources**:
- Cache: 2000 MB
- Max sessions: 1000
- File limit: 16384
- Max memory: 8 GB

#### Security
- Non-privileged user (electrumx)
- Filesystem isolation
- Resource limits
- NoNewPrivileges enabled
- PrivateTmp enabled

#### FixedCoin Specifics
- Native support with correct parameters
- Genesis hash validated
- P2PKH addresses: "Q..." (0x01)
- P2SH addresses: "1..." (0x00)
- Compatible with Bitcoin v25 fork

### Tested On
- Ubuntu 22.04 LTS
- FixedCoin v1.x (Bitcoin v25 fork)
- Python 3.10/3.11
- ElectrumX 1.16.0

---

## [Unreleased]

### Planned Features
- [ ] Optional Docker support
- [ ] Web monitoring dashboard
- [ ] Prometheus/Grafana metrics
- [ ] Automatic backup script
- [ ] Multi-coin support

---

## Version Compatibility

| Version | Ubuntu 22.04 | Debian 11 | Debian 12 | Method |
|---------|--------------|-----------|-----------|---------|
| 1.0.1   | ✅           | ⚠️        | ❌        | --user  |
| 1.0.2   | ✅           | ✅        | ⚠️        | --user  |
| 1.0.3   | ✅           | ✅        | ✅        | venv    |
| 1.0.4   | ✅           | ✅        | ✅        | venv    |

**Legend**:
- ✅ Fully supported and tested
- ⚠️ Works with limitations
- ❌ Not supported

---

## Production Servers

**Tested and validated on**:
- electrumx.fixedcoin.org:50002
- electrumx.nitopool.fr:50002

**Release Date**: October 25, 2025  
**Status**: Production Stable ✅  
**Developed for**: FixedCoin Community 🚀

---

## License

MIT License - Free to use and modify

---

## Support

For questions or issues:
- GitHub Issues: https://github.com/yourusername/electrumx-fixedcoin/issues
- Documentation: [README.md](README.md)
- Troubleshooting: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
