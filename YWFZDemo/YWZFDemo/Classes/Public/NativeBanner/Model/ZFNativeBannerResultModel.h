//
//  ZFNativeBannerResultModel.h
//  ZZZZZ
//
//  Created by YW on 25/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFNativeBannerInfoModel.h"
#import "ZFNativeBannerListModel.h"
#import "ZFNativePlateGoodsModel.h"
#import "ZFNativeBannerPageModel.h"

@interface ZFNativeBannerResultModel : NSObject

@property (nonatomic, strong) ZFNativeBannerInfoModel                    *infoModel;
/**
 * banner 分馆
 */
@property (nonatomic, strong) NSArray<ZFNativeBannerListModel *>         *bannerList;
/**
 * 无导航商品数组
 */
@property (nonatomic, strong) NSArray<ZFNativePlateGoodsModel *>         *plateGoodsArray;
/**
 * 导航栏标题数组
 */
@property (nonatomic, strong) NSArray<ZFNativeBannerPageModel *>         *menuList;


/************  以下参数是自定义的,不是后台返回 *****************/
/**
 * 所有分馆的总数
 */
@property (nonatomic, assign) NSInteger   bannerCount;

/**
 * 所有分馆高度总和
 */
@property (nonatomic, assign) CGFloat     allbannerHeight;

- (CGFloat)calculateAllBranchHeight;
@end

