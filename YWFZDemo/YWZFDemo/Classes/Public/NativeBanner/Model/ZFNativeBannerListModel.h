//
//  ZFNativeBannerListModel.h
//  ZZZZZ
//
//  Created by YW on 13/4/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFNativeBannerBaseLayout.h"

@class ZFNativeBannerModel;
@class ZFGoodsModel;

@interface ZFNativeBannerListModel : NSObject
/**
 * banner id
 */
@property (nonatomic, copy) NSString   *bannerID;
/**
 * banner name
 */
@property (nonatomic, copy) NSString   *bannerName;
/**
 * banner 类型
 * 1:一分馆  2:多分馆  3:滑动banner  4:banner+sku  5:商品
 */
@property (nonatomic, assign) ZFNativeBannerType   bannerType;
/**
 * 多分馆数组
 */
@property (nonatomic, strong) NSArray<ZFNativeBannerModel *>   *bannerList;
/**
 * sku集合
 */
@property (nonatomic, strong) NSArray<ZFGoodsModel *>   *skuArrays;


@end
