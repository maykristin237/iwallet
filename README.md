# iwallet

#### 介紹
一款跨平臺的區塊鏈數位資產管理工具的app,提供數位資產管理服務。  
加入NFC功能模組，為使用者提供了簡單便捷、安全可靠的數位貨幣資產服務管理。  

#### 軟體模組
創建--類型--助記詞--NFC寫入儲存--主頁  
導入--私密金鑰導入--NFC讀取--主頁  
  --助記詞導入--輸入肋記詞--NFC寫入儲存--主頁  

主頁--資產--資產列表--轉帳--收款  
  --我的--交易記錄--回饋--重置--語言切換--關於  

#### 工具包

1.  Flutter 3.10.6
2.  Dart 3.0.6
3.  DevTools 2.23.1

### 協力廠商框架

| 庫                           | 功能                |
| --------------------------   | --------------      |
| **dio**                      | **網路框架**        |
| **shared_preferences**       | **本地數據緩存**    |
| **flutter_redux**            | **redux**           |
| **device_info**              | **設備資訊**        |
| **connectivity**             | **網路連結**        |
| **flutter_markdown**         | **markdown解析**    |
| **url_launcher**             | **啟動外部流覽器**  |
| **nfc_manager**              | **nfc管理工具**     |
| **path_provider**            | **本地路徑**        |
| **permission_handler**       | **許可權**          |
| **qr_flutter**               | **狀態管理和共用**  |
| **multi_image_picker_view**  | **圖片獲取**        |
| **flutter_spinkit**          | **載入框樣式**      |

#### 相關介面

1.  創建錢包  
    Future<dynamic> createWallet(bool isBtc, bool isMainNet, String psw) {  
       return WalletKitPlatform.instance.createWallet(  
        isBtc: isBtc,  
        isMainNet: isMainNet,  
        psw: psw);  
    }  
3.  私密金鑰導入錢包 var bytes = utf8.encode(password);  
    Future<dynamic> importWalletByPrivateKey(bool isBtc, bool isMainNet, String psw, List<int> privateKey, List<int> deviceId, String prvKeyStr, String devIdStr) {  
        return WalletKitPlatform.instance.importWalletByPrivateKey(
        isBtc: isBtc,  
        isMainNet: isMainNet,  
        psw: psw,  
        privateKey: privateKey,  
        deviceId: deviceId,  
        prvKeyStr: prvKeyStr,  
        devIdStr: devIdStr);  
    }  
5.  助記詞導入錢包  
    Future<dynamic> importWalletByMnemonic(bool isBtc, bool isMainNet, String psw, List<String> mnemonics) {  
        return WalletKitPlatform.instance.importWalletByMnemonic(isBtc: isBtc, isMainNet: isMainNet, psw: psw, mnemonics: mnemonics);  
    }  
6.  交易簽名 BTC需要address參數  utxo => String txHash, int vout, num amount, String address, String scriptPubKey, String derivedPath  
    Future<dynamic> transactionSignBtc(bool isBtc, bool isMainNet, String psw, String address, List<int> privateKey, List<int> deviceId, String prvKeyStr, String devIdStr,  
        int changeIdx, String amount, String fee, List<Map> utxo) {  
        return WalletKitPlatform.instance.transactionSignBtc(  
              isBtc: isBtc,  
              isMainNet: isMainNet,  
              psw: psw,  
              address: address,  
              privateKey: privateKey,  
              deviceId: deviceId,  
              prvKeyStr: prvKeyStr,  
              devIdStr: devIdStr,  
              changeIdx: changeIdx,  
              amount: amount,  
              fee: fee,  
              utxo: utxo);  
    }  
7.  交易簽名 ETH  
    Future<dynamic> transactionSignEth(bool isBtc, bool isMainNet, String psw, String address, List<int> privateKey, List<int> deviceId, String prvKeyStr, String devIdStr,  
        String nonce, String gasPrice, String gasLimit, String to, String value, String data) {  
        return WalletKitPlatform.instance.transactionSignEth(  
              isBtc: isBtc,  
              isMainNet: isMainNet,  
              psw: psw,  
              address: address,  
              privateKey: privateKey,  
              deviceId: deviceId,  
              prvKeyStr: prvKeyStr,  
              devIdStr: devIdStr,  
              nonce: nonce,  
              gasPrice: gasPrice,  
              gasLimit: gasLimit,  
              to: to,  
              value: value,  
              data: data);  
    }  
8.  創建錢包時用到 tagId, cardPayload, privateKey 需要16進制 Hex  
    Future<dynamic> encPrivateKey(String tagId, String cardPayload, String privateKey, String psw, bool overwrite, List<int> other) {  
        return WalletKitPlatform.instance.encPrivateKey(  
        tagId: tagId,  
        cardPayload: cardPayload,  
        privateKey: privateKey,  
        psw: psw, overwrite:  
        overwrite, other: other);  
    }  
10.  重置卡片時用到 tagId, deviceSn 需要16進制 Hex  
    Future<dynamic> encDeviceFactoryInfo(String tagId, String deviceSn) {  
        return WalletKitPlatform.instance.encDeviceFactoryInfo(tagId: tagId, deviceSn: deviceSn);  
    }  

#### 參與

1.  Fork 本倉庫
2.  新建 Feat 分支
3.  提交代碼
4.  新建 Pull Request


#### 特技

1.  使用 Readme\_XXX.md 來支援不同的語言，例如 Readme\_en.md, Readme\_zh.md
2.  官方博客 
3.  官方提供的使用手冊
