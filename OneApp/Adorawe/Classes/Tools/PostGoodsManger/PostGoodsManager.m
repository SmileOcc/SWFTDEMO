//
//  PostGoodsManger.m
//  Zaful
//
//  Created by 10010 on 20/7/29.
//  Copyright © 2020年 StarLink. All rights reserved.
//

#import "PostGoodsManager.h"
#import "SelectGoodsModel.h"
#import "PostModel.h"

@interface PostGoodsManager ()

@end

@implementation PostGoodsManager

+ (PostGoodsManager *)sharedManager {
    static PostGoodsManager *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
        sharedManagerInstance.wishArray = [NSMutableArray array];
        sharedManagerInstance.bagArray = [NSMutableArray array];
        sharedManagerInstance.orderArray = [NSMutableArray array];
        sharedManagerInstance.recentArray = [NSMutableArray array];
        sharedManagerInstance.isFirstTimeEnter = YES;
    });
    return sharedManagerInstance;
}

- (void)removeGoodsWithModel:(SelectGoodsModel *)model {
    switch (model.goodsType) {
        case CommunityGoodTypeWish:
        {
            [self.wishArray enumerateObjectsUsingBlock:^(PostModel *wishModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([wishModel.goodsId isEqualToString:model.goodsID]) {
                    [self.wishArray removeObject:wishModel];
                }
            }];
            break;
        }
        case CommunityGoodTypeBag:
        {
            [self.bagArray enumerateObjectsUsingBlock:^(PostModel *bagModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([bagModel.goodsId isEqualToString:model.goodsID]) {
                    [self.bagArray removeObject:bagModel];
                }
            }];
            break;
        }
        case CommunityGoodTypeOrder:
        {
            [self.orderArray enumerateObjectsUsingBlock:^(PostModel *orderModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([orderModel.goodsId isEqualToString:model.goodsID]) {
                    [self.orderArray removeObject:orderModel];
                }
            }];
            break;
        }
        case CommunityGoodTypeRecent:
        {
            [self.recentArray enumerateObjectsUsingBlock:^(PostModel *recentModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([recentModel.goodsId isEqualToString:model.goodsID]) {
                    [self.recentArray removeObject:recentModel];
                }
            }];
            break;
        }
    }
}

- (void)clearData {
    [self.wishArray removeAllObjects];
    [self.bagArray removeAllObjects];
    [self.orderArray removeAllObjects];
    [self.recentArray removeAllObjects];
}


@end
