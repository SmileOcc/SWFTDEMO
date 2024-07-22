//
//  ZFNativeBannerBranchLayout.m
//  ZZZZZ
//
//  Created by YW on 31/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeBannerBranchLayout.h"
#import "ZFNativeBannerModel.h"
#import "NSArray+SafeAccess.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"

@implementation ZFNativeBannerBranchLayout

- (instancetype)init {
    if (self = [super init]) {
        self.type  = ZFNativeBannerTypeBranch;
    }
    return self;
}

- (void)setBanners:(NSArray<ZFNativeBannerModel *> *)banners {
    _banners = banners;
    [self setRowCount:banners.count];
}

- (CGSize)itemSizeAtRowIndex:(NSInteger)index {
    ZFNativeBannerModel *model = [self.banners objectWithIndex:index];
    
    BOOL isValid         = !ZFIsEmptyString(model.bannerHeight) && !ZFIsEmptyString(model.bannerWidth);
    CGFloat scale        = isValid ? [model.bannerWidth floatValue] / [model.bannerHeight floatValue] : 0;
    CGFloat tmpWidth     = [self collectionitemWidthCountPerRow:self.branch index:index];
    CGFloat bannerWidth  = self.branch > 0 ? tmpWidth : KScreenWidth;
    if ([model.bannerHeight floatValue] > 0) {
        scale = isValid ? [model.bannerWidth floatValue] / [model.bannerHeight floatValue] : 0;
    }
    // 特殊情况下,返回不为0,即可以显示正常
    CGFloat firstWidth   = [self collectionitemWidthCountPerRow:self.branch index:0];
    CGFloat bannerHeight = scale > 0 ?  (firstWidth / scale) : 0.1;
    bannerHeight         = round(bannerHeight);
    return CGSizeMake(bannerWidth, bannerHeight);
}

- (CGFloat)collectionitemWidthCountPerRow:(NSInteger)count index:(NSInteger)index {
    // 处理collectionView小数点bug，因为collectView是智能布局，当出现小数点时会随机分配宽度
    if (count <= 0) {
        return KScreenWidth;
    }
    NSInteger columnCount   = count;
    NSInteger cellWidth     = round(KScreenWidth / columnCount);    // 四舍五入
    if (index % columnCount == 0) {
        if (cellWidth * columnCount > KScreenWidth) {
            return cellWidth - (cellWidth * columnCount - KScreenWidth);
        } else {
            return KScreenWidth - cellWidth * (columnCount - 1);
        }
    } else {
        return cellWidth;
    }
}


@end
