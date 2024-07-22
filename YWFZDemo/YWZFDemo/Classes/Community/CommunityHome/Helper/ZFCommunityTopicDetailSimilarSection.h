//
//  ZFCommunityTopicDetailSimilarSection.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailBaseSection.h"

@class ZFCommunityGoodsInfosModel;
@interface ZFCommunityTopicDetailSimilarSection : ZFCommunityTopicDetailBaseSection

@property (nonatomic, assign) CGFloat bottomSpaceHeight;
@property (nonatomic, assign) NSInteger bottomSelectIndex;


@property (nonatomic, strong) NSArray<ZFCommunityGoodsInfosModel *> *goodsArray;
- (NSString *)goodsImageURLWithIndex:(NSInteger)index;
- (NSString *)goodsPriceURLWithIndex:(NSInteger)index;
- (NSString *)goodsIDWithIndex:(NSInteger)index;
- (NSString *)goodsSNWithIndex:(NSInteger)index;
- (BOOL)isSimilarGoodsWithIndex:(NSInteger)index;

@end
