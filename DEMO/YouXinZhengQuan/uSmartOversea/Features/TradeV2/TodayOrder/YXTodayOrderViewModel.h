//
//  YXTodayOrderViewModel.h
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
 
#import "YXTableViewModel.h"
@class YXOrderModel;
@class YXOrderResponseModel;
NS_ASSUME_NONNULL_BEGIN

@interface YXTodayOrderViewModel : YXTableViewModel

@property (nonatomic, strong, readonly) RACCommand *didClickQuote;
@property (nonatomic, strong, readonly) RACCommand *didClickTrade;
@property (nonatomic, strong, readonly) RACCommand *didClickChange;
@property (nonatomic, strong, readonly) RACCommand *didClickRecall; //「撤单」的请求
@property (nonatomic, strong, readonly) RACCommand *didClickOrderDetail;    //订单详情
@property (nonatomic, strong, readonly) RACCommand *bondCancel;

@property (nonatomic, strong, readonly) RACCommand *pwdSucceedForUndoEntrust; //对撤单，密码输入成功

@property (nonatomic, strong, readonly) RACCommand *didChange; //更改了订单

@property (nonatomic, strong) RACCommand *validatePwd;

@property (nonatomic, strong, readonly) NSMutableArray *tradingOrders;
@property (nonatomic, strong, readonly) NSMutableArray *doneOrders;
@property (nonatomic, strong, readonly) NSMutableArray *bondTradingOrders;
@property (nonatomic, strong, readonly) NSMutableArray *bondDoneOrders;
@property (nonatomic, assign) BOOL isOrder;
@property (nonatomic, strong) RACCommand *changeTrade;//切换交易股票

@property (nonatomic, assign) NSInteger exchangeType;
@property (nonatomic, assign) NSString *enEntrustStatus;
@property (nonatomic, assign) NSString *categoryStatus; //sg参数


@property (nonatomic, assign) NSString *market; //sg参数


@property (nonatomic, assign) NSInteger orderCount;

@property (nonatomic, assign) NSInteger pageSource; //页面来源 1-港股交易， 2-美股交易，, 3-交易主页, 4.A股交易

@property (nonatomic, assign) BOOL isAssetPage; // 是否在资产页

- (void)updateWithExchangeType:(NSInteger)exchangeType;

- (void)tapBondTitleCell:(NSIndexPath *)indexPath;
//今日订单 ---正在交易订单数
- (NSInteger)tradingOrderCount;
//今日订单 ---已成交订单数
- (NSInteger)doneOrderCount;

// 是否是快捷交易
@property (nonatomic, assign) BOOL isShortcut;
// 股票市场代码
@property (nonatomic, strong) NSString *marketSymblo;

@property (nonatomic, assign) BOOL isIntraday;

@property (nonatomic, assign) BOOL isShortSell;

//订单为空时是否展示图片
@property (nonatomic ,assign) BOOL needShowEmptyImage;

@property (nonatomic ,strong) YXOrderResponseModel *todayOrderResModel;

@end

NS_ASSUME_NONNULL_END
