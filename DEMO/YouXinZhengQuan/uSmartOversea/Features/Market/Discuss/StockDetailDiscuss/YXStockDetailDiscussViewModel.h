//
//  YXStockDetailDiscussViewModel.h
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailDiscussViewModel : YXViewModel

@property (nonatomic, strong) NSString * symbol;
@property (nonatomic, strong) NSString * market;
@property (nonatomic, strong) NSString * name;

// 股票是否支持猜涨跌
@property (nonatomic, assign) BOOL supportGuess;

/// 热门评论
@property (nonatomic, strong) NSMutableArray *hotCommentList;

@end

NS_ASSUME_NONNULL_END
