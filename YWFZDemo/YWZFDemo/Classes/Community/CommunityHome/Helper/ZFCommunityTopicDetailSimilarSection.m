//
//  ZFCommunityTopicDetailSimilarSection.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailSimilarSection.h"
#import "ZFCommunityGoodsInfosModel.h"
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"

@implementation ZFCommunityTopicDetailSimilarSection

- (instancetype)init {
    if (self = [super init]) {
        self.type                    = ZFTopicSectionTypeSimilar;
        self.columnCount             = 3;
        self.headerSize              = CGSizeMake(KScreenWidth, 44.0);
        self.footerSize              = CGSizeMake(KScreenWidth, 12.0);
        self.minimumLineSpacing      = 0.0f;
        self.minimumInteritemSpacing = 12.0f;
        CGFloat cellWidth            = (KScreenWidth - 12.0 * 4) / 3;
        CGFloat cellHeight           = cellWidth * 145.0 / 109.0 + 40.0;
        self.itemSize                = CGSizeMake(cellWidth, cellHeight);
        self.edgeInsets              = UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0);
        
        self.bottomSpaceHeight       = 0;
    }
    return self;
}

- (void)setGoodsArray:(NSArray<ZFCommunityGoodsInfosModel *> *)goodsArray {
    _goodsArray   = goodsArray;
    self.rowCount = goodsArray.count;
    
    self.edgeInsets = UIEdgeInsetsZero;
    self.columnCount = 1;
    self.bottomSpaceHeight = 0;
    self.bottomSelectIndex = 0;
    self.rowCount = _goodsArray.count > 0 ? 1 : 0;
    CGFloat cellWidth            = (KScreenWidth - 12.0 * 4) / 3;
    CGFloat cellHeight           = cellWidth * 145.0 / 109.0 + 40.0;
    if (_goodsArray.count < 4) {
        self.itemSize = CGSizeMake(KScreenWidth, cellHeight);
    } else if (_goodsArray.count < 7) {
        self.itemSize = CGSizeMake(KScreenWidth, 2 * cellHeight);
    } else {
        self.bottomSpaceHeight = 30;
        self.itemSize = CGSizeMake(KScreenWidth, 2 * cellHeight + self.bottomSpaceHeight);
    }
}

- (ZFCommunityGoodsInfosModel *)goodsInfoModelWithIndex:(NSInteger)index {
    if (self.goodsArray.count > index) {
        ZFCommunityGoodsInfosModel *model = [self.goodsArray objectAtIndex:index];
        return model;
    }
    return [ZFCommunityGoodsInfosModel new];
}

- (NSString *)goodsImageURLWithIndex:(NSInteger)index {
    return [self goodsInfoModelWithIndex:index].goodsImg;
}

- (NSString *)goodsPriceURLWithIndex:(NSInteger)index {
    NSString *price = [self goodsInfoModelWithIndex:index].shopPrice;
    if ([price length] > 0) {
        return [ExchangeManager transforPrice:price];
    }
    return nil;
}

- (NSString *)goodsIDWithIndex:(NSInteger)index {
    return [self goodsInfoModelWithIndex:index].goodsId;
}

- (NSString *)goodsSNWithIndex:(NSInteger)index {
    return [self goodsInfoModelWithIndex:index].goods_sn;
}

- (BOOL)isSimilarGoodsWithIndex:(NSInteger)index {
    return [self goodsInfoModelWithIndex:index].isSame;
}

@end
