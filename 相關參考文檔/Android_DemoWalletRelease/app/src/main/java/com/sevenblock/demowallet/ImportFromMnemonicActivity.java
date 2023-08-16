package com.sevenblock.demowallet;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import com.sevenblock.walletsdk.result.ImportWalletByMnemonicResult;
import com.sevenblock.walletsdk.wallet.SevenblockWallet;

public class ImportFromMnemonicActivity extends AppCompatActivity {
    private final static String TAG = ImportFromMnemonicActivity.class.getSimpleName();
    private SevenblockWallet mSevenblockWallet;
    private ImportWalletByMnemonicResult importWalletByMnemonicResult;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_import_from_mnemonic);
        mSevenblockWallet = SevenblockWallet.shareInstance(this);
        ActivityResultLauncher<Intent> intentActivityResultLauncher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(), result -> {
                    int resultCode = result.getResultCode();
                    if (resultCode == RESULT_OK) {
                        Toast.makeText(ImportFromMnemonicActivity.this, "写入设备成功", Toast.LENGTH_SHORT).show();
                    }
                });
        findViewById(R.id.export).setOnClickListener((view) -> {
            Intent intent = new Intent(ImportFromMnemonicActivity.this, AccessNfcActivity.class);
            intent.putExtra(AccessNfcActivity.EXTRA_ACTION, AccessNfcActivity.ACTION_WRITE_PRIVATE_KEY);
            intent.putExtra(AccessNfcActivity.EXTRA_PASSWORD, TestConstants.password);
            intent.putExtra(AccessNfcActivity.EXTRA_PRIVATE_KEY, importWalletByMnemonicResult.getPrivateKey());
            intentActivityResultLauncher.launch(intent);
        });

        testImportWallet();
    }

    public void testImportWallet() {
        TextView title = findViewById(R.id.status);
        try {
            importWalletByMnemonicResult = mSevenblockWallet.importWalletByMnemonic(TestConstants.getCoinType(),
                    TestConstants.mnemonics,
                    TestConstants.mainNet,
                    TestConstants.password);
        } catch (Exception e) {
            title.setText("导入失败:" + e.getMessage());
            return;
        }

        Log.e(TAG, "mSevenblockWallet.importWalletByMnemonic: " + importWalletByMnemonicResult);
        title.setText("导入钱包成功");
        TextView privateKey = findViewById(R.id.private_key);
        privateKey.setText(TypeConversion.bytes2HexString(importWalletByMnemonicResult.getPrivateKey()));

        TextView address = findViewById(R.id.address);
        address.setText(importWalletByMnemonicResult.getAddress());
        TestConstants.address = importWalletByMnemonicResult.getAddress();
    }
}
