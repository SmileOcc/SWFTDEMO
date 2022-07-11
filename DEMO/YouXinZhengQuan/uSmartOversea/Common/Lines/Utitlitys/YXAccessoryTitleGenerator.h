//
//  YXAccessoryTitleGenerator.h
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/10/26.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YXKLine;

@interface YXAccessoryTitleGenerator : NSObject

/**
 分时线长按时价格
 */
@property (nonatomic, strong) QMUILabel *timeLineCrossingPriceLabel;

/**
 分时线长按时涨跌幅
 */
@property (nonatomic, strong) QMUILabel *timeLineCrossingRocLabel;




/**
 MA标签
 */
@property (nonatomic, strong) UILabel *MALabel;

/**
 BOLL标签
 */
@property (nonatomic, strong) UILabel *BOLLLabel;


/**
 EMA标签
 */
@property (nonatomic, strong) UILabel *EMALabel;


@property (nonatomic, strong) UIView *EMAView;

/**
 SAR标签
 */
@property (nonatomic, strong) UILabel *SARLabel;

/**
 MACD标签
 */
@property (nonatomic, strong) UILabel *MACDTitleLabel;

/**
 volume标签
 */
@property (nonatomic, strong) UILabel *MACD_VOL_Label;

/**
 RSI标签
 */
@property (nonatomic, strong) UILabel *RSILabel;

/**
 KDJ标签
 */
@property (nonatomic, strong) UILabel *KDJLabel;
/**
 DMA标签
 */
@property (nonatomic, strong) UILabel *DMALabel;
/**
 ARBR标签
 */
@property (nonatomic, strong) UILabel *ARBRLabel;
/**
 WR标签
 */
@property (nonatomic, strong) UILabel *WRLabel;

/**
 EMV标签
 */
@property (nonatomic, strong) UILabel *EMVLabel;

/**
 CR标签
 */
@property (nonatomic, strong) UILabel *CRLabel;

/**
    usmart标签
 */
@property (nonatomic, strong) UILabel *usmartLabel;

/**
 K线crossing对应的price价格
 */
@property (nonatomic, strong) QMUILabel *crossingLinePriceLabel;

/**
 赋值的model
 */
@property (nonatomic, strong) YXKLine  *klineModel;
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, strong) UILabel *startDateLabel;

@property (nonatomic, strong) UILabel *endDateLabel;

@property (nonatomic, strong) UILabel *currentDateLabel;

@property (nonatomic, strong) UILabel *pclosePriceLabel;
@property (nonatomic, strong) UILabel *kLineSecondMaxPriceLabel;
@property (nonatomic, strong) UILabel *kLineSecondMinPriceLabel;
@property (nonatomic, strong) UILabel *kLineMaxPriceLabel;
@property (nonatomic, strong) UILabel *kLineMinPriceLabel;
@property (nonatomic, strong) UILabel *kLineThirdMaxPriceLabel;
@property (nonatomic, strong) UILabel *kLineThirdMinPriceLabel;

@property (nonatomic, strong) UILabel *pcloseRatoLabel;
@property (nonatomic, strong) UILabel *kLineSecondMaxRatoLabel;
@property (nonatomic, strong) UILabel *kLineSecondMinRatoLabel;
@property (nonatomic, strong) UILabel *kLineMaxRatoLabel;
@property (nonatomic, strong) UILabel *kLineMinRatoLabel;
@property (nonatomic, strong) UILabel *kLineThirdMaxRatoLabel;
@property (nonatomic, strong) UILabel *kLineThirdMinRatoLabel;

// 副指标
@property (nonatomic, strong) UILabel *subMidPriceLabel;
@property (nonatomic, strong) UILabel *subMaxPriceLabel;
@property (nonatomic, strong) UILabel *subMinPriceLabel;

// 是否是港股指数
@property (nonatomic, assign) BOOL isHKIndex;
// 是否横屏
@property (nonatomic, assign) BOOL isLandscape;

@end

