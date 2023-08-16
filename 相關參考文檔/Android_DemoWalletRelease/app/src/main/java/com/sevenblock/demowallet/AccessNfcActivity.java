package com.sevenblock.demowallet;

import android.app.PendingIntent;
import android.content.Intent;
import android.content.IntentFilter;
import android.nfc.FormatException;
import android.nfc.NdefMessage;
import android.nfc.NdefRecord;
import android.nfc.NfcAdapter;
import android.nfc.Tag;
import android.nfc.tech.Ndef;
import android.os.Build;
import android.os.Bundle;
import android.os.Parcelable;
import android.provider.Settings;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;

import com.sevenblock.walletsdk.hardware.nfc.reader.CardReader;
import com.sevenblock.walletsdk.wallet.SevenblockWallet;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;

public class AccessNfcActivity extends AppCompatActivity {

    private final static String NDEF_DOMAIN = "sevenblock";
    private final static String NDEF_DATA_TYPE = "wallet";

    public final static String EXTRA_PRIVATE_KEY = "extract.private.key";
    public final static String EXTRA_DEVICE_ID = "extract.device.id";
    public final static String EXTRA_ACTION = "extract.action";
    public final static String EXTRA_PASSWORD = "extract.password";
    public final static String EXTRA_OVERWRITE = "extract.overwrite";
    public final static int ACTION_WRITE_UNKNOWN = 0;
    public final static int ACTION_WRITE_PRIVATE_KEY = 1;
    public final static int ACTION_READ_PRIVATE_KEY = 2;
    public final static int ACTION_RESET_CARD = 3;

    private NfcAdapter mNfcAdapter;
    private PendingIntent pIntent;
    private byte[] tagId;
    private int action;
    private byte[] privateKey;
    private String password;
    private boolean overwrite = false;

    private SevenblockWallet mSevenblockWallet;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_access_nfc);
        Intent intent = getIntent();
        action = intent.getIntExtra(EXTRA_ACTION, ACTION_WRITE_UNKNOWN);
        overwrite = intent.getBooleanExtra(EXTRA_OVERWRITE, false);
        mSevenblockWallet = SevenblockWallet.shareInstance(this);
        if(action == ACTION_WRITE_UNKNOWN) {
            showErrorAndFinish("必须指定action");
            return;
        } else if(action == ACTION_WRITE_PRIVATE_KEY) {
            privateKey = intent.getByteArrayExtra(EXTRA_PRIVATE_KEY);
            if(privateKey == null) {
                showErrorAndFinish("必须指定private key");
                return;
            }
            password = intent.getStringExtra(EXTRA_PASSWORD);
            if(password == null) {
                showErrorAndFinish("必须指定password");
                return;
            }
        }
        initNfc();
    }

    private void initNfc(){
        mNfcAdapter = NfcAdapter.getDefaultAdapter(this);
        pIntent = PendingIntent.getActivity(this, 0,
                //在Manifest里或者这里设置当前activity启动模式，否则每次向阳NFC事件，activity会重复创建
                // 当然也要按照具体情况来，你设置成singleTask也不是不行，
                new Intent(this, getClass()).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
                //0);
                //PendingIntent.FLAG_ONE_SHOT);
                //PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
                PendingIntent.FLAG_MUTABLE);
    }

    private void readFromDevice(Intent intent) {
        try {
            Tag tag = getIntent().getParcelableExtra(NfcAdapter.EXTRA_TAG);
            if(tag == null) {
                throw new Exception("无效卡");
            }
            tagId = tag.getId();
            Log.i("FlashTestNFC--Tag", "tag id: " + TypeConversion.bytes2HexString(tagId));
            CardReader reader = CardReader.with(tag);
            if(reader == null) {
                throw new Exception("无效卡");
            }
            String data = reader.parse(tag);
            if(data == null) {
                throw new Exception("空白卡");
            }
            Log.i("FlashTestNFC--Tag", data);
            String[] dataArr = data.split(" ");
            if (dataArr.length == 0) {
                throw new Exception("卡片中没有钱包信息");
            }
            String payloadPairStr = dataArr[dataArr.length - 1];
            String[] payloadPair = payloadPairStr.split("=");
            if (payloadPair.length != 2) {
                throw new Exception("卡片中没有钱包信息");
            }
            byte[] privateKey = TypeConversion.hexString2Bytes(payloadPair[1]);
            Log.i("FlashTestNFC--PK:", TypeConversion.bytes2HexString(privateKey));
            Intent resultIntent = new Intent();
            resultIntent.putExtra(EXTRA_PRIVATE_KEY, privateKey);
            resultIntent.putExtra(EXTRA_DEVICE_ID, tagId);
            setResult(RESULT_OK, resultIntent);
            finish();
        } catch (Exception e) {
            showErrorAndFinish("读取失败:" + e.getMessage());
            e.printStackTrace();
        }
    }

    private void resetDevice(Intent intent) {
        try {
            Tag tag = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);
            if(tag == null) {
                throw new Exception("无效卡");
            }
            tagId = tag.getId();
            Log.i("FlashTestNFC--Tag", "tag id: " + TypeConversion.bytes2HexString(tagId));
            byte[] deviceSn = TypeConversion.hexString2Bytes("701001000000");
            byte[] encPrivateKey = mSevenblockWallet.encDeviceFactoryInfo(tagId, deviceSn);

            String str = TypeConversion.bytes2HexString(encPrivateKey);
            //writeNFCToTag(encPrivateKey, intent);

            Intent result = new Intent();
            result.putExtra(EXTRA_ACTION, action);
            setResult(RESULT_OK, intent);
            finish();
        } catch (Exception e) {
            showErrorAndFinish("写入失败:" + e.getMessage());
            e.printStackTrace();
        }
    }

    private void write2Device(Intent intent) {
        Log.i("FlashTestNFC", "onNewIntent");
        try {
            Tag tag = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);
            if(tag == null) {
                throw new Exception("无效卡");
            }
            tagId = tag.getId();
            Log.i("FlashTestNFC--Tag", "tag id: " + TypeConversion.bytes2HexString(tagId));
            CardReader reader = CardReader.with(tag);
            if(reader == null) {
                throw new Exception("无效卡");
            }
            String data = reader.parse(tag);
            if(data == null) {
                throw new Exception("空白卡");
            }
            Log.i("FlashTestNFC--Tag", data);
            String[] dataArr = data.split(" ");
            if (dataArr.length == 0) {
                throw new Exception("卡片信息错误");
            }
            String payloadPairStr = dataArr[dataArr.length - 1];
            String[] payloadPair = payloadPairStr.split("=");
            if (payloadPair.length != 2) {
                throw new Exception("卡片信息错误");
            }
            byte[] cardPayload = TypeConversion.hexString2Bytes(payloadPair[1]);
            Log.i("FlashTestNFC--Tag", TypeConversion.bytes2HexString(cardPayload));
            byte[] encPrivateKey = mSevenblockWallet.encPrivateKey(tagId, cardPayload, privateKey, password, overwrite);

            //writeNFCToTag(encPrivateKey, intent);  //test:

            Intent result = new Intent();
            result.putExtra(EXTRA_ACTION, action);
            setResult(RESULT_OK, intent);
            finish();
        } catch (Exception e) {
            showErrorAndFinish("写入失败:" + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        //这里必须setIntent，set  NFC事件响应后的intent才能拿到数据
        setIntent(intent);
        switch (action) {
            case ACTION_READ_PRIVATE_KEY:
                readFromDevice(intent);
                break;
            case ACTION_WRITE_PRIVATE_KEY:
                write2Device(intent);
                break;
            case ACTION_RESET_CARD:
                resetDevice(intent);
                break;
            default:
                break;
        }
    }

    private void showErrorAndFinish(String error) {
        Toast.makeText(AccessNfcActivity.this, error, Toast.LENGTH_SHORT).show();
        finish();
    }

    /**
     * 往nfc写入数据
     */
    public static void writeNFCToTag(byte[] data, Intent intent) throws IOException, FormatException {
        Tag tag = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);
        Ndef ndef = Ndef.get(tag);
        ndef.connect();
        NdefRecord ndefRecord = NdefRecord.createExternal(NDEF_DOMAIN, NDEF_DATA_TYPE, data);
        NdefRecord[] records = {ndefRecord};
        NdefMessage ndefMessage = new NdefMessage(records);
        ndef.writeNdefMessage(ndefMessage);
    }

    @RequiresApi(api = Build.VERSION_CODES.P)
    public String readExtraData(Intent intent) throws UnsupportedEncodingException {
        Parcelable[] rawArray = intent.getParcelableArrayExtra(NfcAdapter.EXTRA_DATA);
        if (rawArray != null) {
            NdefMessage mNdefMsg = (NdefMessage) rawArray[0];
            NdefRecord mNdefRecord = mNdefMsg.getRecords()[0];
            if (mNdefRecord != null) {
                return new String(mNdefRecord.getPayload(), StandardCharsets.UTF_8);
            }
        }
        return "";
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.i("FlashTestNFC", "onResume");
        if (null == mNfcAdapter) {
            Toast.makeText(this, "不支持NFC功能", Toast.LENGTH_SHORT).show();
        } else if (!mNfcAdapter.isEnabled()) {
            Intent intent = new Intent(Settings.ACTION_NFC_SETTINGS);
            // 根据包名打开对应的设置界面
            startActivity(intent);
        }
        if (mNfcAdapter != null) {
            //添加intent-filter
            IntentFilter ndef = new IntentFilter(NfcAdapter.ACTION_NDEF_DISCOVERED);
            IntentFilter tag = new IntentFilter(NfcAdapter.ACTION_TAG_DISCOVERED);
            IntentFilter tech = new IntentFilter(NfcAdapter.ACTION_TECH_DISCOVERED);
            IntentFilter[] filters = new IntentFilter[]{ndef, tag, tech};

            //添加 ACTION_TECH_DISCOVERED 情况下所能读取的NFC格式，这里列的比较全，实际我这里是没有用到的，因为测试的卡是NDEF的
            String[][] techList = new String[][]{
                    new String[]{
                            "android.nfc.tech.Ndef",
                            "android.nfc.tech.NfcA",
                            "android.nfc.tech.NfcB",
                            "android.nfc.tech.NfcF",
                            "android.nfc.tech.NfcV",
                            "android.nfc.tech.NdefFormatable",
                            "android.nfc.tech.MifareClassic",
                            "android.nfc.tech.MifareUltralight",
                            "android.nfc.tech.NfcBarcode"
                    }
            };
            mNfcAdapter.enableForegroundDispatch(this, pIntent, filters, techList);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.i("FlashTestNFC", "onPause");
        if (mNfcAdapter != null) {
            mNfcAdapter.disableForegroundDispatch(this);
        }
    }
}
