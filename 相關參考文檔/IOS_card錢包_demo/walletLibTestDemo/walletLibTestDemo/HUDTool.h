//
//  HUDTool.h
//  CP33_Project
//
//  Created by admin on 2017/3/30.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HUDTool : NSObject
/**
 主动隐藏提示框
 */
+ (void)dismiss;
/**
 *  加载信息提示(不会主动消失)
 */
+ (void)showStatusWithString:(NSString *)string;
/**
 *  错误信息提示(默认3s后消失)
 */
+ (void)showErrorWithString:(NSString *)string;
+ (void)showErrorWithString:(NSString *)string showTime:(NSTimeInterval)time;
/**
 *  成功信息提示(默认3s后消失)
 */
+ (void)showSuccessWithString:(NSString *)string;
+ (void)showSuccessWithString:(NSString *)string showTime:(NSTimeInterval)time;
/**
 安卓版提示(默认3后消失)
 */
+ (void)showPromptWithString:(NSString *)string;
+ (void)showPromptWithString:(NSString *)string showTime:(NSTimeInterval)time;

@end
