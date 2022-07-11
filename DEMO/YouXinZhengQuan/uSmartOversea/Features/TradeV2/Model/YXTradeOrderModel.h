//
//  YXTradeOrderModel.h
//  YouXinZhengQuan
//
//  Created by JC_Mac on 2019/1/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//


//typedef NS_ENUM(NSInteger, YXConditionType) {
//    YXConditionTypeBuy   =   0,       // 条件单买入
//    YXConditionTypeSell  =   1,       // 条件单卖出
//};
//
//typedef NS_ENUM(NSInteger, YXConditionOrderType) {
//    YXConditionOrderTypeEnhanceLimit   =   0,       // 条件单买入
//    YXConditionOrderTypeMarket   =   1,       // 条件单卖出
//};
//
//typedef NS_ENUM(NSInteger, YXTradeOrderType) {
//    YXTradeOrderTypeBuyLong = 0,       // 做多
//    YXTradeOrderTypeShortSell = 1,       // 做空
//};
//
//
//NS_ASSUME_NONNULL_BEGIN
//
//
//@class YXV2Quote;
//@class ConditionExtendDTO;
//
//@interface YXTradeOrderModel : NSObject
//
//@property (nonatomic, copy, nullable) NSString *name;  //股票名(中)
//@property (nonatomic, copy) NSString *enName;  //股票名(英)
//@property (nonatomic, copy) NSString *now; //当前价格
//@property (nonatomic, copy) NSString *pclose; //昨收
//@property (nonatomic, copy) NSString *close; //今收
//@property (nonatomic, copy) NSString *change; //涨跌额
//@property (nonatomic, copy) NSString *roc; //涨跌幅
//@property (nonatomic, copy) NSString *market; //市场
//@property (nonatomic, copy) NSString *symbol; //股票代码
//@property (nonatomic, copy) NSString *priceBase; //除数比
//@property (nonatomic, assign) NSInteger stc; //价位表类型 0:错误/默认类型  1:A类型 3:B类型
//@property (nonatomic, assign) NSInteger priceDivisor; //除数
//@property (nonatomic, assign) NSInteger marketStockType; //股票类型
//@property (nonatomic, assign) BOOL isDerivatives; //是否是衍生品
//@property (nonatomic, assign) NSInteger greyFlag; //是显示暗盘交易界面
//@property (nonatomic, assign) NSInteger greyFlagStock; //是否是暗盘
//@property (nonatomic, assign) NSInteger isInlineWarrant; //是否是界内证
//@property (nonatomic, assign) BOOL isCanPreAfter;
//
//@property (nonatomic, assign) double nowBuyPrice; //当前购买价格
//@property (nonatomic, assign) double conditionPrice;//条件单触发价格
//@property (nonatomic, assign) YXConditionType conditionType; //条件单买入方向
//@property (nonatomic, assign) YXConditionOrderType conditionOrderType;
//
//@property (nonatomic, assign) double amountIncrease; //智能下单 -- 幅度百分比
//
//@property (nonatomic, assign) long long tradeCount; //当前输入数量
//@property (nonatomic, assign) long long normalTradeCount; //其他输入数量
//@property (nonatomic, assign) long long brokenTradeCount; //碎股输入数量
//@property (nonatomic, assign) double minChange; //最小价格变化
//@property (nonatomic, assign) double conMinChange; //条件单最小价格变化
//@property (nonatomic, assign) double minBuyCount;  //最小购买变化
//@property (nonatomic, assign) long long canBuyCount; //最大可买 --> 融资可买
//@property (nonatomic, assign) long long canSellCount; //港股持仓整手可卖/ A股持仓最大可卖
//@property (nonatomic, assign) long long canSellBrokenCount;  //碎股可卖
//
//@property (nonatomic, assign) long long cashEnableAmount; //现金可买数量-包含碎股
//@property (nonatomic, assign) long long cashEnableIntAmount; //现金可买整手数量
//
//@property (nonatomic, copy) NSString * maxPurchasingPower;  //融资购买力
//@property (nonatomic, copy) NSString * cashPurchasingPower;  //现金购买力
//
//@property (nonatomic, assign) BOOL useMargin; // 保证金账户 下单是否用了融资
//
//@property (nonatomic, copy) NSString *showPrice; //展示的当前价格
//@property (nonatomic, copy) NSString *showConPrice; //展示的当前价格
//@property (nonatomic, copy) NSString *showTradeCount; //展示的当前输入数量
//@property (nonatomic, strong) NSArray *positionArray;  //买卖十档
//
//@property (nonatomic, assign) UInt32 contractSize;
//@property (nonatomic, strong) NSNumber *holdId;
//
////基本盘面参数数据 + 买卖十档
//@property (nonatomic, strong, nullable) YXV2Quote *quote;
//
//@property (nonatomic, assign) NSInteger marketStatus; // 0盘中 1盘前 2盘后 3已收盘
//@property (nonatomic, assign) NSInteger currency; //币种
//
//@property (nonatomic, assign) BOOL isRequestCanBuy; //是否请求过最大可买
//
//@property (nonatomic, assign) BOOL isSetedPrice; //是否设置过界面价格
//@property (nonatomic, assign) BOOL isLatestPriceEmpty; //是否有现在价
//
//@property (nonatomic, assign) NSInteger margin; //股票是否可融资
//@property (nonatomic, assign) double marginRatio; //抵押比率
//
///*******改单相关*********/
//@property (nonatomic, copy) NSString *entrustId;  //委托id 改单时使用
//@property (nonatomic, copy) NSString *conId;  //委托id 改单时使用
//@property (nonatomic, assign) NSInteger businessAmount; //成交数量
//@property (nonatomic, assign) NSInteger entrustAmount; //原订单数量
//@property (nonatomic, assign) NSInteger modifiedUpperAmount; //可修改范围的修改上限
//@property (nonatomic, assign) NSInteger modifiedlowerAmount; //可修改范围的修改下限
//@property (nonatomic, copy) NSString *strategyEnddate; //条件单有效时间
//@property (nonatomic, copy) NSString *strategyEnddateDesc; //条件单有效时间
//@property (nonatomic, assign) BOOL isChangeDate; //是否已经更改有效期
//
//@property (nonatomic, assign) CGFloat stopLossRate;
//
//@property (nonatomic, strong, nullable) NSNumber *quotationSource;
//
//// 日内融选中的杠杆比例
//@property (nonatomic, assign) int heaverRatio;
//
//@property (nonatomic, strong, nullable) ConditionExtendDTO *conditionExtendDTO;
//
//@property (nonatomic, strong, nullable) YXV2Quote *assetQuote;
//
//@end

//NS_ASSUME_NONNULL_END
