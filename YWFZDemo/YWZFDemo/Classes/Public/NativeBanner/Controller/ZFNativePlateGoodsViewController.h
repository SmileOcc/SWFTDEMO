//
//  ZFNativePlateGoodsViewController.h
//  ZZZZZ
//
//  Created by YW on 4/1/18.
//  Copyright © 2018年 YW. All rights reserved.
//  原生专题只有一个商品列表的时候使用的控制器
//  带层级的

#import "ZFBaseViewController.h"
#import "ZFAnalytics.h"

@class ZFNativeBannerResultModel;
@class YNPageCollectionView;

@interface ZFNativePlateGoodsViewController : ZFBaseViewController

@property (nonatomic, strong) ZFNativeBannerResultModel         *model;
@property (nonatomic, copy) NSString                            *specialTitle;  // 专题名称
//统计
@property (nonatomic, strong) ZFAnalyticsProduceImpression      *analyticsProduceImpression;

- (YNPageCollectionView *)querySubScrollView;
@end
