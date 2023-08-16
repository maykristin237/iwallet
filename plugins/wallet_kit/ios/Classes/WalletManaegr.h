//
//  WalletManaegr.h
//  WalletOCDemo
//
//  Created by 七块 on 2023/3/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,CoinType){
    CoinTypeBTC,
    CoinTypeETH
};
///交易数据模型
@interface STransaction : NSObject
///ETH模型数据
@property (nonatomic,assign) int64_t gasLimit;
@property (nonatomic,assign) int64_t gasPrice;
@property (nonatomic,assign) int64_t nonce;
@property (nonatomic,assign) int64_t value;
@property (nonatomic,assign) NSInteger chainId;
///BTC模型数据
@property (nonatomic,strong) NSArray *uxtoArray;
@property (nonatomic,assign) int64_t amount;
@property (nonatomic,assign) int64_t fee;
///公共属性
@property (nonatomic,copy) NSString *toAddress;
@end

@interface WalletManaegr : NSObject

/** 单例 */
+(instancetype)shareManager;

/// 创建钱包
/// - Parameters:
///   - type: 币种类型
///   - password: 密码
///   - MainNet: 是否BTC主网络，ETH忽略,设置NO
///   - block: 回调结果--私钥，地址，助记词
-(void)createWalletWith:(CoinType)type
               password:(NSString *)password
              isMainNet:(BOOL)MainNet
            resultBlock:(void(^)(NSString *privateKey,NSString *address,NSString *mnemonic))block;
/// 通过助记词导入
/// - Parameters:
///   - mnemonic: 助记词
///   - type: 币种类型
///   - password: 密码
///   - MainNet: 是否BTC主网络，ETH忽略,设置NO
///   - block: 回调结果--私钥，地址
-(void)importWalletByMnemonic:(NSString *)mnemonic
                           type:(CoinType)type
                       password:(NSString *)password
                      isMainNet:(BOOL)MainNet
                    resultBlock:(void(^)(NSString *privateKey,NSString *address))block;

/// 通过私钥导入
/// - Parameters:
///   - privateKey: 私钥
///   - type: 币种类型
///   - password: 密码
///   - MainNet: 是否BTC主网络，ETH忽略,设置NO
///   - deviceId: 卡片ID
///   - block: 回调结果--地址,密码是否正确
-(void)importWalletByPrivateKey:(NSString *)privateKey
                           type:(CoinType)type
                       password:(NSString *)password
                      isMainNet:(BOOL)MainNet
                      deviceId:(NSString *)deviceId
                    resultBlock:(void(^)(NSString *address,BOOL isCorrect))block;


/// 加密要发送的数据
/// - Parameters:
///   - privateKey: 私钥-64字节
///   - deviceId: 卡片ID
///   - password: 密码
///   - deviceSnNum: 设备SN号
-(NSData *)encryptPrivateKey:(NSString *)privateKey
                deviceId:(NSString *)deviceId
                password:(NSString *)password
             deviceSnNum:(NSString *)deviceSnNum;


/// 签名
/// - Parameters:
///   - tran: 交易数据模型
///   - type: 币种类型
///   - password: 密码
///   - deviceId: 卡片ID
///   - privateKey: 私钥数据
///   - MainNet: 是否BTC主网络，ETH忽略,设置NO
///   - block:  回调结果--地址,密码是否正确
-(void)signTransaction:(STransaction *)tran
                  type:(CoinType)type
              password:(NSString *)password
              deviceId:(NSString *)deviceId
            PrivateKey:(NSString *)privateKey
             isMainNet:(BOOL)MainNet
           resultBlock:(void(^)(NSData *signtureData,BOOL isCorrect))block;

@end
NS_ASSUME_NONNULL_END
