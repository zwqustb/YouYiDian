//
//  MBProgressHUD+MJ.m
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+HM.h"

@implementation MBProgressHUD (HM)
#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil)
    {
        if ([UIApplication sharedApplication].keyWindow) {
            view=[UIApplication sharedApplication].keyWindow;
        }
        else
        {
             view = [[[UIApplication sharedApplication]windows ]lastObject];
        }
    }
    
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:2];
}
+ (void)show:(NSString *)text view:(UIView *)view
{
    if (view == nil)
    {
        if ([UIApplication sharedApplication].keyWindow) {
            view=[UIApplication sharedApplication].keyWindow;
        }
        else
        {
            view = [[[UIApplication sharedApplication]windows ]lastObject];
        }
    }
    
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    hud.opacity = 0.50;
    CGSize ScreenSize = [UIScreen mainScreen].bounds.size;
    hud.minSize = CGSizeMake(ScreenSize.width*0.7, 0);
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:1.0];
}
#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    return hud;
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

+ (void)hideHUDForView:(UIView *)view
{
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}
+ (void)showWaiting:(NSString*)message toView:(UIView*)pView{
    //dispatch
    dispatch_async(dispatch_get_main_queue(), ^{
        g_pGlobalWaiting = [self showMessage:message toView:pView];
    });
    
}
+ (void)setWaitingTxt:(NSString*)pTxt{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (g_pGlobalWaiting) {
            g_pGlobalWaiting.labelText = pTxt ;
        }
    });
}
+ (void)setWaitingDetailTxt:(NSString*)pTxt{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (g_pGlobalWaiting) {
            g_pGlobalWaiting.detailsLabelText = pTxt;
        }
    });
}
+ (void)closeWaiting{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (g_pGlobalWaiting) {
            [g_pGlobalWaiting hide:true];
        }
    });
}
@end
