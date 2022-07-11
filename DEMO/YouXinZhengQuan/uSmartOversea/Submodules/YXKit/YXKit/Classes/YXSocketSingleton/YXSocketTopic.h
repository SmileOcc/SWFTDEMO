//
//  YXTopicModel.h
//  YouXinZhengQuan
//
//  Created by ellison on 2018/11/7.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "proto.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YXSocketMarketStatus){
    /**
     *  日内
     */
    YXSocketMarketStatusIntraday,
    /**
     *  盘前
     */
    YXSocketMarketStatusPre,
    /**
     *  盘后
     */
    YXSocketMarketStatusAfter,
};


typedef NS_ENUM(NSUInteger, YXSocketDepthType){
    /**
     *  普通无合并摆盘
     */
    YXSocketDepthTypeNone,
    /**
     *  同价合并摆盘
     */
    YXSocketDepthTypeMerge,
    /**
     *  多空分布
     */
    YXSocketDepthTypeChart,
};

typedef NS_ENUM(NSUInteger, YXSocketGreyMarketType){
    /**
     *  辉立暗盘
     */
    YXSocketGreyMarketTypePhillip = 1,
    /**
     *  富途暗盘
     */
    YXSocketGreyMarketTypeFutu = 2,
};

typedef NS_ENUM(NSUInteger, YXSocketExtraQuote){
    /**
     *  无额外
     */
    YXSocketExtraQuoteNone = 0,
    /**
     *  全美行情
     */
    YXSocketExtraQuoteUsNation = 1,
    /**
     *  富途行情
     */
    YXSocketExtraQuoteFutu = 2,
};

/**
 推送类别，YXSocketPushType
 - rt： 实时
 - ts： 分时
 - tk： 逐笔
 - kl： K线
 - cap： 资金流向
 - tspre:   盘前分时
 - tsafter: 盘后分时
 - tkpre:   盘前逐笔
 - tkafter: 盘后逐笔
 - arcaob: 深度摆盘
 - pos: 买卖档
 - broker: 经纪商
 */
typedef NS_ENUM(NSUInteger, YXSocketPushType){
    YXSocketPushTypeNone = 0,
    YXSocketPushTypeRt,
    YXSocketPushTypeTs,
    YXSocketPushTypeTk,
    YXSocketPushTypeKl,
    YXSocketPushTypeCap,
    YXSocketPushTypeTsPre,
    YXSocketPushTypeTsAfter,
    YXSocketPushTypeTkPre,
    YXSocketPushTypeTkAtfer,
    YXSocketPushTypeArca,
    YXSocketPushTypeArcaChart,
    YXSocketPushTypePos,
    YXSocketPushTypeBroker,
    YXSocketPushTypeSgArca,
    YXSocketPushTypeSgArcaChart,
};

/**
 Topic字符串
 拼接规则
 - q.rt.version.market.symbol.scene
 - q.ts.version.market.symbol
 - q.tk.version.market.symbol
 - q.kl.version.market.symbol.kLineType.direction
 - q.cap.version.market.symbol.capFlowType
 */
@interface YXSocketTopic : NSObject



/**
  第一个字段 默认q
 */
@property (nonatomic, copy, readonly) NSString *firstQ;

/**
 推送类别，API_CLIENTPushType
 */
@property (nonatomic, assign, readonly) YXSocketPushType pushType;

/**
 第三个字段 版本 v2
 */
@property (nonatomic, assign, readonly) NSString *version;


/**
 市场类别，OBJECT_MARKETMarketId
 [sh, sz, hk, us, usoption]
 */
@property (nonatomic, assign, readonly) OBJECT_MARKETMarketId marketID;

/**
 股票代码
 */
@property (nonatomic, copy, readonly) NSString *symbol;

/**
 额外的行情
 */
@property (nonatomic, assign) YXSocketExtraQuote extraQuote;
- (NSString *)getExtraQuoteStr;

/**
 实时(rt)类型，OBJECT_QUOTEQuoteScene
 
 - full： 全量股票信息，全量行情
 - mobile_brf1： 移动端列表, 股票信息包含基础静态信息，行情包含现价、涨跌、涨跌价
 - desktop_brf1： 客户端列表，股票信息包含基础静态信息，全量行情
 - CUSTOM_FLAG ：自定义方式
 */
@property (nonatomic, assign, readonly) OBJECT_QUOTEQuoteScene scene;

/**
 k线(kl)类型，OBJECT_QUOTEKLineType
 
 [m1, m5, m10, m30, m60, d, w, mn1, mn3, mn6, y]
 */
@property (nonatomic, assign, readonly) OBJECT_QUOTEKLineType kLineType;

/**
 k线(kl)复权类型，OBJECT_QUOTEKLineDirection
 [fw, bw, none]
 */
@property (nonatomic, assign, readonly) OBJECT_QUOTEKLineDirection direction;

/**
 资金流向(cap)类型，OBJECT_QUOTECapFlowType
 [d, 5d]
 */
@property (nonatomic, assign, readonly) OBJECT_QUOTECapFlowType capFlowType;

/**
 深度摆盘类型
 */
@property (nonatomic, assign) YXSocketDepthType depthType;


+ (instancetype)topicWithString:(NSString *)topicString;

+ (NSArray<NSString *> *)stringArrayWithTopics:(NSArray<YXSocketTopic *> *)topics;

- (NSString *)topicDescription;

- (NSString *)market;

- (NSString *)getExtraQuoteStr;

/**
 实时订阅   q.rt.v2.market.symbol.scene  /  q.rt.v2.market.symbol.scene.futu
 */
+ (instancetype)topicRtWithMarket:(NSString *)market symbol:(NSString *)symbol scene:(OBJECT_QUOTEQuoteScene)scene;
+ (instancetype)topicRtWithMarket:(NSString *)market symbol:(NSString *)symbol scene:(OBJECT_QUOTEQuoteScene)scene extraQuote: (YXSocketExtraQuote)extraQuote;

/**
 分时订阅   q.ts.v2.market.symbol  /  q.ts.v2.market.symbol.futu
 */
+ (instancetype)topicTsWithMarket:(NSString *)market symbol:(NSString *)symbol DEPRECATED_MSG_ATTRIBUTE("Please use [YXSocketTopic topicTsWithMarket:symbol:status:]");

/**
 盘前分时订阅   q.tspre.v2.market.symbol
 盘后分时订阅   q.tsafter.v2.market.symbol
 */
+ (instancetype)topicTsWithMarket:(NSString *)market symbol:(NSString *)symbol status:(YXSocketMarketStatus)status;
+ (instancetype)topicTsWithMarket:(NSString *)market symbol:(NSString *)symbol status:(YXSocketMarketStatus)status extraQuote: (YXSocketExtraQuote)extraQuote;

/**
 逐笔订阅   q.tk.v2.market.symbol  /  q.tk.v2.market.symbol.futu
 */
+ (instancetype)topicTkWithMarket:(NSString *)market symbol:(NSString *)symbol DEPRECATED_MSG_ATTRIBUTE("Please use [YXSocketTopic topicTkWithMarket:symbol:status:]");

/**
 盘前逐笔订阅   q.tkpre.v2.market.symbol
 盘后逐笔订阅   q.tkafter.v2.market.symbol
 */
+ (instancetype)topicTkWithMarket:(NSString *)market symbol:(NSString *)symbol status:(YXSocketMarketStatus)status;
+ (instancetype)topicTkWithMarket:(NSString *)market symbol:(NSString *)symbol status:(YXSocketMarketStatus)status extraQuote: (YXSocketExtraQuote)extraQuote;

/**
 K线订阅   q.kl.v2.market.symbol.kLineType.direction   /  q.kl.v2.market.symbol.kLineType.direction.futu
 */
+ (instancetype)topicKlWithMarket:(NSString *)market symbol:(NSString *)symbol type:(OBJECT_QUOTEKLineType)kLineType direction:(OBJECT_QUOTEKLineDirection)direction;
+ (instancetype)topicKlWithMarket:(NSString *)market symbol:(NSString *)symbol type:(OBJECT_QUOTEKLineType)kLineType direction:(OBJECT_QUOTEKLineDirection)direction extraQuote: (YXSocketExtraQuote)extraQuote;

/**
 资金流订阅  q.cap.market.symbol.capFlowType
 */
+ (instancetype)topicCapWithMarket:(NSString *)market symbol:(NSString *)symbol type:(OBJECT_QUOTECapFlowType)capFlowType;

/**
 深度摆盘  q.arcaob.v2.MARKET.CODE   /  q.arcaob.v2.MARKET.CODE.merge /  q.arcaob.v2.MARKET.CODE.chart
 */
+ (instancetype)topicDepthWithMarket:(NSString *)market symbol:(NSString *)symbol type:(YXSocketDepthType)type;

/**
 买卖档  q.ob.v2.market.symbol.full /  q.ob.v2.market.symbol.full.futu
 */
+ (instancetype)topicPosWithMarket:(NSString *)market symbol:(NSString *)symbol extraQuote: (YXSocketExtraQuote)extraQuote;
/**
 经纪商  q.bq.v2.market.symbol.full /  q.bq.v2.market.symbol.full.futu
 */
+ (instancetype)topicBrokerWithMarket:(NSString *)market symbol:(NSString *)symbol extraQuote: (YXSocketExtraQuote)extraQuote;


@end

NS_ASSUME_NONNULL_END
