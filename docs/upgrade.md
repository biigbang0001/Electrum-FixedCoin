# Existing deployment: v30 compatibility and genesis index repair

The validated deployment keeps `electrumx.service`, private configuration at
`/var/electrum/electrumx.conf`, DB `/var/electrum/db`, and the existing executable
`/home/electrumx/.local/bin/electrumx_server`. Python imports its installed
package from `/home/electrumx/.local/lib/python3.10/site-packages/electrumx`.
The historical `/var/electrum/electrumx-source/src/electrumx` checkout is also
kept consistent. The fresh-install template uses an isolated virtualenv instead;
do not replace a working unit solely to change its installation layout.

## Required change

Only the FixedCoin adapter's documentation and genesis handling change.
It inherits the upstream genesis hash verification, returning the header with
zero transactions instead of indexing an unspendable coinbase. Address prefixes,
genesis hash, SegWit decoding, reorganization limit and protocol methods remain
unchanged. The private service configuration and public ports stay in place.
The banner describes the 21,000 FIX limit at block 52,560 without calling it
current circulation.

An existing DB containing the genesis output cannot be fixed merely by
restarting: genesis is outside the retained undo window. Editing only its UTXO
key would leave transaction/history counters inconsistent. Build a clean index
with the corrected source in a separate directory and on separate loopback
ports, using the same Core node. Do not delete or modify the live index.

## Verification and cutover

1. Run `PYTHONPATH=runtime/src python3 -m unittest discover -s tests -v` with the
   service's Python dependencies. Verify invalid genesis is still rejected.
2. Build the isolated index with peer discovery disabled. Wait for Core's tip.
3. Compare headers, balances, histories and unspent outputs with the live
   service for ordinary addresses and the frozen output. Only the unspendable
   genesis coinbase should disappear; compare it with Core's empty gettxout.
4. Stop the staging process cleanly, then stop only `electrumx.service`.
   Retain the previous DB and installed adapter for rollback; put the verified
   DB at the configured DB_DIRECTORY and the corrected adapter in the actual
   imported package. Preserve ownership and permissions.
5. Start `electrumx.service`. Check synchronization, TCP/TLS/WSS, genesis
   exclusion and unchanged balances/history. Keep the admin port on loopback.

Rollback: stop ElectrumX, restore the previous DB and adapter together, and
restart the same service. Do not mix the old adapter with the new index.
After successful verification remove temporary staging processes and credentials.
Retain a bounded recovery copy separately from the source repository.

No Core consensus code, Core workflow or web wallet needs modification here.
Wallet clients that independently validate ASERT or ignore the frozen outpoint
need a separate compatibility review. The ElectrumX wire protocol is preserved.
