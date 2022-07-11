//
//  YXTradeAskBidViewModel.h
//  YouXinZhengQuan
//
//  Created by youxin on 2021/6/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXTableViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@class YXQuoteRequest;
@interface YXTradeAskBidViewModel : YXTableViewModel
//加载深度摆盘
@property (nonatomic, strong) RACCommand *loadDepthOrderDataCommand;

@property (nonatomic, strong) RACSubject *loadDepthOrderSubject;

//加载深度摆盘多空分布
@property (nonatomic, strong) RACCommand *loadDepthChartDataCommand;

@property (nonatomic, strong) RACSubject *loadDepthChartSubject;

@property (nonatomic, strong, nullable) YXQuoteRequest *depthOrderRequset;
@property (nonatomic, strong, nullable) YXQuoteRequest *depthChartRequset;

- (void)cancelRequest;
- (void)cancelTimer;
@end

NS_ASSUME_NONNULL_END
