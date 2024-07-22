//
//  ZFHomeManager.h
//  ZZZZZ
//
//  Created by YW on 23/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ZFBannerModel;

@interface ZFHomeManager : NSObject

/**
 * 监听无网络,显示首页无网络提示
 */
+ (void)showNoNetWorkError:(UIView *)view offset:(CGFloat)offset;

/**
 * 加载浮窗banner按钮UI
 */
+ (void)requestBottomFloatBanner:(void (^)(ZFBannerModel *bannerModel))completion;


@end
