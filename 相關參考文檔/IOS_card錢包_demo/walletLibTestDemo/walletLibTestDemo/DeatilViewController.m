//
//  DeatilViewController.m
//  WalletOCDemo
//
//  Created by 七块 on 2023/3/10.
//

#import "DeatilViewController.h"
#import "WalletManaegr.h"
#import "HUDTool.h"
#import <NFCReaderWriter.h>

static NSString *password = @"666666";

@interface DeatilViewController ()<NFCReaderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *address;

@property (weak, nonatomic) IBOutlet UILabel *mnemonicPhrase;

@property (weak, nonatomic) IBOutlet UILabel *privateKey;

@property (nonatomic,strong) NFCReaderWriter *readerWriter;

@property (nonatomic,strong) WalletManaegr *manager;

@property (nonatomic,strong) NSData *seedData;

@property (nonatomic,strong) NSString *deviceTagID;
///恢复按钮
@property (weak, nonatomic) IBOutlet UIButton *recoverButton;
///导入按钮
@property (weak, nonatomic) IBOutlet UIButton *outputButton;
///卡片中是否有数据
@property (nonatomic,assign) BOOL hasDataInCrad;
///临时私钥
@property (nonatomic,copy) NSString *tempPrivateKey;

@end

@implementation DeatilViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.readerWriter = [NFCReaderWriter sharedInstance];
    self.manager = [WalletManaegr shareManager];
    NSString *title = @"功能";
    switch (self.type) {
        case FuncTypeCreateBtc:
            title = @"创建BTC钱包";
            [self createBtc];
            self.recoverButton.hidden = YES;
            self.outputButton.hidden = NO;
            break;
        case FuncTypeMonInputBtc:
            title = @"助记词导入BTC";
            [self inputMnemonicBTC];
            self.recoverButton.hidden = YES;
            self.outputButton.hidden = NO;
            break;
        case FuncTypepriKeyBtc:
            title = @"私钥导入BTC";
            self.recoverButton.hidden = NO;
            self.outputButton.hidden = YES;
            break;
        case FuncTypeSignBtc:
            title = @"BTC交易签名";
            self.recoverButton.hidden = NO;
            self.outputButton.hidden = YES;
            break;
        case FuncTypeCreateEth:
            title = @"创建ETH钱包";
            [self createETH];
            self.recoverButton.hidden = YES;
            self.outputButton.hidden = NO;
            break;
        case FuncTypeMoninputEth:
            title = @"助记词导入ETH";
            [self inputMnemonicETH];
            self.recoverButton.hidden = YES;
            self.outputButton.hidden = NO;
            break;
        case FuncTypepriKeyEth:
            title = @"私钥导入ETH";
            self.recoverButton.hidden = NO;
            self.outputButton.hidden = YES;
            break;
        case FuncTypesignEth:
            title = @"ETH交易签名";
            self.recoverButton.hidden = NO;
            self.outputButton.hidden = YES;
            break;
        default:
            break;
    }
    self.navigationItem.title = title;
}
///创建BTC
-(void)createBtc{
    [self.manager createWalletWith:CoinTypeBTC password:password isMainNet:YES resultBlock:^(NSString *privateKey, NSString *address, NSString *mnemonic) {
        NSLog(@"btc地址=%@\n,私钥=%@\n,助记词=%@",address,privateKey,mnemonic);
        self.tempPrivateKey = privateKey;
        /**
         btc地址=1PuRxvt7SxevDVhtn8Agxih9KD8Xi5icQd
         ,私钥=262c7ede58c62c6e155ebd23b25862a28536b523abe42cb5046205fce8adc2846c01ef80e36c73dbed30c31aa0602578565351035fef1685d3a3b1b00ca55890
         ,助记词=clever soldier aware common polar slogan object stone churn drum switch filter
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            self.address.text = address;
            self.mnemonicPhrase.text = mnemonic;
            self.privateKey.text = privateKey;
        });
    }];
}
///助记词导入BTC
-(void)inputMnemonicBTC{
    NSString *Mnemonic = @"clever soldier aware common polar slogan object stone churn drum switch filter";
    [self.manager importWalletByMnemonic:Mnemonic type:CoinTypeBTC password:password isMainNet:YES resultBlock:^(NSString * _Nonnull privateKey, NSString * _Nonnull address) {
        self.tempPrivateKey = privateKey;
        NSLog(@"btc地址=%@\n,私钥=%@",address,privateKey);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.address.text = address;
            self.mnemonicPhrase.text = Mnemonic;
            self.privateKey.text = privateKey;
            
        });
    }];
}
///私钥导入BTC
-(void)importPrivateKeyBTC:(NSString *)privateKey{
    NSString *deviceID = self.deviceTagID;///卡片的ID
    if(deviceID.length == 0){
        NSLog(@"请先获取的卡片ID");
        return;
    }
    [self.manager importWalletByPrivateKey:privateKey type:CoinTypeBTC password:password isMainNet:YES deviceId:deviceID resultBlock:^(NSString * _Nonnull address, BOOL isCorrect) {
        if(isCorrect){
            NSLog(@"btc地址=%@\n",address);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.address.text = address;
                self.privateKey.text = privateKey;
            });
        }else{
            NSLog(@"密码错误");
        }
    }];
}
///创建ETH
-(void)createETH{
    [self.manager createWalletWith:CoinTypeETH password:password isMainNet:NO resultBlock:^(NSString * _Nonnull privateKey, NSString * _Nonnull address, NSString * _Nonnull mnemonic) {
        NSLog(@"eth地址=%@\n,私钥=%@\n,助记词=%@",address,privateKey,mnemonic);
        self.tempPrivateKey = privateKey;
        /*
         eth地址=54531afd10730898ae9590d1a1ef8f5cf3fa96e9
         私钥=33cc889074a4e2e406f9f616c490244836986bedf241a878593baab4d5762f1832ebcf6535768dda1ae1bfa13d39e93ac7e2b2559dd8946532f2360c42171749
         助记词=tongue oak doctor friend absorb liar senior easily curtain stem ladder embark
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            self.address.text = address;
            self.mnemonicPhrase.text = mnemonic;
            self.privateKey.text = privateKey;
        });
    }];
}
///助记词导入ETH
-(void)inputMnemonicETH{
    NSString *Mnemonic = @"tongue oak doctor friend absorb liar senior easily curtain stem ladder embark";
    [self.manager importWalletByMnemonic:Mnemonic type:CoinTypeETH password:password isMainNet:NO resultBlock:^(NSString * _Nonnull privateKey, NSString * _Nonnull address) {
        self.tempPrivateKey = privateKey;
        NSLog(@"eth地址=%@\n,私钥=%@",address,privateKey);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.address.text = address;
            self.mnemonicPhrase.text = Mnemonic;
            self.privateKey.text = privateKey;
        });
    }];
}
///私钥导入ETH
-(void)importPrivateKeyETH:(NSString *)privateKey{
    NSString *deviceID = self.deviceTagID;///卡片的ID
    if(deviceID.length == 0){
        NSLog(@"请先获取的卡片ID");
        return;
    }
    [self.manager importWalletByPrivateKey:privateKey type:CoinTypeETH password:password isMainNet:NO deviceId:deviceID resultBlock:^(NSString * _Nonnull address, BOOL isCorrect) {
        if(isCorrect){
            NSLog(@"eth地址=%@\n",address);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.address.text = address;
                self.privateKey.text = privateKey;
            });
        }else{
            NSLog(@"密码错误");
        }
    }];
}

- (IBAction)OutputButtonClick:(UIButton *)sender {
    [self readTagInfo];//无论读取还是写入都要先获取到卡片ID
}

- (IBAction)readCradMessage:(UIButton *)sender {
    [self readTagInfo];//无论读取还是写入都要先获取到卡片ID
}
-(void)readTagInfo{
    [self.readerWriter newWriterSessionWithDelegate:self isLegacy:NO invalidateAfterFirstRead:YES alertMessage:@"将卡片靠近手机"];
    [self.readerWriter begin];
    self.readerWriter.detectedMessage = @"监测到tag信息";
}
-(void)writeMessageToCrad{
    if(self.hasDataInCrad){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"卡片中有钱包数据，是否要覆盖" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self writeData];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }];
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self writeData];
    }
}
-(void)writeData{
    [self.readerWriter newWriterSessionWithDelegate:self isLegacy:YES invalidateAfterFirstRead:NO alertMessage:@"将卡片靠近手机"];
    [self.readerWriter begin];
    self.readerWriter.detectedMessage = @"写入成功";
}
#pragma mark - NFCReaderDelegate
///当NFC读取器会话处于活动状态时调用。射频启用，阅读器正在扫描标签。
-(void)readerDidBecomeActive:(NFCReader *)session{
    NSLog(@"开始扫描");
}
-(void)reader:(NFCReader *)session didInvalidateWithError:(NSError *)error{
    NSLog(@"出错了=%@",error);
    [self.readerWriter end];
}
-(void)reader:(NFCReader *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages{
    [self.readerWriter end];
}
/////写入
-(void)reader:(NFCReader *)session didDetectTags:(NSArray<__kindof id<NFCNDEFTag>> *)tags{
    NSLog(@"开始写入");
    NSString *deviceSnNum = @"701000000099";//设备SN号为12位
    NSData *resultData = [self.manager encryptPrivateKey:self.tempPrivateKey deviceId:self.deviceTagID password:password deviceSnNum:deviceSnNum];
    NSData *typeData = [@"sevenblock:wallet" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *idData = [NSData data];
    NFCNDEFPayload *payLoad = [[NFCNDEFPayload alloc]initWithFormat:NFCTypeNameFormatNFCExternal type:typeData identifier:idData payload:resultData chunkSize:0];
    NSArray *array = [[NSArray alloc]initWithObjects:payLoad, nil];
    NFCNDEFMessage *message = [[NFCNDEFMessage alloc]initWithNDEFRecords:array];
    [self.readerWriter writeMessage:message toTag:tags.firstObject completion:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"写入出错=%@",error);
        }else{
            NSLog(@"写入成功");
        }
        [self.readerWriter end];
    }];
}
///读取
-(void)reader:(NFCReader *)session didDetectTag:(__kindof id<NFCTag>)tag didDetectNDEF:(NFCNDEFMessage *)message{
    NSData *tagId = [self.readerWriter tagIdentifierWithTag:tag];
    self.deviceTagID = [self convertDataToHexStr:tagId];
    [self.readerWriter end];
    NSLog(@"卡片ID = %@",tagId);
    NFCNDEFPayload *record = message.records.firstObject;
    if(record.payload.length != 90){///返回私钥数据是90个字节。如果不是，就认为卡片中没有数据获数据不对
        self.hasDataInCrad = NO;
        if(self.type == FuncTypepriKeyBtc || self.type == FuncTypeSignBtc || self.type == FuncTypepriKeyEth || self.type == FuncTypesignEth){
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUDTool showPromptWithString:@"卡片中没有数据哦~"];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self writeMessageToCrad];
            });
        }
    }else{
        self.hasDataInCrad = YES;
        if(self.type == FuncTypepriKeyBtc || self.type == FuncTypeSignBtc || self.type == FuncTypepriKeyEth || self.type == FuncTypesignEth){
            if(self.type == FuncTypepriKeyBtc){
                [self importPrivateKeyBTC:[self convertDataToHexStr:record.payload]];
            }else if (self.type == FuncTypepriKeyEth){
                [self importPrivateKeyETH:[self convertDataToHexStr:record.payload]];
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self writeMessageToCrad];
            });
        }
    }
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
@end
 
