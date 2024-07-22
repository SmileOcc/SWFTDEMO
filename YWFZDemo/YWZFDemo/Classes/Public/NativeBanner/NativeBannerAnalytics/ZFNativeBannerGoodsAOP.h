//
//  ZFNativeBannerGoodsAOP.h
//  ZZZZZ
//
//  Created by YW on 2018/10/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  原生专题推荐商品统计AOP
//  适用于 ZFNativeGoodsViewController， ZFNativePlateGoodsViewController

#import <Foundation/Foundation.h>
#import "AnalyticsInjectManager.h"
#import "ZFAnalyticsInjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFNativeBannerGoodsAOP : NSObject
<
    ZFAnalyticsInjectProtocol
>

@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, copy) NSString *specialTitle;  // 专题名称

@end

NS_ASSUME_NONNULL_END
