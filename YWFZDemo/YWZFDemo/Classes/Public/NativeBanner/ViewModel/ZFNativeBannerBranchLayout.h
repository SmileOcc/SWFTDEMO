//
//  ZFNativeBannerBranchLayout.h
//  ZZZZZ
//
//  Created by YW on 31/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeBannerBaseLayout.h"

@class ZFNativeBannerModel;

@interface ZFNativeBannerBranchLayout : ZFNativeBannerBaseLayout

@property (nonatomic, strong) NSArray <ZFNativeBannerModel *> *banners;

@property (nonatomic, assign) NSInteger                 branch;

- (CGSize)itemSizeAtRowIndex:(NSInteger)index;

@end
