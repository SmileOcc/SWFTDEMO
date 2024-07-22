//
//  ZFNativeBannerSKUBannerLayout.m
//  ZZZZZ
//
//  Created by YW on 31/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeBannerSKUBannerLayout.h"
#import "ZFFrameDefiner.h"

@implementation ZFNativeBannerSKUBannerLayout

- (instancetype)init {
    if (self = [super init]) {
        self.type       = ZFNativeBannerTypeSKUBanner;
        self.itemSize   = CGSizeMake(KScreenWidth, 158);
        self.headerSize = CGSizeMake(KScreenWidth, 10);
        self.footerSize = CGSizeMake(KScreenWidth, 10);
        [self setRowCount:1];
    }
    return self;
}

@end
