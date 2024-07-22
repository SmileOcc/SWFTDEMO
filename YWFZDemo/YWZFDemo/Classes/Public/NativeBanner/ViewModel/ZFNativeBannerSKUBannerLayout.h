//
//  ZFNativeBannerSKUBannerLayout.h
//  ZZZZZ
//
//  Created by YW on 31/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeBannerBaseLayout.h"
#import "ZFGoodsModel.h"

@class ZFBannerModel;

@interface ZFNativeBannerSKUBannerLayout : ZFNativeBannerBaseLayout

@property (nonatomic, strong) NSArray <ZFGoodsModel *> *goodsArray;

@property (nonatomic, strong) ZFBannerModel   *bannerModel;

@end
