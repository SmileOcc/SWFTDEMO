//
//  ZFUnlineSimilarViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/7/24.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

// 防止第一页只返回一两个数据, 把size设置大一点
#define kSimilarPageSize 40


@class ZFGoodsModel;
@interface ZFUnlineSimilarViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *resultGoodsArray;  // 相似商品集合

/// 此入口有收藏夹和购物车,都要对接bts
- (void)requestAISimilarMetalDataWithImageURL:(NSString *)url
                                      goodsSn:(NSString *)goods_sn
                                  findsPolicy:(NSString *)findsPolicy
                               completeHandle:(void (^)(void))complateHandle;

- (void)requestGoodsListcompleteHandle:(void(^)(void))complateHandle;

- (NSInteger)totalCount;
- (NSInteger)rowCount;
- (ZFGoodsModel *)goodsModelWithIndex:(NSInteger)index;
- (BOOL)isLastPage;

@end
