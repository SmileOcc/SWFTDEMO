//
//  ZFCommunityOutfitBorderViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/6/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCommunityOutfitGoodsCateModel.h"
#import "ZFCommunityOutfitBorderModel.h"
#import "ZFCommunityOutfitBorderCateModel.h"

@interface ZFCommunityOutfitBorderViewModel : NSObject

@property (nonatomic, strong) NSMutableArray<ZFCommunityOutfitGoodsCateModel *>    * goodsCateArray;
@property (nonatomic, strong) NSMutableArray<ZFCommunityOutfitBorderCateModel *>   * bordersCateArray;
@property (nonatomic, strong) NSMutableArray<ZFCommunityOutfitBorderModel *>       * borderArray;


- (void)requestOutfitBorderWithFinished:(void(^)(void))finishedHandel;

// v455只请求边框菜单及数据
- (void)requestOutfitBorderCateID:(NSString *)cateID finished:(void (^)(void))finishedHandel;
// 获取画布URL
- (NSArray *)outfitBorderImageURLs;

// 分类总数
- (NSInteger)goodsCateMenuCount;

// 分类名
- (NSString *)cateTitleWithIndex:(NSInteger)index;

// 分类ID
- (NSString *)cateIDWithIndex:(NSInteger)index;

@end
