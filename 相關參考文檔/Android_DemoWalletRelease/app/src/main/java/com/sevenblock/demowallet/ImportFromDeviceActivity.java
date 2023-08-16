package com.sevenblock.demowallet;

import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import com.sevenblock.walletsdk.result.ImportWalletByPrivateKeyResult;
import com.sevenblock.walletsdk.wallet.SevenblockWallet;

public class ImportFromDeviceActivity extends AppCompatActivity {
    private SevenblockWallet mSevenblockWallet;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_import_from_device);
        mSevenblockWallet = SevenblockWallet.shareInstance(this);
        ActivityResultLauncher<Intent> intentActivityResultLauncher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(), result -> {
                    int resultCode = result.getResultCode();
                    Intent intent = result.getData();
                    if (resultCode == RESULT_OK && intent != null) {
                        byte[] privateKey = intent.getByteArrayExtra(AccessNfcActivity.EXTRA_PRIVATE_KEY);
                        byte[] deviceId = intent.getByteArrayExtra(AccessNfcActivity.EXTRA_DEVICE_ID);
                        doImportWalletFromPrivateKey(privateKey, deviceId);
                    }
                });
        findViewById(R.id.scan).setOnClickListener((view) -> {
            Intent intent = new Intent(ImportFromDeviceActivity.this, AccessNfcActivity.class);
            intent.putExtra(AccessNfcActivity.EXTRA_ACTION, AccessNfcActivity.ACTION_READ_PRIVATE_KEY);
            intentActivityResultLauncher.launch(intent);
        });
    }

    private void doImportWalletFromPrivateKey(byte[] privateKey, byte[] deviceId) {
        TextView title = findViewById(R.id.status);
        try {
            ImportWalletByPrivateKeyResult importWalletByPrivateKeyResult = mSevenblockWallet.importWalletByPrivateKey(
                    TestConstants.getCoinType(),
                    TestConstants.mainNet,
                    privateKey,
                    TestConstants.password,
                    deviceId);
            TextView address = findViewById(R.id.address);
            address.setText(importWalletByPrivateKeyResult.getAddress());
            TestConstants.address = importWalletByPrivateKeyResult.getAddress();
            title.setText("导入成功");
        } catch (Exception e) {
            title.setText("导入失败:" + e.getMessage());
            e.printStackTrace();
        }
    }
}
