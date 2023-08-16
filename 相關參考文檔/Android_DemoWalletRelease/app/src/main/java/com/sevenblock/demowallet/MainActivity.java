package com.sevenblock.demowallet;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.widget.RadioGroup;
import android.widget.Toast;

public class MainActivity extends AppCompatActivity  {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        setListener();

        findViewById(R.id.create_wallet).setOnClickListener((view) -> {
            startActivity(new Intent(MainActivity.this, CreateWalletActivity.class));
        });
        findViewById(R.id.import_from_mnemonics).setOnClickListener((view) -> {
            startActivity(new Intent(MainActivity.this, ImportFromMnemonicActivity.class));
        });
        findViewById(R.id.transaction).setOnClickListener((view) -> {
            if(TestConstants.testBtc) {
                startActivity(new Intent(MainActivity.this, BtcTransactionActivity.class));
            } else {
                startActivity(new Intent(MainActivity.this, EthTransactionActivity.class));
            }
        });
        findViewById(R.id.import_from_device).setOnClickListener((view) -> {
            startActivity(new Intent(MainActivity.this, ImportFromDeviceActivity.class));
        });
        ActivityResultLauncher<Intent> intentActivityResultLauncher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(), result -> {
            int resultCode = result.getResultCode();
            if (resultCode == RESULT_OK) {
                Toast.makeText(MainActivity.this, "重置设备成功", Toast.LENGTH_SHORT).show();
            }
        });
        findViewById(R.id.reset_device).setOnClickListener((view) -> {
            Intent intent = new Intent(MainActivity.this, AccessNfcActivity.class);
            intent.putExtra(AccessNfcActivity.EXTRA_ACTION, AccessNfcActivity.ACTION_RESET_CARD);
            intentActivityResultLauncher.launch(intent);
        });
    }

    private void setListener() {
        ((RadioGroup)findViewById
                (R.id.coinTypeGroup)).setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                TestConstants.setTestBtc(checkedId == R.id.btc);
            }
        });
        ((RadioGroup)findViewById
                (R.id.netGroup)).setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                TestConstants.setMainNet(checkedId == R.id.main);
            }
        });
    }
}