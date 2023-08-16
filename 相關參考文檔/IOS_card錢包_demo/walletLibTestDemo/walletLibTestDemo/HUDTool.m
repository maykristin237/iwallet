//
//  HUDTool.m
//  CP33_Project
//
//  Created by admin on 2017/3/30.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "HUDTool.h"
#import <SVProgressHUD.h>
#import <Masonry.h>

@interface HUDTool ()<CAAnimationDelegate>

@property (weak, nonatomic) UIView *tipView;

@end

@implementation HUDTool

static HUDTool *_instance;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - Public

+ (void)dismiss
{
    [SVProgressHUD dismiss];
}

+ (void)showStatusWithString:(NSString *)string
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD showWithStatus:string];
}

+ (void)showErrorWithString:(NSString *)string
{
    [HUDTool showErrorWithString:string showTime:3.0];
}

+ (void)showErrorWithString:(NSString *)string showTime:(NSTimeInterval)time
{
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMinimumDismissTimeInterval:time];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD showErrorWithStatus:string];
}

+ (void)showSuccessWithString:(NSString *)string
{
    [HUDTool showSuccessWithString:string showTime:3.0];
}

+ (void)showSuccessWithString:(NSString *)string showTime:(NSTimeInterval)time
{
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMinimumDismissTimeInterval:time];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD showSuccessWithStatus:string];
}

+ (void)showPromptWithString:(NSString *)string
{
    NSTimeInterval interval = string.length * 0.3;
    interval = MAX(1.5, MIN(interval, 5.0));
    
    
    if (string && string.length > 0) {
        
        [HUDTool showPromptWithString:string showTime:interval];
    }
    
}

+ (void)showPromptWithString:(NSString *)string showTime:(NSTimeInterval)time
{
    [HUDTool dismiss];
    
    if (!(string && string.length > 0)) {
        return;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *view = [window viewWithTag:101];
    if (view) {
        [view.layer removeAllAnimations];
        [view removeFromSuperview];
    }
    UIView *tipView = [[UIView alloc] init];
    tipView.clipsToBounds = YES;
    tipView.tag = 101;
    tipView.layer.cornerRadius = 6.0;
    tipView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    [window addSubview:tipView];
    //不考虑换行的情况(如果换行 第二行的文字也需要居中显示)
    [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(window.mas_centerX);
        make.centerY.equalTo(window.mas_centerY);
    }];
    
    UILabel *tip = [[UILabel alloc] init];
    tip.font = [UIFont systemFontOfSize:14];
    tip.text = string;
    tip.numberOfLines = 0;
    tip.textColor = [UIColor whiteColor];
    [tipView addSubview:tip];
    [tip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    HUDTool *hud = [HUDTool shareInstance];
    hud.tipView = tipView;
    [hud showAnimationWithView:tipView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideAnimationWithView:tipView];
    });
}
#pragma mark - Private

//显示动画
- (void)showAnimationWithView:(UIView *)view
{
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.15;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"opacity"];
    basic.fromValue = [NSNumber numberWithFloat:0.0f];
    basic.toValue = [NSNumber numberWithFloat:1.0f];
    
    group.animations = @[animation, basic];
    [view.layer addAnimation:group forKey:@"show"];
}

//隐藏动画
- (void)hideAnimationWithView:(UIView *)view
{
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.15;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
    group.delegate = self;
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)]];
    animation.values = values;
    
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"opacity"];
    basic.fromValue = [NSNumber numberWithFloat:1.0f];
    basic.toValue = [NSNumber numberWithFloat:0.0f];
    
    group.animations = @[animation, basic];
    [view.layer addAnimation:group forKey:@"show"];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        [self.tipView.layer removeAllAnimations];
        [self.tipView removeFromSuperview];
    }
}

@end
