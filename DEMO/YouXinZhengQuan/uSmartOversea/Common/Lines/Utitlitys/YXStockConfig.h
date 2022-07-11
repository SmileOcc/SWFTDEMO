
//
//  YXStockConfig.h
//  uSmartOversea
//
//  Created by rrd on 2018/9/3.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#ifndef YXStockConfig_h
#define YXStockConfig_h

////////
//颜色
////////
#define YX_STOCK_HEX_COLOR(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]

#define YX_GREEN_COLOR                  [QMUITheme stockGreenColor]
#define YX_RED_COLOR                    [QMUITheme stockRedColor]
#define YX_GREY_COLOR                   [QMUITheme stockGrayColor]
#define YX_KLINE_CROSS_COLOR            [UIColor colorWithRGB:0x8d8d94]            //十字线颜色

#define YX_KLINE_MA5_COLOR              [UIColor colorWithRGB:0xFF6933]           //ma5线颜色
#define YX_KLINE_MA20_COLOR             [UIColor colorWithRGB:0x0C9CC5]              //ma20线颜色
#define YX_KLINE_MA60_COLOR             [UIColor colorWithRGB:0x944EFF]             //ma60线颜色
#define YX_KLINE_MA120_COLOR            [UIColor colorWithRGB:0xF9A800]             //ma120线颜色
#define YX_KLINE_MA250_COLOR            [UIColor colorWithRGB:0x00C767]             //ma250线颜色

#define YX_KLINE_NOPRICE_COLOR          [UIColor colorWithRGB:0xDE967C]             //现价

#define YX_KLINE_HOldPRICE_COLOR          [UIColor colorWithRGB:0x2F79FF]           //持仓成本

#define YX_TEXT_COLOR2                  [UIColor qmui_colorWithHexString:@"#696969"]

#define YX_FOREGROUND_COLOR             [UIColor whiteColor]

#define YX_KLINE_CANDLE_LINE_WIDTH      1.0 //蜡烛线宽
#define YX_KLINE_VOLUME_LINE_WIDTH      1.0                               //成交量线宽
#define YX_KLINE_CROSS_LINE_WIDTH       1                               //十字线宽度

#define YX_KLINE_MA_LINE_WIDTH          1                               //ma线宽
#define YX_KLINE_REDCANDLE_HELLOW       0                               //红色蜡烛是否空心
#define YX_KLINE_GREENCANDLE_HELLOW     1                               //绿色蜡烛是否空心

#define YX_KLINE_NOWPRICE_COUNT         50                               //均价点的数量

#define kSelectTimeShareingAllTabKey  @"kSelectTimeShareingAllTabKey"

///--------
/// KLine相关
///--------
//Kline种类
typedef NS_ENUM(NSInteger, Y_StockChartCenterViewType) {
    Y_StockChartcenterViewTypeKline = 1, //K线
    Y_StockChartcenterViewTypeTimeLine = 2,  //分时图
    Y_StockChartcenterViewTypeOther = 3  //其他
};

//Accessory指标种类(主线指标)
typedef NS_ENUM(NSInteger, YXStockMainAcessoryStatus) {
    YXStockMainAcessoryStatusMA = 100,    //MA线
    YXStockMainAcessoryStatusBOLL = 200,  //BOLL
    YXStockMainAcessoryStatusEMA = 300,   //EMA
    YXStockMainAcessoryStatusSAR = 400,  //SAR
    YXStockMainAcessoryStatusNone = 500, //无参数指标
    YXStockMainAcessoryStatusUsmart = 600  //盈利通道
};

//Accessory副指标参数(副线指标)
typedef NS_ENUM(NSInteger, YXStockSubAccessoryStatus){

    YXStockSubAccessoryStatus_MAVOL = 10, //MAVOL
    YXStockSubAccessoryStatus_MAVOL_NULL = 11,
    YXStockSubAccessoryStatus_MACD = 20,  //MACD
    YXStockSubAccessoryStatus_MACD_NULL = 21,
    YXStockSubAccessoryStatus_KDJ = 30,  //KDJ
    YXStockSubAccessoryStatus_KDJ_NULL = 31,
    YXStockSubAccessoryStatus_ARBR = 40, //ARBR
    YXStockSubAccessoryStatus_ARBR_NULL = 41,
    YXStockSubAccessoryStatus_CR = 50,  //CR
    YXStockSubAccessoryStatus_CR_NULL = 51,
    YXStockSubAccessoryStatus_DMA = 60,  //DMA
    YXStockSubAccessoryStatus_DMA_NULL = 61,
    YXStockSubAccessoryStatus_EMV = 70,  //EMV
    YXStockSubAccessoryStatus_EMV_NULL = 71,
    YXStockSubAccessoryStatus_RSI = 80,  //RSI
    YXStockSubAccessoryStatus_RSI_NULL = 81,
    YXStockSubAccessoryStatus_WR = 90,  //WR
    YXStockSubAccessoryStatus_WR_NULL = 91,

    YXStockSubAccessoryStatus_None = -1
};

typedef NS_ENUM(NSInteger, YXKlineAdjustType){
    YXKlineAdjustTypeNotAdjust = 0, //不复权
    YXKlineAdjustTypePreAdjust = 1,  //前复权
    YXKlineAdjustTypeAfterAdjust = 2  //后复权
};

typedef NS_ENUM(NSInteger, YXKlineStyleType){
    YXKlineStyleTypeSolid = 0, //实心蜡烛
    YXKlineStyleTypeHollow = 1,  //空心蜡烛
    YXKlineStyleTypeOHLC = 2  //OHLC线（又称美国线）
};

typedef NS_ENUM(NSInteger, YXKlineCYQType){
    YXKlineCYQTypeNormal = 1000, //筹码分布
    YXKlineCYQTypeNone = 1100,  //无筹码
};

//行情分时/盘前盘后类型
typedef NS_ENUM(NSInteger, YXTimeShareLineType) {
    YXTimeShareLineTypeNone = 0,    //无
    YXTimeShareLineTypeAll,   //全部
    YXTimeShareLineTypePre,   //盘前
    YXTimeShareLineTypeIntra, //盘中
    YXTimeShareLineTypeAfter, //盘后
};

//行情分时/K线子类型
typedef NS_ENUM(NSInteger, YXKLineSubType) {
    YXKLineSubTypeNone = 0,    //无
    YXKLineSubTypeOneMin,
    YXKLineSubTypeFiveMin,
    YXKLineSubTypeFifteenMin,
    YXKLineSubTypeThirtyMin,
    YXKLineSubTypeSixtyMin
};


//行情分时/K线类型
typedef NS_ENUM(NSInteger, YXRtLineType) {
    YXRtLineTypeDayTimeLine = 0,  //分时
    YXRtLineTypeFiveDaysTimeLine, //五日
    YXRtLineTypeDayKline, //日K
    YXRtLineTypeWeekKline, //周K
    YXRtLineTypeMonthKline, //月K
    YXRtLineTypeSeasonKline, //季K
    YXRtLineTypeYearKline, //年K
    YXRtLineTypeOneMinKline, //1分
    YXRtLineTypeFiveMinKline, //5分
    YXRtLineTypeFifteenMinKline, //15分
    YXRtLineTypeThirtyMinKline, //30分
    YXRtLineTypeSixtyMinKline  //60分
};

typedef NS_ENUM(NSInteger, YXStockTickType){
    YXStockTickTypeTick = 0, //tick
    YXStockTickTypeStatistics = 1,  //成交统计
};


#endif /* YXStockConfig_h */
