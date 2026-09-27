import unittest
from unittest.mock import patch
from electrumx.lib.coins import FixedCoin, CoinError
from electrumx.lib.tx import DeserializerSegWit


class FixedCoinTests(unittest.TestCase):
    def test_protocol_identity_and_encodings_preserved(self):
        self.assertEqual(FixedCoin.NAME, 'FixedCoin')
        self.assertEqual(FixedCoin.NET, 'mainnet')
        self.assertEqual(FixedCoin.P2PKH_VERBYTE, b'\x01')
        self.assertEqual(FixedCoin.P2SH_VERBYTES, (b'\x00',))
        self.assertEqual(FixedCoin.WIF_BYTE, b'\x80')
        self.assertEqual(FixedCoin.XPUB_VERBYTES.hex(), '0488b21e')
        self.assertEqual(FixedCoin.XPRV_VERBYTES.hex(), '0488ade4')
        self.assertIs(FixedCoin.DESERIALIZER, DeserializerSegWit)
        self.assertEqual(FixedCoin.REORG_LIMIT, 800)

    def test_wrong_genesis_is_still_rejected(self):
        with self.assertRaises(CoinError):
            FixedCoin.genesis_block(bytes(81))

    def test_valid_genesis_keeps_header_but_removes_unspendable_coinbase(self):
        header = bytes(range(80))
        with patch.object(FixedCoin, 'header_hash', return_value=bytes.fromhex(FixedCoin.GENESIS_HASH)[::-1]):
            result = FixedCoin.genesis_block(header + b'\x01' + b'coinbase payload')
        self.assertEqual(result, header + b'\x00')
        self.assertEqual(FixedCoin.block(result, 0).transactions, [])


if __name__ == '__main__':
    unittest.main()
