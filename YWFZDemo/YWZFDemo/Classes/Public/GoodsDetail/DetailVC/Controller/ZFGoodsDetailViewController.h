//
//  ZFGoodsDetailViewController.h
//  ZZZZZ
//
//  Created by YW on 2017/11/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFGoodsDetailTransformView.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFAnalytics.h"

#import "ZFLiveBaseView.h"

@interface ZFGoodsDetailViewController : ZFBaseViewController <UINavigationControllerDelegate>

/// 商品ID
@property (nonatomic, copy) NSString *goodsId;

/// 满赠 赠品ID , 如果传入了赠品ID，作为参数传给后台获取赠品赠品信息
@property (nonatomic, copy) NSString *freeGiftId;

/// 转场过渡视图
@property (nonatomic, strong) ZFGoodsDetailTransformView *transformView;
@property (nonatomic, strong) UIImageView *transformSourceImageView;

/// 统计参数
@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;

/// 深度链接来源，如果不为空，就取代 sourceType
@property (nonatomic, copy) NSString *deeplinkSource;
@property (nonatomic, copy) NSString *sourceID;

/// 从上级页面传进来的AF统计参数，可能为空
@property (nonatomic, strong) AFparams *afParams;

/// 排序统计,可能为nil
@property (nonatomic, copy) NSString *analyticsSort;

/// 商品的rank index (从分类页，虚拟分类页，首页频道，搜索结果页，进入必须传此字段)
@property (nonatomic, assign) NSInteger af_rank;

/// 列表传入
@property (nonatomic, strong) ZFAnalyticsProduceImpression *analyticsProduceImpression;

/// 商品图片是否需要做博主图Bts实现
@property (nonatomic, assign) BOOL isNeedProductPhotoBts;

/// 标识商品详情数据加载成功
@property (nonatomic, copy) void (^goodsDetailSuccessBlock)(BOOL flag);

@property (nonatomic, weak) ZFLiveBaseView *playerView;

@end
