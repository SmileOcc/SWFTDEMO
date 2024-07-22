//
//  ZFUnlineSimilarViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/7/24.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//
// 购物车 下架商品同款商品列表

#import "ZFBaseViewController.h"
#import "ZFAnalytics.h"
#import "ZFAppsflyerAnalytics.h"


@interface ZFUnlineSimilarViewController : ZFBaseViewController

- (instancetype)initWithImageURL:(NSString *)url sku:(NSString *)sku;

// 统计参数
@property (nonatomic, assign) ZFAppsflyerInSourceType       sourceType;

@end
