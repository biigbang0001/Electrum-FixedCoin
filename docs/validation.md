# Validation — 2026-09-27

Base: ElectrumX 1.18.0, KomodoPlatform/electrumx-1
`00b4c88a0d97ce44c8eda2d9549e4f419395fc46`, Python 3.10.

- Compared all 40 deployed Python files with the upstream checkout: 39 matched;
  only `lib/coins.py` contained the deployed FixedCoin adaptation.
- Three adapter unit tests passed: identity/encodings, rejection of an invalid
  genesis, and exclusion of the valid genesis coinbase while retaining its header.
- Built an installable wheel from the bundled source. Installed it in an
  isolated target and ran the same adapter tests successfully.
- Rebuilt a separate database against Core v30 through height **49,859**.
  The live service remained available during reconstruction.
- Compared headers and ordinary balances/history/UTXOs at sample heights 1,
  627, 628 and 49,858. Compared the exact frozen-output script independently.
  Those responses matched. The old index's genesis output was present for 1 FIX;
  the reconstructed index omitted it, matching Core's empty `gettxout` result.
- After cutover, all 40 Python source hashes matched both the installed package
  and the server's source checkout. TCP 50001, TLS 50002 and WSS 50004 answered
  at height 49,859. TLS certificate validation succeeded for
  `electrumx.fixedcoin.org`. Genesis balance was zero, its unspent entry absent,
  and the updated banner was served. Core and ElectrumX were active.

The fresh installer was syntax-checked; its wheel build and application tests
were exercised separately. The complete root installer was not run against the
existing production installation, which it is designed to refuse.

The production chain has not reached block 52,560. This is not evidence of a
live post-activation block. ElectrumX delegates monetary and ASERT consensus to
the v30 Core node; no independent consensus checks were removed or disabled.
