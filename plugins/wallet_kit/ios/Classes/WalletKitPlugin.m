#import "WalletKitPlugin.h"
#import "WalletManaegr.h"

WalletManaegr *manager;

@implementation WalletKitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"wallet_kit" binaryMessenger:[registrar messenger]];
  WalletKitPlugin* instance = [[WalletKitPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    
   manager = [WalletManaegr shareManager];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    NSLog(@"btc地址=%@\n,私钥=%@\n,助记词=%@",@"address",@"privateKey",@"mnemonics");
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"create_wallet" isEqualToString:call.method]) {
    [self createWallet:call result:result];
  } else if ([@"import_wallet_key" isEqualToString:call.method]) {
      [self importWalletKey:call result:result];
  } else if ([@"import_wallet_mnemonics" isEqualToString:call.method]) {
      [self importWalletMnemonics:call result:result];
  } else if ([@"transaction_sign_btc" isEqualToString:call.method]) {
      [self transactionSign:call result:result];
  } else if ([@"transaction_sign_eth" isEqualToString:call.method]) {
      [self transactionSign:call result:result];
  } else if ([@"enc_private_key" isEqualToString:call.method]) {
      [self encPrivateKey:call result:result];
  } else if ([@"enc_dev_info" isEqualToString:call.method]) {
      [self encDeviceFactoryInfo:call result:result];
  } else if ([@"other" isEqualToString:call.method]) {
      //handleMethod(call, result);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

-(void)createWallet:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (manager == nil) return;
    NSNumber *boolTure = [NSNumber numberWithBool:YES];

    bool isBtc = (NSNumber*)call.arguments[@"isBtc"] == boolTure;
    bool isMainNet = (NSNumber*)call.arguments[@"isMainNet"] == boolTure;
    NSString *psw = call.arguments[@"psw"];

    CoinType coinType = isBtc ? CoinTypeBTC : CoinTypeETH;
    [manager createWalletWith:coinType password:psw isMainNet:isMainNet resultBlock:^(NSString *privateKey, NSString *address, NSString *mnemonics) {

        NSDictionary *reData = @{
                    @"privateKey": privateKey,
                    @"address": address,
                    @"mnemonics": mnemonics,
                    @"result": @"ok",
                };

        result(reData);
    }];
}

-(void)importWalletKey:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (manager == nil) return;
    NSNumber *boolTure = [NSNumber numberWithBool:YES];

    bool isBtc = (NSNumber*)call.arguments[@"isBtc"] == boolTure;
    bool isMainNet = (NSNumber*)call.arguments[@"isMainNet"] == boolTure;
    NSString *psw = call.arguments[@"psw"];
    NSString *privateKey = call.arguments[@"prvKeyStr"];
    NSString *deviceId = call.arguments[@"devIdStr"];

    @try {
        CoinType coinType = isBtc ? CoinTypeBTC : CoinTypeETH;
        [manager importWalletByPrivateKey:privateKey type:coinType password:psw isMainNet:isMainNet deviceId:deviceId resultBlock:^(NSString * _Nonnull address, BOOL isCorrect) {
            if(isCorrect){
                NSLog(@"eth地址=%@\n",address);
                NSDictionary *reData = @{@"address": address, @"result": @"ok"};
                result(reData);
            } else {
                NSDictionary *reData = @{@"result": @"密码错误"};
                result(reData);
            }
        }];
    } @catch (NSException * e) {
        NSDictionary *reData = @{@"result": e.description};
        if(privateKey.length == 20) reData = @{@"result": @"空钱包, 导入错误!"};
        result(reData);
    }
}
-(void)importWalletMnemonics:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (manager == nil) return;
    NSNumber *boolTure = [NSNumber numberWithBool:YES];

    bool isBtc = (NSNumber*)call.arguments[@"isBtc"] == boolTure;
    bool isMainNet = (NSNumber*)call.arguments[@"isMainNet"] == boolTure;
    NSString *psw = call.arguments[@"psw"];
    NSArray *mnemonics = call.arguments[@"mnemonics"];

    NSString *mnemonicStr = [mnemonics componentsJoinedByString:@" "];

    @try {
        CoinType coinType = isBtc ? CoinTypeBTC : CoinTypeETH;
        [manager importWalletByMnemonic:mnemonicStr type:coinType password:psw isMainNet:isMainNet resultBlock:^(NSString * _Nonnull privateKey, NSString * _Nonnull address) {
            NSLog(@"eth地址=%@\n,私钥=%@",address,privateKey);

            NSDictionary *reData = nil;
            if (address == nil || privateKey == nil || address.length == 0 || privateKey.length == 0 ) {
                reData = @{@"result": @"助记词错误"};
            } else {
                reData = @{@"privateKey": privateKey, @"address": address, @"result": @"ok"};
            }

            result(reData);
        }];
    } @catch (NSException * e) {
        //e.printStackTrace();
        NSDictionary *reData = @{@"result": e.description};
        result(reData);
    }
}

-(void)transactionSign:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (manager == nil) return;
    NSNumber *boolTure = [NSNumber numberWithBool:YES];

    bool isBtc = (NSNumber*)call.arguments[@"isBtc"] == boolTure;
    bool isMainNet = (NSNumber*)call.arguments[@"isMainNet"] == boolTure;
    NSString *psw = call.arguments[@"psw"];
    NSString *address = call.arguments[@"address"];
    NSString *privateKey = call.arguments[@"prvKeyStr"];
    NSString *deviceId = call.arguments[@"devIdStr"];

    NSDictionary *reData = nil;
    if (isBtc) {
      //btc   Long.parseLong();
      NSNumber *changeIdx = (NSNumber*)call.arguments[@"changeIdx"];
      NSString *amount = call.arguments[@"amount"];
      NSString *fee = call.arguments[@"fee"];
      NSArray<NSDictionary*>* utxo = call.arguments[@"utxo"];
      reData = [self btcSign:isBtc isMainNet:isMainNet psw:psw address:address privateKey:privateKey deviceId:deviceId changeIdx:changeIdx amount:amount fee:fee utxoList:utxo];
    } else {
      //eth
      NSString *nonce = call.arguments[@"nonce"];
      NSString *gasPrice = call.arguments[@"gasPrice"];
      NSString *gasLimit = call.arguments[@"gasLimit"];
      NSString *to = call.arguments[@"to"];
      NSString *value = call.arguments[@"value"];
      NSString *data = call.arguments[@"data"];
      reData = [self ethSign:isBtc isMainNet:isMainNet psw:psw privateKey:privateKey deviceId:deviceId nonce:nonce gasPrice:gasPrice gasLimit:gasLimit to:to value:value data:data];
    }

   result(reData);
}

-(NSDictionary *) ethSign:(bool)isBtc isMainNet:(bool)isMainNet psw:(NSString*)psw privateKey:(NSString*)privateKey deviceId:(NSString*)deviceId nonce:(NSString*)nonce gasPrice:(NSString*)gasPrice gasLimit:(NSString*)gasLimit to:(NSString*)to value:(NSString*)value data:(NSString*)data {
    __block NSDictionary *reData = nil;

    @try {
        STransaction * trans = [[STransaction alloc]init];
        trans.nonce = [nonce longLongValue];
        trans.gasPrice = [gasPrice longLongValue];
        trans.gasLimit = [gasLimit longLongValue];
        trans.toAddress = to;
        trans.value = [value longLongValue];
        trans.chainId = 1;  //android "1"

        NSLog(@"1.## Eth=> password = %@, deviceId = %@, privateKey = %@", psw, deviceId, privateKey);
        
        CoinType coinType = isBtc ? CoinTypeBTC : CoinTypeETH;
        [manager signTransaction:trans type:coinType password:psw deviceId:deviceId PrivateKey:privateKey isMainNet:isMainNet resultBlock:^(NSData * _Nonnull signtureData, BOOL isCorrect) {
            if (isCorrect) {
                NSString *signedTx = [self convertDataToHexStr:signtureData];
                NSLog(@"交易数据 = %@", signedTx);
                reData = @{
                    @"SignedTx": signedTx,
                    //@"TxHash": result.getTxHash(),
                    //@"WtxID": result.getWtxID(),
                    @"result": @"ok",
                };
            } else {
                NSLog(@"交易数据获取失败，请通知SDK作者");
                reData = @{@"result": @"signed data is wrong."};
            }
        }];

    } @catch (NSException * e) {
      //e.printStackTrace();
        reData = @{@"result": e.description};
    }

    return reData;
}

-(NSDictionary *) btcSign:(bool)isBtc isMainNet:(bool)isMainNet psw:(NSString*)psw address:(NSString*)address privateKey:(NSString*)privateKey deviceId:(NSString*)deviceId changeIdx:(NSNumber*)changeIdx amount:(NSString*)amount fee:(NSString*)fee utxoList:(NSArray<NSDictionary*>*)utxoList {
    __block NSDictionary *reData = nil;

    @try {
        //NSArray *mUtxo = [[NSArray alloc] init];
        NSMutableArray *mUtxo = [NSMutableArray array];
        NSNumber *vout; NSNumber *amountItem;
        NSString *txHash, *addressItem, *scriptPubKey;
        for (NSDictionary* utxoItem in utxoList) {
            txHash = (NSString*) utxoItem[@"txHash"];
            vout = (NSNumber*)utxoItem[@"vout"];
            amountItem = (NSNumber*)utxoItem[@"amount"]; //注意: long
            addressItem = (NSString*)utxoItem[@"address"];
            scriptPubKey = (NSString*)utxoItem[@"scriptPubKey"];
            NSLog(@"1.btcSign => txHash=%@\n,vout=%@\n,amountItem=%@\n,addressItem=%@\n,scriptPubKey=%@",txHash,vout,amountItem,addressItem,scriptPubKey);

            //[mUtxo arrayByAddingObject:utxoItem];
            NSString *amountStr = [NSString stringWithFormat:@"%@",amountItem];
            NSDictionary *mData = @{@"txHash": txHash, @"vout": vout, @"value": amountStr, @"address": addressItem, @"scriptPubKey": scriptPubKey};
            //[mUtxo arrayByAddingObject: mData];
            [mUtxo addObject: mData];
        }
        NSLog(@"1.## mUtxo_size = %lu",(unsigned long)mUtxo.count);
        
        STransaction * trans = [[STransaction alloc]init];
        trans.amount = [amount longLongValue];
        trans.fee = [fee longLongValue];
        trans.toAddress = address;
        trans.chainId = 0;  //android "0"
        trans.uxtoArray = mUtxo; //mUtxo;  utxoList

        NSLog(@"2.## Btc = > password = %@, deviceId = %@, privateKey = %@", psw, deviceId, privateKey);
        NSLog(@"3.## STransaction: trans.amount = %lld, trans.fee = %lld, trans.toAddress = %@, trans.uxtoArray = %@", trans.amount, trans.fee, trans.toAddress, trans.uxtoArray);

        CoinType coinType = isBtc ? CoinTypeBTC : CoinTypeETH;
        [manager signTransaction:trans type:coinType password:psw deviceId:deviceId PrivateKey:privateKey isMainNet:isMainNet resultBlock:^(NSData * _Nonnull signtureData, BOOL isCorrect) {
            if (isCorrect) {
                NSString *signedTx = [self convertDataToHexStr:signtureData];
                NSLog(@"交易数据 = %@", signedTx);
                reData = @{
                    @"SignedTx": signedTx,
                    //@"TxHash": result.getTxHash(),
                    //@"WtxID": result.getWtxID(),
                    @"result": @"ok",
                };
            } else {
                NSLog(@"交易数据获取失败，请通知SDK作者");
                reData = @{@"result": @"signed data is wrong."};
            }
        }];

    } @catch (NSException * e) {
        reData = @{@"result": e.description};
    }

    return reData;
}


-(void)encPrivateKey:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (manager == nil) return;
    NSNumber *boolTure = [NSNumber numberWithBool:YES];
    
    bool overwrite = (NSNumber*)call.arguments[@"overwrite"] == boolTure;
    NSString *tagId = call.arguments[@"tagId"];
    NSString *cardPayload = call.arguments[@"cardPayload"];
    //final byte[] privateKey = call.argument("privateKey");
    NSString *privateKey = call.arguments[@"privateKey"];
    NSString *psw = call.arguments[@"psw"];
    NSLog(@"1.encPrivateKey => tagId=%@",tagId);

    NSDictionary *reData = nil;
    NSString *deviceSnNum = @"701001000000";//设备SN号为12位
    NSData *encPrivateKey = [manager encryptPrivateKey:privateKey deviceId:tagId password:psw deviceSnNum:deviceSnNum];
    reData = @{@"encPrivateKey": encPrivateKey, @"result": @"ok"};

    result(reData);
}

-(void)encDeviceFactoryInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (manager == nil) return;

    NSString *tagId = call.arguments[@"tagId"];
    NSString *deviceSn = call.arguments[@"deviceSn"];   //@"701001000000";//设备SN号为12位
    NSString *privateKey = @"00013B15675324A851B0";     // @"00013B15675324A851B0"
    NSLog(@"1.encDeviceFactoryInfo => tagId=%@, deviceSn=%@", tagId, deviceSn);

    NSData *encData = [manager encryptPrivateKey:@"" deviceId:tagId password:@"" deviceSnNum:deviceSn];
    NSString *encAll= [self convertDataToHexStr:encData];
    if (encAll.length >= 20) {
      privateKey = [encAll substringToIndex:20];
    }
    NSLog(@"2.encDeviceFactoryInfo => encPrivateKey=%@", privateKey);
    NSData *encPrivateKey = [self convertHexStrToData:privateKey];

    result(encPrivateKey);
}



/** data转16进制 */
-(NSString *)convertDataToHexStr:(NSData *)data{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

/// 16进制字符串转data
/// - Parameter str: 16进制字符串
- (NSData *)convertHexStrToData:(NSString *)str{
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];

        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];

        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

-(NSString *)getTwoByte:(NSString *)str{
    NSString *result = @"";
    if(str.length == 2){
        result = [NSString stringWithFormat:@"00%@",str];
    }else if (str.length == 3){
        result = [NSString stringWithFormat:@"0%@",str];
    }else{
        result = str;
    }
    return result;
}

@end
