package com.sevenblock.demowallet;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import com.sevenblock.walletsdk.result.TxSignResult;
import com.sevenblock.walletsdk.wallet.EthereumTransaction;
import com.sevenblock.walletsdk.wallet.SevenblockWallet;

import java.math.BigInteger;

public class EthTransactionActivity extends AppCompatActivity {
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
            Intent intent = new Intent(EthTransactionActivity.this, AccessNfcActivity.class);
            intent.putExtra(AccessNfcActivity.EXTRA_ACTION, AccessNfcActivity.ACTION_READ_PRIVATE_KEY);
            intentActivityResultLauncher.launch(intent);
        });
    }

    private void doSignTransaction(byte[] privateKey, byte[] deviceId) {
        TextView status = findViewById(R.id.status);
        try {
            EthereumTransaction ethTx = new EthereumTransaction(BigInteger.valueOf(9L),
                    BigInteger.valueOf(20000000000L),
                    BigInteger.valueOf(21000L),
                    "0x94778b0dd870df2371437e84c6a2fa3091a64b6b",
                    BigInteger.valueOf(1000000000000000000L), "");

            TxSignResult result = ethTx.signTransaction(mSevenblockWallet,
                    TestConstants.getCoinType(),
                    TestConstants.mainNet,
                    privateKey,
                    TestConstants.password,
                    TestConstants.getChainId(), deviceId);
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
}