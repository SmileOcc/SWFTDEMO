//
//  YXStockDetailUtility.h
//  uSmartOversea
//
//  Created by 姜轶群 on 2019/1/10.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXKLineView.h"
#import "YXStockConfig.h"
#import "YXTradeOrderModel.h"
@class YXUsmartSignalModel;

@class YXV2Quote;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YXUSPosQuoteType) {
    YXUSPosQuoteTypeNone = 0,
    YXUSPosQuoteTypeNsdq,
    YXUSPosQuoteTypeUsNation,
};


@interface YXStockDetailUtility : NSObject


/**
 获取K线复权类型

 @return 复权类型
 */
+ (YXKlineAdjustType)getKLineAdjustType;


/**
 设置K线复权类型

 @param adjustType 复权类型
 */
+ (void)setKlineAdjustType:(YXKlineAdjustType)adjustType;


/**
 获取ma配置参数(如:ma5/20/60/120), 以及显示问题

 @return ma配置数据
 */
+ (NSDictionary<NSString *, NSDictionary<NSString *, id>*> *)getKLineMaSetting;


/**
 重新设置ma指标参数

 @param maSettingDic ma指标参数
 */
+ (void)setMaSetting:(NSDictionary *)maSettingDic;


/**
 K线主指标线

 @return K线主指标线默认配置
 */
+ (YXStockMainAcessoryStatus)kLineMainAccessory;


/**
 重置K线主指标
 */
+ (void)resetKlineMainAccessory:(YXStockMainAcessoryStatus)mainAccessory;

/**
 K线副指标线
 
 @return K线副指标线默认配置
 */
+ (YXStockSubAccessoryStatus)kLineSubAccessory;


/**
 重置K线副指标
 */
+ (void)resetKlineSubAccessory:(YXStockSubAccessoryStatus)subAccessory;


/**
 分时/K线类型
 */
+ (YXRtLineType)rtLineType;


/**
 重置分时/k线类型

 */
+ (void)resetRtLineType:(YXRtLineType)lineType;

/**
 获取盘口展开
 */
+ (BOOL)paraViewExpand;
/**
 重设盘口展开
 */
+ (void)resetParaViewExpand:(BOOL)isExpand;


/**
 获取tick类型

 @return tick类型
 */
+ (YXStockTickType)getStockTickType;

/**
 重设保存tick
 */
+ (void)resetStcokTickType:(YXStockTickType)tickType;



+ (NSDictionary *)mergeUsmartSingalData:(NSArray *)list toTimeLineData:(YXKLineData *)klineData;

+ (void)mergeSingleSignalData:(YXUsmartSignalModel *)info toKlineData:(YXKLine *)lineData;


/**
 深度摆盘是否展示颜色价位,  默认YES
*/
+ (BOOL)showDepthTradeColorPrice;

/**
 设置深度摆盘颜色价位是否展示
*/
+ (void)setDepthTradeColorPrice:(BOOL)show;

/**
 深度摆盘是否展示委托数量,  默认YES
*/
+ (BOOL)showDepthTradeOrderNumber;

/**
 设置深度摆盘委托数量是否展示
*/
+ (void)setDepthTradeOrderNumber:(BOOL)show;

/**
 深度摆盘是否展示同价分布,  默认NO
*/
+ (BOOL)showDepthTradeCombineSamePrice;

/**
 设置深度摆盘同价分布是否展示
*/
+ (void)setDepthTradeCombineSamePrice:(BOOL)show;

/**
 深度摆盘是否展示多空分布,  默认YES
*/
+ (BOOL)showDepthTradePriceDistribution;

/**
 设置深度摆盘多空分布是否展示
*/
+ (void)setDepthTradePriceDistribution:(BOOL)show;

/**
 设置深度摆盘当前档位
*/
+ (NSInteger)getDepthGearNumber;

/**
 设置深度摆盘当前档位
*/
+ (void)setDepthGearNumber:(NSInteger)gear;
/**
 获取买卖档全美的选中, 1 是纳斯达克, 2 是全美
*/
+ (YXUSPosQuoteType)getUsAskBidSelect;

/**
 获取买卖档全美的选中
*/
+ (void)setUsAskBidSelect:(YXUSPosQuoteType)select;


///获取主类型的字符串
+ (NSString *)getRtStringWithType: (YXRtLineType)type;
///获取分时子类型的字符串
+ (NSString *)getTimeShareStringWithType: (YXTimeShareLineType)type;
///获取k线子类型的字符串
+ (NSString *)getSubKlineStringWithType: (YXKLineSubType)type;
///根据k线子类型转主类型
+ (YXRtLineType )getRtKlineWithSubType: (YXKLineSubType)type;
///根据k线主类型转子类型
+ (YXKLineSubType)getRtSubKlineWithType: (YXRtLineType)type;
///判断1日线的类型
+ (YXTimeShareLineType)getTimeShareTypeWithQuote:(YXV2Quote *)quote;
///判断5日线的类型
+ (YXTimeShareLineType)getFiveDayTimeShareTypeWithQuote:(YXV2Quote *)quote;
///是否支持分时的展开
+ (BOOL)canSupportTimelineExpand:(YXV2Quote *)quote;
///重设期权的类型
+ (YXRtLineType)resetOptionKline: (YXRtLineType)type;
///是否是美股的交易时段(盘前盘后盘中)
+ (BOOL)isUsTradingTime:(YXV2Quote *)quote;

@end

NS_ASSUME_NONNULL_END
