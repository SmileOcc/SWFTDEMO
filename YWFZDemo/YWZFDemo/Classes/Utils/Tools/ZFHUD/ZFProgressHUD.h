//
//  ZFProgressHUD.h
//  ZZZZZ
//
//  Created by YW on 1/4/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFProgressHUD : UIView

UIView *loadingViewFromView(id parmaters);

/**
 * 显示loading框，可返回上一个页面，当前控制器 view 禁止交互
 * 适用于页面间跳转
 @param parmaters     字典获取当前控制器 view.
 */
void ShowLoadingToView(id parmaters);

/**
 * 隐藏loading框，可返回上一个页面，当前控制器 view 禁止交互`
 * 适用于页面间跳转
 @param parmaters     字典获取当前控制器 view.
 */
void HideLoadingFromView(id parmaters);

/**
 * 显示loading框，可返回上一个页面，当前控制器 view 禁止交互
 * 纯文本展示
 */
void ShowToastToViewWithText(id parmaters ,NSString *message);

/**
 * 显示网络异常提示框
 */
void ShowNetworkErrorTipToView(UIView *targetView,CGFloat offset);

/**
 * 隐藏网络异常提示框
 */
void HideNetworkErrorTipToView(UIView *targetView);

/**
 * 自定义屏幕顶部显示一个提示条
 */
void ShowScreenTopToolBarToView(UIView *superView, NSString *title, NSString *btnTitle, void(^buttonBlcok)(void)) ;

/**
 * 显示网络请求错误信息提示弹框, 只要在网络数据中 (result)中(error != 0)时才会提示
 * targetView:  为nil时就在window上提示
 * resultDict:  网络请求回调的result结构体字典
 */
void ShowErrorToastToViewWithResult(UIView *targetView ,NSDictionary *resultDict);

/**
 * 显示gif动画加按钮
 */
void ShowGifImageWithGifPathToTransparenceScreenView(CGFloat offset, CGSize size, NSString *gifName, NSString *bottomImgName, void(^buttonBlcok)(void));

@end
