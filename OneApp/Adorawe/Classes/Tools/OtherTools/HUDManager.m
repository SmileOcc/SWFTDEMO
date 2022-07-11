//
//  HUDManager.m
//  DemoHUD
//
//  Copyright (c) 2014年 ygsoft. All rights reserved.
//

#import "HUDManager.h"
#import "AppDelegate.h"

// 定义变量
static MBProgressHUD *mbProgressHUD;

@implementation HUDManager

+ (void)showHUDWithMessage:(NSString *)aMessage
{
    [self showHUD:MBProgressHUDModeText onTarget:nil hide:YES afterDelay:3 enabled:YES message:aMessage customView:nil contentBgColor:nil textColor:nil margin:10 completionBlock:nil];
}

+ (void)showHUDWithMessage:(NSString *)aMessage margin:(CGFloat)margin
{
    [self showHUD:MBProgressHUDModeText onTarget:nil hide:YES afterDelay:2 enabled:YES message:aMessage customView:nil contentBgColor:nil textColor:nil margin:margin completionBlock:nil];
}

+ (void)showHUDWithMessage:(NSString *)aMessage completionBlock:(void (^)(void))block {
    [self showHUD:MBProgressHUDModeText onTarget:nil hide:YES afterDelay:2 enabled:YES message:aMessage customView:nil contentBgColor:nil textColor:nil margin:10 completionBlock:block];
}

+ (void)showHUDWithMessage:(NSString *)aMessage afterDelay:(NSTimeInterval)timeDelay completionBlock:(void (^)(void))block {
    [self showHUD:MBProgressHUDModeText onTarget:nil hide:YES afterDelay:timeDelay enabled:YES message:aMessage customView:nil contentBgColor:nil textColor:nil margin:10 completionBlock:block];
}


+(void)showLoading
{
    [self showLoading:nil contentColor:nil];
}
+ (void)showLoading:(UIColor *)bgColor contentColor:(UIColor *)contentColor {
    
    [self showHUD:MBProgressHUDModeIndeterminate onTarget:nil hide:NO afterDelay:0 enabled:YES message:nil customView:nil contentBgColor:bgColor textColor:contentColor margin:10 completionBlock:nil];
}

+(void)showLoadingOnTarget:(UIView *)target {
    [self showHUD:MBProgressHUDModeIndeterminate onTarget:target hide:NO afterDelay:0 enabled:YES message:nil customView:nil contentBgColor:nil textColor:nil margin:-1 completionBlock:nil];
}


+ (void)showHUDWithMessage:(NSString *)aMessage onTarget:(UIView *)target {
    [self showHUD:MBProgressHUDModeText onTarget:target hide:YES afterDelay:2 enabled:YES message:aMessage customView:nil contentBgColor:nil textColor:nil margin:-1 completionBlock:nil];
}

+ (void)showHUDWithMessage:(NSString *)aMessage customView:(UIView *)customView {
    [self showHUD:MBProgressHUDModeCustomView onTarget:nil hide:YES afterDelay:2 enabled:YES message:aMessage customView:customView contentBgColor:nil textColor:nil margin:-1 completionBlock:nil];
}

+ (void)showHUD:(MBProgressHUDMode)mode hide:(BOOL)autoHide afterDelay:(NSTimeInterval)timeDelay enabled:(BOOL)autoEnabled message:(NSString *)aMessage {
    [self showHUD:mode onTarget:nil hide:autoHide afterDelay:timeDelay enabled:autoHide message:aMessage customView:nil contentBgColor:nil textColor:nil margin:-1 completionBlock:nil];
}


+ (void)showHUD:(MBProgressHUDMode)mode
       onTarget:(UIView *)target
           hide:(BOOL)autoHide
     afterDelay:(NSTimeInterval)timeDelay
        enabled:(BOOL )autoEnabled
        message:(NSString *)aMessage
     customView:(UIView *)customView
 contentBgColor:(UIColor *)contentBgColor
      textColor:(UIColor *)textColor
         margin:(CGFloat)margin
completionBlock:(void (^)(void))block
{
    // 如果已存在，则从父视图移除
    if (mbProgressHUD.superview) {
        [mbProgressHUD removeFromSuperview];
        mbProgressHUD = nil;
    }
    
    if (target && [target isKindOfClass:[UIView class]]) {
        // 添加到目标视图
        mbProgressHUD = [MBProgressHUD showHUDAddedTo:target animated:YES];
    } else {
        // 创建显示视图
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        mbProgressHUD = [MBProgressHUD showHUDAddedTo:delegate.window animated:YES];
    }
    
    // 设置显示模式
    [mbProgressHUD setMode:mode];
    
    // 如果是自定义图标模式，则显示
    if (mode == MBProgressHUDModeCustomView && customView) {
        // 设置自定义图标
        [mbProgressHUD setCustomView:customView];
    }
    
    // 如果是填充模式
    if (mode == MBProgressHUDModeDeterminate || mode == MBProgressHUDModeAnnularDeterminate || mode == MBProgressHUDModeDeterminateHorizontalBar) {
        // 方法2
//        [mbProgressHUD showWhileExecuting:@selector(showProgress) onTarget:self withObject:nil animated:YES];
        mbProgressHUD.minShowTime = 1;
        
    }
    
    if (margin > 0) {
        mbProgressHUD.margin = margin;
    }
    
    // 设置标示标签
    mbProgressHUD.detailsLabel.text = aMessage;
    
    
    // 强制设置
    mbProgressHUD.contentColor = [OSSVThemesColors stlWhiteColor];
    mbProgressHUD.bezelView.color = [OSSVThemesColors col_000000:0.7];
    // 设置模式
    mbProgressHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    
    // 字体颜色
    if (textColor) {
        mbProgressHUD.contentColor = textColor;
    }
    // 黑色背景
    if (contentBgColor) {
        mbProgressHUD.bezelView.color = contentBgColor;
        // 设置模式
        mbProgressHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    }
    
    // 设置显示类型 出现或消失
    [mbProgressHUD setAnimationType: MBProgressHUDAnimationZoom];
    
    // 显示
    [mbProgressHUD showAnimated:YES];

    // 加上这个属性才能在HUD还没隐藏的时候点击到别的view
    // 取反，即!autoEnabled
    [mbProgressHUD setUserInteractionEnabled:!autoEnabled];
    
    // 隐藏后从父视图移除
    [mbProgressHUD setRemoveFromSuperViewOnHide:YES];
    
    // 设置自动隐藏
    if (autoHide) {
        [mbProgressHUD hideAnimated:autoHide afterDelay:timeDelay];
    }
    
    if (block) {
        mbProgressHUD.completionBlock = block;
    }

}

+ (void)hiddenHUD {
    [mbProgressHUD hideAnimated:YES];
}


@end
