//
//  ZFGoodsDetailCellTypeModel.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailCellTypeModel.h"
#import "ZFGoodsDetailColectionViewImportFiles.h"

@implementation ZFGoodsDetailCellTypeModel

/**
 * 获取商详页面所有的Cell类型
 */
+ (NSArray *)fetchDetailAllCellTypeArray
{
    return @[@{ @(ZFGoodsDetailCellTypeScrollBanner)    : [ZFGoodsDetailBannerCell class]} ,
             @{ @(ZFGoodsDetailCellTypeActivity)        : [ZFGoodsDetailActivityCell class]} ,
             @{ @(ZFGoodsDetailCellTypeGoodsInfo)       : [ZFGoodsDetailGoodsInfoCell class]} ,
             @{ @(ZFGoodsDetailCellTypeCoupon)          : [ZFGoodsDetailNormalArrowsCell class]} ,
             @{ @(ZFGoodsDetailCellTypeSelectStandard)  : [ZFGoodsDetailGoodsSelectSizeCell class]} ,
             @{ @(ZFGoodsDetailCellTypeProductModelDesc): [ZFGoodsDetailProductModelDescCell class]} ,
             @{ @(ZFGoodsDetailCellTypeQualified)       : [ZFGoodsDetailGoodsQualifiedCell class]} ,
             @{ @(ZFGoodsDetailCellTypeShippingTips)    : [ZFGoodsDetailNormalArrowsCell class]} ,
             @{ @(ZFGoodsDetailCellTypeDescription)     : [ZFGoodsDetailNormalArrowsCell class]} ,
             @{ @(ZFGoodsDetailCellTypeModelStats)      : [ZFGoodsDetailNormalArrowsCell class]} ,
             @{ @(ZFGoodsDetailCellTypeShow)            : [ZFGoodsDetailGoodsShowCell class]} ,
             @{ @(ZFGoodsDetailCellTypeReviewStar)      : [ZFGoodsDetailGoodsReviewStarCell class]} ,
             @{ @(ZFGoodsDetailCellTypeReview)          : [ZFGoodsDetailGoodsReviewCell class]} ,
             @{ @(ZFGoodsDetailCellTypeReviewViewAll)   : [ZFGoodsDetailGoodsReviewViewAllCell class]} ,
             @{ @(ZFGoodsDetailCellTypeCollocationBuy)  : [ZFGoodsDetailCollocationBuyCell class]},
             @{ @(ZFGoodsDetailCellTypeOutfits)         : [ZFGoodsDetailOutfitsCell class]},
             @{ @(ZFGoodsDetailCellTTypeRecommendHeader): [ZFGoodsDetailGoodsRecommendHeaderCell class]} ,
             @{ @(ZFGoodsDetailCellTTypeRecommend)      : [ZFGoodsDetailGoodsRecommendCell class]},
             ];
}

- (void)setReviewModelArray:(NSArray<GoodsDetailFirstReviewModel *> *)reviewModelArray {
    _reviewModelArray = reviewModelArray;
    
    NSMutableArray *sizeArray = [NSMutableArray array];
    for (NSInteger i=0; i<reviewModelArray.count; i++) {
        GoodsDetailFirstReviewModel *reviewModel = reviewModelArray[i];
        CGFloat celLHeight = [ZFGoodsDetailGoodsReviewCell fetchReviewCellHeight:reviewModel];// 计算高度
        [sizeArray addObject:NSStringFromCGSize(CGSizeMake(KScreenWidth, celLHeight))];
    }
    self.reviewCellSizeArray = sizeArray;
}

@end
