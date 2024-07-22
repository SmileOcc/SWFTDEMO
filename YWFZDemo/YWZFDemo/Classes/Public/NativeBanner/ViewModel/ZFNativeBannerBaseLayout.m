//
//  ZFNativeBannerBaseLayout.m
//  ZZZZZ
//
//  Created by YW on 31/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeBannerBaseLayout.h"
#import "ZFFrameDefiner.h"

@implementation ZFNativeBannerBaseLayout

- (instancetype)init {
    if (self = [super init]) {
        self.rowCount                   = 0;
        self.footerSize                 = CGSizeMake(0.0, 0.0);
        self.headerSize                 = CGSizeMake(0.0, 0.0);
        self.edgeInsets                 = UIEdgeInsetsMake(0, 0, 0, 0);
        self.minimumLineSpacing         = 0.0f;
        self.minimumInteritemSpacing    = 0.0f;
        self.itemSize                    = CGSizeMake(KScreenWidth, 0.0f);
    }
    return self;
}

#pragma mark getter/setter
- (void)setRowCount:(NSInteger)rowCount {
    _rowCount = rowCount;
}

@end
