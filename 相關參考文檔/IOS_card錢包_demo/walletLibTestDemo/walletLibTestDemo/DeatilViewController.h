//
//  DeatilViewController.h
//  WalletOCDemo
//
//  Created by 七块 on 2023/3/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,FuncType){
    FuncTypeCreateBtc,          //创建BTC
    FuncTypeMonInputBtc,
    FuncTypepriKeyBtc,
    FuncTypeSignBtc,
    FuncTypeCreateEth,
    FuncTypeMoninputEth,
    FuncTypepriKeyEth,
    FuncTypesignEth
};

@interface DeatilViewController : UIViewController

@property(nonatomic,assign) FuncType type;

@end

NS_ASSUME_NONNULL_END
