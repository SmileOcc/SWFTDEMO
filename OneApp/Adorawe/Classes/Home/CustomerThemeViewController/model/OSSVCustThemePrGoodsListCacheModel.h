//
//  OSSVCustThemePrGoodsListCacheModel.h
// OSSVCustThemePrGoodsListCacheModel
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger) {
    FooterRefrestStatus_Show,
    FooterRefrestStatus_NoMore,
    FooterRefrestStatus_Hidden,
}FootRefrestStatus;

@interface OSSVCustThemePrGoodsListCacheModel : NSObject

///缓存的列表
@property (nonatomic, strong) NSMutableArray *cacheList;
///缓存的位置
@property (nonatomic, assign) CGPoint cacheOffset;
///当前请求的页数
@property (nonatomic, assign) NSInteger pageIndex;
///频道的sort
@property (nonatomic, copy) NSString *sort;
///缓存的上拉刷新状态
@property (nonatomic, assign) FootRefrestStatus footStatus;
///在menu中的位置
@property (nonatomic, assign) NSInteger index;
///悬浮时的临界位置
@property (nonatomic, assign) CGPoint floatingOffset;

///上拉刷新时调用的接口
-(void)pageOnThePullRequestCustomeId:(NSString *)customeId complation:(void(^)(NSInteger index, NSArray *result))complation;

@end
