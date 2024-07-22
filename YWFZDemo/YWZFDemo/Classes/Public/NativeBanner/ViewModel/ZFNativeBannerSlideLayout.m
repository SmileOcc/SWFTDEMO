//
//  ZFNativeBannerSlideLayout.m
//  ZZZZZ
//
//  Created by YW on 31/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeBannerSlideLayout.h"
#import "ZFNativeBannerModel.h"
#import "NSArray+SafeAccess.h"
#import "ZFFrameDefiner.h"

@implementation ZFNativeBannerSlideLayout

- (instancetype)init {
    if (self = [super init]) {
        self.type        = ZFNativeBannerTypeSlide;
        [self setRowCount:1];
    }
    return self;
}

- (CGSize)itemSize {
    ZFNativeBannerModel *model = [self.slideArray objectWithIndex:0];
    CGFloat bannerWidth  = KScreenWidth;
    CGFloat cellWidth = (KScreenWidth - 60)/2;
    CGFloat bannerHeight = [model.bannerHeight floatValue] * cellWidth / [model.bannerWidth floatValue];
    return CGSizeMake(bannerWidth, bannerHeight);
}




@end
