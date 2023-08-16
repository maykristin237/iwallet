//
//  MainViewController.m
//  WalletOCDemo
//
//  Created by 七块 on 2023/3/10.
//

#import "MainViewController.h"
#import "DeatilViewController.h"
//#import "WalletManaegr.h"
//#import "TestViewController.h"

const NSInteger CraeteBTC = 1001;
const NSInteger MonInputBTC = 1002;
const NSInteger privateKeyInputBTC = 1003;
const NSInteger SignBTC = 1004;
const NSInteger CraeteEth = 2001;
const NSInteger monInputEth = 2002;
const NSInteger privateKeyInputEth = 2003;
const NSInteger signEth = 2004;

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ///使用前--请查看readme文件
    self.navigationItem.title = @"钱包功能";
}
- (IBAction)ButtonClick:(UIButton *)sender {
    DeatilViewController *vc = [[DeatilViewController alloc]init];
    switch (sender.tag) {
        case CraeteBTC:
        {
            vc.type = FuncTypeCreateBtc;
        }
            break;
        case MonInputBTC:
        {
            vc.type = FuncTypeMonInputBtc;
        }
            break;
        case privateKeyInputBTC:
        {
            vc.type = FuncTypepriKeyBtc;
        }
            break;
        case SignBTC:
        {
            vc.type = FuncTypeSignBtc;
        }
            break;
        case CraeteEth:
        {
            vc.type = FuncTypeCreateEth;
        }
            break;
        case monInputEth:
        {
            vc.type = FuncTypeMoninputEth;
        }
            break;
        case privateKeyInputEth:
        {
            vc.type = FuncTypepriKeyEth;
        }
            break;
        case signEth:
        {
            vc.type = FuncTypesignEth;
        }
            break;
        default:
            break;
    }
    [self.navigationController pushViewController:vc animated:YES];
}


@end
