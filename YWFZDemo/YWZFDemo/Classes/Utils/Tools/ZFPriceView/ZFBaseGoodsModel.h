//
//  ZFBaseGoodsModel.h
//  ZZZZZ
//
//  Created by YW on 14/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFGoodsTagModel.h"
#import "GoodsDetailModel.h"
#import "ZFGoodsModel.h"

@interface ZFBaseGoodsModel : NSObject
/**
 * 售价
 */
@property (nonatomic, copy) NSString   *shopPrice;

/**
 * 原价 (带中间线那种)
 */
@property (nonatomic, copy) NSString   *marketPrice;

/**
 * 是否需要隐藏原价
 * 首页推荐商品需要隐藏
 */
@property (nonatomic, assign) BOOL   isHideMarketPrice;

/**
 * 判断是否需要显示收藏按钮
 * 部分页面是不需要显示的
 */
@property (nonatomic, assign) BOOL   isShowCollectButton;

/**
 * 是否收藏
 */
@property (nonatomic, copy) NSString   *isCollect;

/// 4.5.7添加
/**
 巴西站分期付款字段
 */
@property (nonatomic, assign) BOOL isInstallment;
@property (nonatomic, strong) InstalmentModel *instalmentModel;

@property (nonatomic, strong) NSArray<ZFGoodsTagModel *>   *tagsArray;
/// 是否显示色块选择（ABTest）
@property (nonatomic, assign) BOOL showColorBlock;
/**
 * 同款商品数据 v4.6.0
 */
@property (nonatomic, strong) NSArray <ZFGoodsModel *> *groupGoodsList;

@property (nonatomic, copy) NSAttributedString *RRPAttributedPriceString;

///商品促销价类型 1=秒杀价 2=新用户专享价 3=App专享价 4=清仓价 5=促销价
@property (nonatomic, assign) NSInteger price_type;

- (BOOL)showMarketPrice;

@end

