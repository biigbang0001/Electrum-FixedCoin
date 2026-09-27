# ElectrumX for FixedCoin

FixedCoin Electrum server sources and deployment tooling. The `runtime/` tree
contains the complete Python application used by the deployed service, based on
KomodoPlatform/electrumx-1 commit `00b4c88a0d97ce44c8eda2d9549e4f419395fc46`
(ElectrumX 1.18.0), with the FixedCoin adapter in `lib/coins.py`.
All other 39 Python files matched the deployed upstream source at capture.
Production credentials, certificates, logs and indexes are excluded.

## v30 compatibility

Core v30 must be running before block **52,560**. The maximum becomes
**21,000 FIX** at that height, alongside ASERT V2 and the new reward schedule.
Historical rules remain valid before activation. This server delegates consensus
to Core, has no 10,000 FIX monetary validation ceiling and does not calculate
ASERT independently. Existing address encodings and Electrum RPC methods remain
unchanged; no validation is bypassed to accommodate v30.

The FixedCoin genesis coinbase is unspendable. The adapter now uses the inherited
genesis hash check and excludes that coinbase from the UTXO index. An old index
built with the faulty adapter needs a rebuild to remove its fictitious 1 FIX.
The supply increase alone does not require reindexing.

The consensus-frozen output
`53968570e24004c7e1ec0b199766a4c088c219f2c319c7f43b6af74c69894147:0`
remains in transaction history and the unspent-output API, as in Core's UTXO
set. Unspent does not mean spendable: clients must exclude this exact outpoint
when selecting inputs and reporting available balance. Other outputs to its
address are unaffected. Core rejects its spend from block 628, including after
v30. No web wallet code or deployment is included in this repository.

## Fresh installation

Use Ubuntu 22.04 with Python 3.10 and a synchronized, unpruned Core v30 node with
`txindex=1` and RPC enabled. The supplied runtime versions match the validated
deployment. Other Python/OS combinations need separate qualification.

```sh
git clone https://github.com/biigbang0001/Electrum-FixedCoin.git
cd Electrum-FixedCoin
sudo install -d -m 750 /var/electrum
sudo install -m 600 deploy/electrumx.conf.example /var/electrum/electrumx.conf
# Edit the private configuration: real credentials and the node's RPC port.
sudo bash install_electrumx_fixedcoin.sh
sudo systemctl enable --now electrumx
```

The installer uses bundled source, installs into `/var/electrum/venv`, runs the
adapter tests, and refuses to overwrite an existing deployment. It does not
remove databases, fetch a moving upstream branch or silently start the service.
The sample binds to loopback. To offer public services, configure TCP 50001,
TLS 50002 and WSS 50004 plus readable certificate/key paths; keep admin RPC 8000
on loopback. Never expose the Core RPC port or credentials to clients.

See [existing-installation upgrade and rollback](docs/upgrade.md).

Project: [web.fixedcoin.org](https://web.fixedcoin.org/).
Core: [official v30 source](https://github.com/Fixed-Blockchain/fixedcoin/tree/v30).
Contact: **help@fixedcoin.org**.

## License

Upstream notices are retained in `runtime/LICENCE` and its source files.
See also the repository's `LICENSE`.
