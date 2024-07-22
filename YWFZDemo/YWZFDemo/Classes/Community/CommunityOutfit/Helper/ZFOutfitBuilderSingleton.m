//
//  ZFOutfitBuilderSingleton.m
//  ZZZZZ
//
//  Created by YW on 2018/5/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOutfitBuilderSingleton.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

static ZFOutfitBuilderSingleton *builderSingleton = nil;
static dispatch_once_t onceToken;

@interface ZFOutfitBuilderSingleton ()

@property (nonatomic, strong) NSMutableArray      *myOutfitPostArray;
@property (nonatomic, strong) NSMutableArray      *outifitItemsArray;


@end

@implementation ZFOutfitBuilderSingleton

+ (instancetype)shareInstance {
    dispatch_once(&onceToken, ^{
        builderSingleton = [[ZFOutfitBuilderSingleton alloc] init];
        builderSingleton.postOutfitsModel  = [[ZFCommunityOutfitsModel alloc] init];
        builderSingleton.myOutfitPostArray = [NSMutableArray new];
        builderSingleton.outifitItemsArray = [NSMutableArray new];
    });
    return builderSingleton;
}

- (void)addOutfitItem:(ZFOutfitItemModel *)itemModel {
    if (self.outifitItemsArray.count < 15 && itemModel) {
        [self.outifitItemsArray addObject:itemModel];
    }
}
- (void)deleteSelectedOutfitItem:(ZFOutfitItemModel *)itemModel {
    if (itemModel) {
        [self.outifitItemsArray removeObject:itemModel];
    }
}

- (BOOL)isCanAdd {
    return self.outifitItemsArray.count >= 15 ? NO : YES;
}

- (BOOL)isContainGoods:(ZFGoodsModel *)goodsModel {
    
    __block BOOL contain = NO;
    NSString *goodsId = goodsModel.goods_id;
    if (!ZFIsEmptyString(goodsId)) {
        [self.outifitItemsArray enumerateObjectsUsingBlock:^(ZFOutfitItemModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.goodModel.goods_id isEqualToString:goodsId]) {
                contain = YES;
                *stop = YES;
            }
        }];
    }
    return contain;
}

- (NSInteger)selectedCount {
    YWLog(@"---- %lu",(unsigned long)self.outifitItemsArray.count);
    return self.outifitItemsArray.count;
}

- (NSString *)selecteGoodsIDsString {
    NSMutableString *string = [NSMutableString new];
    NSInteger i = 0;
    for (ZFOutfitItemModel *itemModel in self.outifitItemsArray) {
        if (i == self.outifitItemsArray.count - 1) {
            [string appendString:ZFToString(itemModel.goodModel.goods_id)];
        } else {
            [string appendFormat:@"%@,", ZFToString(itemModel.goodModel.goods_id)];
        }
        i++;
    }
    return string;
}


- (NSArray<ZFCommunityOutfitsModel *> *)myOutfitPosts {
    return self.myOutfitPostArray;
}

- (void)deallocSingleton {
    [self.outifitItemsArray removeAllObjects];
}

- (void)removeOutfitPost {
    [self.myOutfitPostArray removeAllObjects];
}

- (ZFCommunityOutfitsModel *)currentPostOutfitsModel {
    
    ZFCommunityOutfitsModel *model = [[ZFCommunityOutfitsModel alloc] init];
    
    model.reviewTitle = [ZFOutfitBuilderSingleton shareInstance].postOutfitsModel.reviewTitle;
    model.reviewId = [ZFOutfitBuilderSingleton shareInstance].postOutfitsModel.reviewId;
    model.nikename = [ZFOutfitBuilderSingleton shareInstance].postOutfitsModel.nikename;
    model.avatar = [ZFOutfitBuilderSingleton shareInstance].postOutfitsModel.avatar;
    model.img = [ZFOutfitBuilderSingleton shareInstance].postOutfitsModel.img;
    
    return model;
}
@end
