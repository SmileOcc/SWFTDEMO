//
//  PostGoodsManger.m
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "PostGoodsManager.h"
#import "GoodListModel.h"
#import "ZFCommunityPostShowOrderListModel.h"
#import "ZFGoodsModel.h"

@interface PostGoodsManager ()


@end

@implementation PostGoodsManager

+ (PostGoodsManager *)sharedManager {
    static PostGoodsManager *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
        sharedManagerInstance.hotArray = [NSMutableArray array];
        sharedManagerInstance.wishArray = [NSMutableArray array];
        sharedManagerInstance.bagArray = [NSMutableArray array];
        sharedManagerInstance.orderArray = [NSMutableArray array];
        sharedManagerInstance.recentArray = [NSMutableArray array];
        sharedManagerInstance.isFirstTimeEnter = YES;
    });
    return sharedManagerInstance;
}

- (void)removeGoodsWithModel:(ZFCommunityPostShowSelectGoodsModel *)model {
    switch (model.goodsType) {
        case CommunityGoodsTypeHot:
        {
            NSArray *tempHotArray = [self.hotArray copy];
            [tempHotArray enumerateObjectsUsingBlock:^(ZFGoodsModel *wishModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([wishModel.goods_id isEqualToString:model.goodsID]) {
                    [self.hotArray removeObject:wishModel];
                }
            }];
        }
            break;
        case CommunityGoodsTypeWish:
        {
            NSArray *tempWishArray = [self.wishArray copy];
            [tempWishArray enumerateObjectsUsingBlock:^(ZFGoodsModel *wishModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([wishModel.goods_id isEqualToString:model.goodsID]) {
                    [self.wishArray removeObject:wishModel];
                }
            }];
            break;
        }
        case CommunityGoodsTypeBag:
        {
            NSArray *tempBagArray = [self.bagArray copy];
            [tempBagArray enumerateObjectsUsingBlock:^(GoodListModel *bagModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([bagModel.goods_id isEqualToString:model.goodsID]) {
                    [self.bagArray removeObject:bagModel];
                }
            }];
            break;
        }
        case CommunityGoodsTypeOrder:
        {
            NSArray *tempOrderArray = [self.orderArray copy];
            [tempOrderArray enumerateObjectsUsingBlock:^(ZFCommunityPostShowOrderListModel *orderModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([orderModel.goods_id isEqualToString:model.goodsID]) {
                    [self.orderArray removeObject:orderModel];
                }
            }];
            break;
        }
        case CommunityGoodsTypeRecent:
        {
            NSArray *tempRecentArray = [self.recentArray copy];
            [tempRecentArray enumerateObjectsUsingBlock:^(ZFGoodsModel *recentModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([recentModel.goods_id isEqualToString:model.goodsID]) {
                    [self.recentArray removeObject:recentModel];
                }
            }];
            break;
        }
    }
}

- (void)clearData {
    [self.hotArray removeAllObjects];
    [self.wishArray removeAllObjects];
    [self.bagArray removeAllObjects];
    [self.orderArray removeAllObjects];
    [self.recentArray removeAllObjects];
}


@end
