#!/usr/bin/env bash
# Install the bundled, verified FixedCoin ElectrumX source. Fresh installs only.
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ $EUID -ne 0 ]]; then echo "Run as root." >&2; exit 1; fi
if [[ ! -f "$root/runtime/pyproject.toml" || ! -f "$root/runtime/requirements-runtime.txt" || ! -d "$root/tests" ]]; then
  echo "Clone the complete repository; the standalone script is not sufficient." >&2
  exit 1
fi
if [[ -e /var/electrum/venv || -d /var/electrum/db || -e /etc/systemd/system/electrumx.service ]]; then
  echo "Existing installation detected. Follow docs/upgrade.md; no files changed." >&2
  exit 1
fi
if [[ ! -f /var/electrum/electrumx.conf ]] || grep -q CHANGE_ME /var/electrum/electrumx.conf; then
  echo "Configure /var/electrum/electrumx.conf from deploy/electrumx.conf.example first." >&2
  exit 1
fi
apt-get update
apt-get install -y python3 python3-venv python3-dev build-essential libleveldb-dev
id electrumx >/dev/null 2>&1 || useradd --system --create-home --shell /usr/sbin/nologin electrumx
install -d -o electrumx -g electrumx -m 750 /var/electrum /var/electrum/db
python3 -m venv /var/electrum/venv
/var/electrum/venv/bin/pip install -r "$root/runtime/requirements-runtime.txt"
/var/electrum/venv/bin/pip install --no-deps "$root/runtime"
/var/electrum/venv/bin/python -m unittest discover -s "$root/tests" -v
install -o electrumx -g electrumx -m 644 "$root/deploy/banner.txt" /var/electrum/banner.txt
chmod 600 /var/electrum/electrumx.conf
install -m 644 "$root/deploy/electrumx.service" /etc/systemd/system/electrumx.service
systemctl daemon-reload
echo "Installed and tested. Run: systemctl enable --now electrumx"
echo "Configure TLS/WSS and public endpoints in electrumx.conf before exposing them."
