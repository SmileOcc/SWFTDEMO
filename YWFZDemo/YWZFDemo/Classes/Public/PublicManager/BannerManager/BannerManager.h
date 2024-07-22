//
//  BannerManager.h
//  ZZZZZ
//
//  Created by YW on 16/10/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFBannerModel.h"

@interface BannerManager : NSObject

/**
 * 根据url解析Deeplink参数
 */
+ (NSMutableDictionary *)parseDeeplinkParamDicWithURL:(NSURL *)url;

/**
 * Deeplink数据源解析
 */
+ (void)jumpDeeplinkTarget:(id)target deeplinkParam:(NSDictionary *)paramDict;

/**
 * Deeplink跳转
 */
+ (void)doBannerActionTarget:(id)target withBannerModel:(ZFBannerModel *)bannerModel;

@end
