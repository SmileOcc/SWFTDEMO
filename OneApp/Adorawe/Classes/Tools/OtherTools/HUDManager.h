//
//  HUDManager.h
//  DemoHUD
//
//  Copyright (c) 2014年 ygsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HUDManager : NSObject <MBProgressHUDDelegate>

/*!
 *  @brief 用于网络数据加载时，显示菊花，可交互，配合下面的hiddenHUD 一起使用。加到window上
 */
+ (void)showLoading;
+ (void)showLoading:(UIColor *)bgColor contentColor:(UIColor *)contentColor;

/*!
 *  @brief 用于网络数据加载时，显示菊花,可交互，配合下面的hiddenHUD 一起使用 阻塞页面不阻塞导航栏可用此方法设置!!!
 *  @param target 加载视图被添加到该视图上, 如果target=nil,则被添加到window上
 */
+(void)showLoadingOnTarget:(UIView *)target;


/**
 *  @brief 显示默认模式的加载视图,添加到window,阻塞操作 默认为只显示文本，自动隐藏
 */
+ (void)showHUDWithMessage:(NSString *)aMessage;

+ (void)showHUDWithMessage:(NSString *)aMessage margin:(CGFloat)margin;
+ (void)showHUDWithMessage:(NSString *)aMessage completionBlock:(void (^)(void))block;
+ (void)showHUDWithMessage:(NSString *)aMessage afterDelay:(NSTimeInterval)timeDelay completionBlock:(void (^)(void))block;
/**
 @brief 显示默认模式的加载视图,添加到target,阻塞操作[阻塞页面不阻塞导航栏可用此方法设置]
 @param aMessage 加载视图显示的文字信息
 @param target   加载视图被添加到该视图上, 如果target=nil,则被添加到window上
 */
+ (void)showHUDWithMessage:(NSString *)aMessage onTarget:(UIView *)target;

/*!
 *  @brief 设置自定义HUD 默认2秒隐藏，可交互
 *  @param aMessage   提示文字
 *  @param customView 自定义视图（一般为照片）
 */
+ (void)showHUDWithMessage:(NSString *)aMessage customView:(UIView *)customView;

/**
 @brief  完善加载视图
 @param mode        加载模式
 @param target      加载视图被添加到该视图上, 如果target=nil,则被添加到window上
 @param autoHide    是否到时间自动隐藏
 @param timeDelay   加载视图持续时间，hide=YES才起作用
 @param autoEnabled 加载视图显示过程中是否允许操作
 @param aMessage    加载视图显示的文字信息
 */
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
completionBlock:(void (^)(void))block;

/// 设置方法:此方法默认加载到window上
+ (void)showHUD:(MBProgressHUDMode)mode hide:(BOOL)autoHide afterDelay:(NSTimeInterval)timeDelay enabled:(BOOL)autoEnabled message:(NSString *)aMessage;

/*!
 *  @brief 隐藏
 */
+ (void)hiddenHUD;

@end
