//
//  ZFOutfitBuilderSingleton.h
//  ZZZZZ
//
//  Created by YW on 2018/5/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCommunityOutfitsModel.h"
#import "ZFOutfitItemModel.h"
#import "ZFCommunityOutfitBorderModel.h"

@interface ZFOutfitBuilderSingleton : NSObject

+ (instancetype)shareInstance;
// 要发布的帖子
@property (nonatomic, strong) ZFCommunityOutfitsModel      *postOutfitsModel;
@property (nonatomic, strong) ZFCommunityOutfitBorderModel *borderModel;


- (void)addOutfitItem:(ZFOutfitItemModel *)itemModel;
- (void)deleteSelectedOutfitItem:(ZFOutfitItemModel *)itemModel;

- (BOOL)isCanAdd;
- (BOOL)isContainGoods:(ZFGoodsModel *)goodsModel;

- (NSString *)selecteGoodsIDsString;
- (NSInteger)selectedCount;

// 获取所有本次启动发的穿搭贴，暂时置顶
- (NSArray <ZFCommunityOutfitsModel *> *)myOutfitPosts;

// 清除数据，释放内存
- (void)deallocSingleton;
- (void)removeOutfitPost;

- (ZFCommunityOutfitsModel *)currentPostOutfitsModel;

@end
