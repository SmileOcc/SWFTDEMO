//
//  YXSmartOrderListViewModel.h
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class YXConditionOrderModel;

@interface YXSmartOrderListViewModel : YXTableViewModel

@property (nonatomic, strong, readonly) RACCommand *didClickQuote;
@property (nonatomic, strong, readonly) RACCommand *didClickChange;
@property (nonatomic, strong, readonly) RACCommand *didClickStop;

@property (nonatomic, strong, readonly) RACCommand *didClickSmartOneMore;   //再来一单
@property (nonatomic, strong, readonly) RACCommand *didClickSmartDetail;    //查看触发订单
@property (nonatomic, assign) BOOL isOrder; //是否在下单页
@property (nonatomic, strong, readonly) RACCommand *changeSmartOneMore;    //「智能交易」页-点了「再来一单」，切换

@property (nonatomic, strong) RACCommand *validatePwd;


@property (nonatomic, strong, readonly) NSMutableArray *tradingOrders;
@property (nonatomic, strong, readonly) NSMutableArray *doneOrders;

@property (nonatomic, assign) BOOL isAll;

@property (nonatomic, assign) NSInteger pageSource; //页面来源 1-港股交易， 2-美股交易， 3-交易主页

@property (nonatomic, assign) int marketType;

@property (nonatomic, strong) NSString *securityType;

@property (nonatomic, strong) NSString *orderStatus;

@property (nonatomic, strong) NSString *orderType;

@property (nonatomic, strong) NSString *beginDate;

@property (nonatomic, strong) NSString *endDate;

@property (nonatomic, strong) NSString *stockCode;

@property (nonatomic, strong) NSString *transactionTime;

@property (nonatomic, assign) NSInteger exchangeType;

@end

NS_ASSUME_NONNULL_END
