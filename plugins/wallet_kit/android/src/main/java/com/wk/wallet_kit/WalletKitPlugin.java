package com.wk.wallet_kit;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.sevenblock.walletsdk.constant.ChainId;
import com.sevenblock.walletsdk.constant.CoinType;
import com.sevenblock.walletsdk.result.CreateWalletResult;
import com.sevenblock.walletsdk.result.ImportWalletByMnemonicResult;
import com.sevenblock.walletsdk.result.ImportWalletByPrivateKeyResult;
import com.sevenblock.walletsdk.result.TxSignResult;
import com.sevenblock.walletsdk.wallet.BitcoinTransaction;
import com.sevenblock.walletsdk.wallet.EthereumTransaction;
import com.sevenblock.walletsdk.wallet.SevenblockWallet;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** WalletKitPlugin */
public class WalletKitPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context appContext;
  private Activity activity;

  private SevenblockWallet mSevenblockWallet;
  private CreateWalletResult createWalletResult;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    Log.d("Tracker", "### init onAttachedToEngine");

    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "wallet_kit");
    channel.setMethodCallHandler(this);
    appContext = flutterPluginBinding.getApplicationContext();

    //第三方包模块:
    mSevenblockWallet = SevenblockWallet.shareInstance(appContext);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    //Log.d("Tracker", "onMethodCall: "+ call.method);
    String action;
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "create_wallet":
        createWallet(call, result);
        break;
      case "import_wallet_key":
        importWalletKey(call, result);
        break;
      case "import_wallet_mnemonics":
        importWalletMnemonics(call, result);
        break;
      case "transaction_sign_btc":
        transactionSign(call, result);
        break;
      case "transaction_sign_eth":
        transactionSign(call, result);
        break;
      case "enc_private_key":
        encPrivateKey(call, result);
        break;
      case "enc_dev_info":
        encDeviceFactoryInfo(call, result);
        break;
      case "other":
        handleMethod();
        break;
      default:
        result.notImplemented();
    }
  }

  private void createWallet(MethodCall call, Result result) {
    if (mSevenblockWallet == null) return;

    final boolean isBtc = Boolean.TRUE.equals(call.argument("isBtc"));
    final boolean isMainNet = Boolean.TRUE.equals(call.argument("isMainNet"));
    final String psw = call.argument("psw");

    Map<String, String> reData = new HashMap<>();
    try {
      createWalletResult = mSevenblockWallet.createWalletWithPath(getCoinType(isBtc), isMainNet, psw);

      String privateKey = bytesToHexStr(createWalletResult.getPrivateKey());
      String address = createWalletResult.getAddress();
      String mnemonics = String.join(" ", createWalletResult.getMnemonics());

      reData.put("privateKey", privateKey);
      reData.put("address", address);
      reData.put("mnemonics", mnemonics);
      reData.put("result", "ok");

    } catch (Exception e) {
      e.printStackTrace();
      reData.put("result", e.getMessage());
    }

    //channel.invokeMethod("onEventCall", reData);
    result.success(reData);
  }

  private void importWalletKey(MethodCall call, Result result) {
    if (mSevenblockWallet == null) return;

    final boolean isBtc = Boolean.TRUE.equals(call.argument("isBtc"));
    final boolean isMainNet = Boolean.TRUE.equals(call.argument("isMainNet"));
    final String psw = call.argument("psw");
    final byte[] privateKey = call.argument("privateKey");
    final byte[] deviceId = call.argument("deviceId");

    Map<String, String> reData = new HashMap<>();
    try {
      ImportWalletByPrivateKeyResult importResult = mSevenblockWallet.importWalletByPrivateKey(getCoinType(isBtc), isMainNet, privateKey, psw, deviceId);
      //String privateKey = bytesToHexStr(createWalletResult.getPrivateKey());
      String address = importResult.getAddress();
      reData.put("address", address);
      reData.put("result", "ok");

    } catch (Exception e) {
      e.printStackTrace();
      reData.put("result", e.getMessage());
    }

    result.success(reData);
  }

  private void importWalletMnemonics(MethodCall call, Result result) {
    if (mSevenblockWallet == null) return;

    final boolean isBtc = Boolean.TRUE.equals(call.argument("isBtc"));
    final boolean isMainNet = Boolean.TRUE.equals(call.argument("isMainNet"));
    final String psw = call.argument("psw");
    final List<String> mnemonics = call.argument("mnemonics");
    //Log.d("Tracker", "1.importWalletMnemonics => coinType="+ coinType + ", isMainNet="+isMainNet+ ", psw="+psw);

    Map<String, String> reData = new HashMap<>();
    try {
      ImportWalletByMnemonicResult importResult = mSevenblockWallet.importWalletByMnemonic(getCoinType(isBtc), mnemonics, isMainNet, psw);
      String privateKey = bytesToHexStr(importResult.getPrivateKey());
      String address = importResult.getAddress();

      reData.put("privateKey", privateKey);
      reData.put("address", address);
      reData.put("result", "ok");

    } catch (Exception e) {
      e.printStackTrace();
      reData.put("result", e.getMessage());
    }

    //channel.invokeMethod("onEventCall", reData);
    result.success(reData);
  }

  private void encPrivateKey(MethodCall call, Result result) {
    if (mSevenblockWallet == null) return;

    final boolean overwrite = Boolean.TRUE.equals(call.argument("overwrite"));
    final String tagId = call.argument("tagId");
    final String cardPayload = call.argument("cardPayload");
    //final byte[] privateKey = call.argument("privateKey");
    final String privateKey = call.argument("privateKey");
    final String psw = call.argument("psw");
    //final byte[] other = call.argument("other");
    //Log.d("Tracker", "## 1.Android => other = "+ bytesToHexStr(other) + ", arr = " + java.util.Arrays.toString(other) );

    Map<String, Object> reData = new HashMap<>();
    try {
      //boolean overwrite = true;
      byte[] encPrivateKey = mSevenblockWallet.encPrivateKey(hexStrToBytes(tagId), hexStrToBytes(cardPayload), hexStrToBytes(privateKey), psw, overwrite);
      reData.put("encPrivateKey", encPrivateKey);
      reData.put("result", "ok");
      Log.d("Tracker", "## 2.Android => encPrivateKey = " + bytesToHexStr(encPrivateKey));
    } catch (Exception e) {
      e.printStackTrace();
      reData.put("result", e.getMessage());
    }
    result.success(reData);
  }

  private void encDeviceFactoryInfo(MethodCall call, Result result) {
    if (mSevenblockWallet == null) return;

    //final boolean isBtc = Boolean.TRUE.equals(call.argument("isBtc"));
    final String tagId = call.argument("tagId");
    final String deviceSn = call.argument("deviceSn");

    byte[] encPrivateKey = null;
    try {
      encPrivateKey = mSevenblockWallet.encDeviceFactoryInfo(hexStrToBytes(tagId), hexStrToBytes(deviceSn));
    } catch (Exception e) {
      e.printStackTrace();
    }
    result.success(encPrivateKey);
  }

  private void transactionSign(MethodCall call, Result result) {
    if (mSevenblockWallet == null) return;

    final boolean isBtc = Boolean.TRUE.equals(call.argument("isBtc"));
    final boolean isMainNet = Boolean.TRUE.equals(call.argument("isMainNet"));
    final String psw = call.argument("psw");
    final String address = call.argument("address");
    final byte[] privateKey = call.argument("privateKey");
    final byte[] deviceId = call.argument("deviceId");
    //Log.d("Tracker", "1.create_wallet => coinType="+ coinType + ", isMainNet="+isMainNet+ ", psw="+psw);

    Map<String, String> reData = null;
    if (isBtc) {
      //btc
      final int changeIdx = call.argument("changeIdx");
      final long amount = Long.parseLong(call.argument("amount"));
      final long fee = Long.parseLong(call.argument("fee"));
      final List<Map<String, Object>> utxo = call.argument("utxo");
      reData = btcSign(isBtc, isMainNet, psw, address, privateKey, deviceId, changeIdx, amount, fee, utxo);
    } else {
      //eth
      final long nonce = Long.parseLong(call.argument("nonce"));
      final long gasPrice = Long.parseLong(call.argument("gasPrice"));
      final long gasLimit = Long.parseLong(call.argument("gasLimit"));
      final String to = call.argument("to");
      final long value = Long.parseLong(call.argument("value"));
      final String data = call.argument("data");
      reData = ethSign(isBtc, isMainNet, psw, privateKey, deviceId, nonce, gasPrice, gasLimit, to, value, data);
    }

    //channel.invokeMethod("onEventCall", reData);
    result.success(reData);
  }

  private Map<String, String> ethSign(boolean isBtc, boolean isMainNet, String psw, byte[] privateKey, byte[] deviceId, long nonce, long gasPrice, long gasLimit, String to, long value, String data) {
    Map<String, String> reData = new HashMap<>();

    try {
      EthereumTransaction ethTx = new EthereumTransaction(
              BigInteger.valueOf(nonce),
              BigInteger.valueOf(gasPrice),
              BigInteger.valueOf(gasLimit),
              to,
              BigInteger.valueOf(value),
              data
      );

      TxSignResult result = ethTx.signTransaction(mSevenblockWallet,
              getCoinType(isBtc),
              isMainNet,
              privateKey,
              psw,
              getChainId(isBtc, isMainNet),
              deviceId);
      //Log.e(TAG, "transaction.signTransaction: " + result);

      reData.put("SignedTx", result.getSignedTx());
      reData.put("TxHash", result.getTxHash());
      reData.put("WtxID", result.getWtxID());
      reData.put("result", "ok");

    } catch (Exception e) {
      e.printStackTrace();
      reData.put("result", e.getMessage());
    }

    return reData;
  }

  private Map<String, String> btcSign(boolean isBtc, boolean isMainNet, String psw, String address, byte[] privateKey, byte[] deviceId, int changeIdx, long amount, long fee, List<Map<String, Object>> utxoList) {
    Map<String, String> reData = new HashMap<>();

    try {
      //BitcoinTransaction transaction = createMultiUXTOOnTestnet(address);
      ArrayList<BitcoinTransaction.UTXO> mUtxo = new ArrayList<>();
      int vout; long amountItem;
      String txHash, addressItem, scriptPubKey;
      for ( Map<String, Object> utxoItem : utxoList) {
        txHash = (String) utxoItem.get("txHash");
        vout = (int)utxoItem.get("vout");
        amountItem = Long.parseLong(utxoItem.get("amount")+"");
        addressItem = (String) utxoItem.get("address");
        scriptPubKey = (String) utxoItem.get("scriptPubKey");
        mUtxo.add(new BitcoinTransaction.UTXO(txHash, vout, amountItem, addressItem, scriptPubKey, ""));
      }
      BitcoinTransaction transaction = new BitcoinTransaction(address, changeIdx, amount, fee, mUtxo);

      TxSignResult result = transaction.signTransaction(mSevenblockWallet,
              getCoinType(isBtc),
              isMainNet,
              privateKey,
              psw,
              getChainId(isBtc, isMainNet),
              deviceId);
      //Log.e(TAG, "transaction.signTransaction: " + result);

      reData.put("SignedTx", result.getSignedTx());
      reData.put("TxHash", result.getTxHash());
      reData.put("WtxID", result.getWtxID());
      reData.put("result", "ok");

    } catch (Exception e) {
      e.printStackTrace();
      reData.put("result", e.getMessage());
    }

    return reData;
  }

  private String getChainId(boolean isBtc, boolean mainNet) {
    return isBtc ? (mainNet ? ChainId.BITCOIN_MAINNET : ChainId.BITCOIN_TESTNET)
            : ChainId.ETHEREUM_MAINNET;
  }

  private String getCoinType(boolean isBtc) {
    return isBtc ? CoinType.BITCOIN : CoinType.ETHEREUM;
  }

  private String bytesToHexStr(byte[] b) {
    if (b == null) {
      return "";
    }
    StringBuilder rs = new StringBuilder();
    int bl = b.length;
    byte bt;
    String bts = "";
    int btsl;
    for (byte value : b) {
      bt = value;
      bts = Integer.toHexString(bt);
      btsl = bts.length();
      if (btsl > 2) {
        bts = bts.substring(btsl - 2).toUpperCase();
      } else if (btsl == 1) {
        bts = "0" + bts.toUpperCase();
      } else {
        bts = bts.toUpperCase();
      }
      rs.append(bts);
    }
    return rs.toString();
  }

  private byte[] hexStrToBytes(String src) {
    int l = src.length() / 2;
    byte[] ret = new byte[l];
    for (int i = 0; i < l; i++) {
      ret[i] = (byte) Integer.valueOf(src.substring(i * 2, i * 2 + 2), 16).byteValue();
    }
    return ret;
  }

  private void handleMethod() {

  }



  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    Log.d("Tracker", "## onDetachedFromEngine");
    channel.setMethodCallHandler(null);
    channel = null;
    appContext = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    Log.d("Tracker", "onAttachedToActivity");

    activity = binding.getActivity();
    if(activity != null) Log.d("Tracker", "activity!=null");

  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }

}
