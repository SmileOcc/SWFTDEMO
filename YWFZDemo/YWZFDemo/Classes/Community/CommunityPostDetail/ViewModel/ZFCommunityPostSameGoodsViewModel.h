//
//  ZFCommunityPostSameGoodsViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/6/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFAnalytics.h"

@class ZFCommunityGoodsInfosModel;
@interface ZFCommunityPostSameGoodsViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *goodsInfoArray;

//统计
@property (nonatomic, strong) ZFAnalyticsProduceImpression    *analyticsProduceImpression;

+ (void)requesttagLabelReviewID:(NSString *)reviewID
                 finishedHandle:(void (^)(NSArray *tagDataArray))finishedHandle;

- (void)requestTheSameGoodsWithReviewID:(NSString *)reviewID
                            isFirstPage:(BOOL)isFirstPage
                                  catId:(NSString *)catId
                         finishedHandle:(void (^)(NSDictionary *pageInfo))finishedHandle;

// ************** 获取数据 ***********
- (NSInteger)dataCount;
- (NSInteger)totalCount;
- (NSString *)goodsTitleWithIndex:(NSInteger)index;
- (NSString *)goodsImageWithIndex:(NSInteger)index;
- (NSString *)goodsPriceWithIndex:(NSInteger)index;
- (NSString *)goodsIDWithIndex:(NSInteger)index;
- (NSString *)goodsSNWithIndex:(NSInteger)index;
- (BOOL)isTheSameWithIndex:(NSInteger)index;
- (CGSize)cellSizeWithIndex:(NSInteger)index;
- (BOOL)isRequestSuccess;

// 统计
- (void)showAnalysicsWithCateName:(NSString *)cateName;
- (void)clickAnalysicsWithCateName:(NSString *)cateName index:(NSInteger)index;

@end
