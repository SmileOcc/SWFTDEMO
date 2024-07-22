//
//  ZFHomeAnalysis.h
//  ZZZZZ
//
//  Created by YW on 22/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFGoodsModel.h"
#import "ZFAnalytics.h"

@interface ZFHomeAnalysis : NSObject


/**
 * 统计首页广告浮窗
 */
+ (void)showHomeFloatingAdvertWindow:(ZFBannerModel *)floatBanner;
+ (void)clickHomeFloatingAdvertWindow:(ZFBannerModel *)floatBanner;

@end
