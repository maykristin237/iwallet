package com.sevenblock.demowallet;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import com.sevenblock.walletsdk.result.CreateWalletResult;
import com.sevenblock.walletsdk.wallet.SevenblockWallet;

public class CreateWalletActivity extends AppCompatActivity {
    private final static String TAG = CreateWalletActivity.class.getSimpleName();
    private SevenblockWallet mSevenblockWallet;
    private CreateWalletResult createWalletResult;

    @Override
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.activity_create_wallet);
        mSevenblockWallet = SevenblockWallet.shareInstance(this);

        ActivityResultLauncher<Intent> intentActivityResultLauncher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(), result -> {
                    int resultCode = result.getResultCode();
                    if (resultCode == RESULT_OK) {
                        Toast.makeText(CreateWalletActivity.this, "写入设备成功", Toast.LENGTH_SHORT).show();
                    }
                });
        findViewById(R.id.export).setOnClickListener((view) -> {
            Intent intent = new Intent(CreateWalletActivity.this, AccessNfcActivity.class);
            intent.putExtra(AccessNfcActivity.EXTRA_ACTION, AccessNfcActivity.ACTION_WRITE_PRIVATE_KEY);
            intent.putExtra(AccessNfcActivity.EXTRA_PASSWORD, TestConstants.password);
            intent.putExtra(AccessNfcActivity.EXTRA_PRIVATE_KEY, createWalletResult.getPrivateKey());
            intentActivityResultLauncher.launch(intent);
        });

        testCreateWalletResult();
    }

    public void testCreateWalletResult() {
        TextView title = findViewById(R.id.status);
        try {
            createWalletResult = mSevenblockWallet.createWalletWithPath(TestConstants.getCoinType(), TestConstants.mainNet, TestConstants.password);
        } catch (Exception e) {
            title.setText("创建失败:" + e.getMessage());
            return;
        }
        Log.e(TAG, "createWalletResult: " + createWalletResult);
        title.setText("创建钱包成功" );
        TextView privateKey = findViewById(R.id.private_key);
        privateKey.setText(TypeConversion.bytes2HexString(createWalletResult.getPrivateKey()));

        TextView address = findViewById(R.id.address);
        address.setText(createWalletResult.getAddress());
        TestConstants.address = createWalletResult.getAddress();

        TextView mnemonic = findViewById(R.id.mnemonic);
        mnemonic.setText(String.join(" ", createWalletResult.getMnemonics()));
    }
}
