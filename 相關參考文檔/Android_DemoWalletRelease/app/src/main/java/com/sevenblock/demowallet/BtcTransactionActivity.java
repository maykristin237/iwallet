package com.sevenblock.demowallet;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import com.sevenblock.walletsdk.result.TxSignResult;
import com.sevenblock.walletsdk.wallet.BitcoinTransaction;
import com.sevenblock.walletsdk.wallet.SevenblockWallet;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BtcTransactionActivity extends AppCompatActivity {
    private final static String TAG = "BtcTransactionActivity";
    private SevenblockWallet mSevenblockWallet;

    @Override
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_btc_transaction);
        mSevenblockWallet = SevenblockWallet.shareInstance(this);

        ActivityResultLauncher<Intent> intentActivityResultLauncher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(), result -> {
                    int resultCode = result.getResultCode();
                    Intent intent = result.getData();
                    if (resultCode == RESULT_OK && intent != null) {
                        byte[] privateKey = intent.getByteArrayExtra(AccessNfcActivity.EXTRA_PRIVATE_KEY);
                        byte[] deviceId = intent.getByteArrayExtra(AccessNfcActivity.EXTRA_DEVICE_ID);
                        doSignTransaction(privateKey, deviceId);
                        //Toast.makeText(BtcTransactionActivity.this, "重置设备成功", Toast.LENGTH_SHORT).show();
                    }
                });
        findViewById(R.id.scan).setOnClickListener((view) -> {
            Intent intent = new Intent(BtcTransactionActivity.this, AccessNfcActivity.class);
            intent.putExtra(AccessNfcActivity.EXTRA_ACTION, AccessNfcActivity.ACTION_READ_PRIVATE_KEY);
            intentActivityResultLauncher.launch(intent);
        });
    }

    private void doSignTransaction(byte[] privateKey, byte[] deviceId) {
        String address = TestConstants.address;
        TextView status = findViewById(R.id.status);
        BitcoinTransaction transaction = createMultiUXTOOnTestnet(address);
        try {
            TxSignResult result = transaction.signTransaction(mSevenblockWallet,
                    TestConstants.getCoinType(),
                    TestConstants.mainNet,
                    privateKey,
                    TestConstants.password,
                    TestConstants.getChainId(),
                    deviceId);
            Log.e(TAG, "transaction.signTransaction: " + result);
            TextView hex = findViewById(R.id.transaction_hex);
            hex.setText(result.getSignedTx());
            TextView hash = findViewById(R.id.transaction_hash);
            hash.setText(result.getTxHash());
            TextView wtxId = findViewById(R.id.wtx_id);
            wtxId.setText(result.getWtxID());
            status.setText("签名成功");
        } catch (Exception e) {
            e.printStackTrace();
            status.setText("签名失败:" + e.getMessage());
        }
    }

    private static BitcoinTransaction createMultiUXTOOnTestnet(String address) {
        ArrayList<BitcoinTransaction.UTXO> utxo = new ArrayList<>();

        utxo.add(new BitcoinTransaction.UTXO(
                "983adf9d813a2b8057454cc6f36c6081948af849966f9b9a33e5b653b02f227a", 0,
                200000000, address,
                "76a914118c3123196e030a8a607c22bafc1577af61497d88ac",
                "0/22"));
        utxo.add(new BitcoinTransaction.UTXO(
                "45ef8ac7f78b3d7d5ce71ae7934aea02f4ece1af458773f12af8ca4d79a9b531", 1,
                200000000, address,
                "76a914383fb81cb0a3fc724b5e08cf8bbd404336d711f688ac",
                "0/0"));
        utxo.add(new BitcoinTransaction.UTXO(
                "14c67e92611dc33df31887bbc468fbbb6df4b77f551071d888a195d1df402ca9", 0,
                200000000, address,
                "76a914383fb81cb0a3fc724b5e08cf8bbd404336d711f688ac",
                "0/0"));
        utxo.add(new BitcoinTransaction.UTXO(
                "117fb6b85ded92e87ee3b599fb0468f13aa0c24b4a442a0d334fb184883e9ab9", 1,
                200000000, address,
                "76a914383fb81cb0a3fc724b5e08cf8bbd404336d711f688ac",
                "0/0"));

        return new BitcoinTransaction(address, 53,
                750000000, 502130, utxo);
    }
}
