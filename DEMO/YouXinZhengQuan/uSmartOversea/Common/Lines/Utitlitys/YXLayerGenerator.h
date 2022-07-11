//
//  YXLayerGeneratorUtility.h
//  uSmartOversea
//
//  Created by rrd on 2018/9/3.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXKLineUtility.h"

/**
 以后各种指标的线 统一管理
 
 */
@interface YXLayerGenerator : NSObject

@property (nonatomic, strong) CAShapeLayer *greenVolumeLayer;               //绿色成交量
@property (nonatomic, strong) CAShapeLayer *redVolumeLayer;                 //红色成交量
@property (nonatomic, strong) CAShapeLayer *greyVolumeLayer;                //灰色成交量
@property (nonatomic, strong) CAShapeLayer *crossLineLayer;                 //十字线

@property (nonatomic, strong) CAShapeLayer *timePriceLineLayer; // 分时/多日线
@property (nonatomic, strong) CAShapeLayer *timeLineFillLayer; // 分时/多日线填充线
@property (nonatomic, strong) CAShapeLayer *averagePriceLayer; //均价layer
@property (nonatomic, strong) CAShapeLayer *yesterdayCloseLayer; //昨收
@property (nonatomic, strong) CAShapeLayer *longPressCirclePriceLayer; //长按时候价格圆圈
@property (nonatomic, strong) CAShapeLayer *longPressCircleAveragePriceLayer;//长安时候均价圆圈

@property (nonatomic, strong) CAShapeLayer *redLineLayer;                   //收盘价大于开盘价
@property (nonatomic, strong) CAShapeLayer *greenLineLayer;                 //开盘价大于收盘价
@property (nonatomic, strong) CATextLayer *maxPriceLayer; //最高价格text
@property (nonatomic, strong) CATextLayer *minPriceLayer; //最低价格text
@property (nonatomic, strong) CAShapeLayer *upArrowLayer; //上箭头
@property (nonatomic, strong) CAShapeLayer *downArrowLayer;  //下箭头

@property (nonatomic, strong) CAShapeLayer *timeLineDotLayer; //分时盘中实心点
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

/**
 MA参数
 */
@property (nonatomic, strong) CAShapeLayer *ma5Layer;                       //ma5线
@property (nonatomic, strong) CAShapeLayer *ma20Layer;                      //ma20线
@property (nonatomic, strong) CAShapeLayer *ma60Layer; //ma60线
@property (nonatomic, strong) CAShapeLayer *ma120Layer; //ma120线
@property (nonatomic, strong) CAShapeLayer *ma250Layer; //ma250线

/**
 EMA参数
 */
@property (nonatomic, strong) CAShapeLayer *ema5Layer;                      //ema5线
//@property (nonatomic, strong) CAShapeLayer *ema10Layer;                     //ema10线
@property (nonatomic, strong) CAShapeLayer *ema20Layer;                     //ema20线
@property (nonatomic, strong) CAShapeLayer *ema60Layer;                     //ema60线
@property (nonatomic, strong) CAShapeLayer *ema120Layer;                     //ema120线
@property (nonatomic, strong) CAShapeLayer *ema250Layer;                     //ema250线

/**
 boll线
 */
@property (nonatomic, strong) CAShapeLayer *boll_MBLayer;
@property (nonatomic, strong) CAShapeLayer *boll_UPLayer;
@property (nonatomic, strong) CAShapeLayer *boll_DNLayer;


/**
 sar线
 */
@property (nonatomic, strong) CAShapeLayer *sar_redLayer;
@property (nonatomic, strong) CAShapeLayer *sar_greenLayer;
@property (nonatomic, strong) CAShapeLayer *sar_grayLayer;


/**
    MACD线
 */
@property (nonatomic, strong) CAShapeLayer *redMACDLayer;
@property (nonatomic, strong) CAShapeLayer *greenMACDLayer;
@property (nonatomic, strong) CAShapeLayer *difLayer;
@property (nonatomic, strong) CAShapeLayer *deaLayer;

/**
    KDJ线
 */
@property (nonatomic, strong) CAShapeLayer *kdj_k_layer;
@property (nonatomic, strong) CAShapeLayer *kdj_d_layer;
@property (nonatomic, strong) CAShapeLayer *kdj_j_layer;


/**
    RSI线
 */
@property (nonatomic, strong) CAShapeLayer *RSI_6_layer;
@property (nonatomic, strong) CAShapeLayer *RSI_12_layer;
@property (nonatomic, strong) CAShapeLayer *RSI_24_layer;

/**
   DMA线
*/
@property (nonatomic, strong) CAShapeLayer *D_DIF_layer;
@property (nonatomic, strong) CAShapeLayer *D_AMA_layer;

/**
   ARBR线
*/
@property (nonatomic, strong) CAShapeLayer *AR_layer;
@property (nonatomic, strong) CAShapeLayer *BR_layer;

/**
    WR线
 */
 @property (nonatomic, strong) CAShapeLayer *WR1_layer;
 @property (nonatomic, strong) CAShapeLayer *WR2_layer;

/**
   EMV线
*/
@property (nonatomic, strong) CAShapeLayer *EMV_layer;
@property (nonatomic, strong) CAShapeLayer *AEMV_layer;

/**
   CR线
*/
@property (nonatomic, strong) CAShapeLayer *CR_layer;
@property (nonatomic, strong) CAShapeLayer *CR1_layer;
@property (nonatomic, strong) CAShapeLayer *CR2_layer;
@property (nonatomic, strong) CAShapeLayer *CR3_layer;
@property (nonatomic, strong) CAShapeLayer *CR4_layer;

/**
 VOLMUN参数
 */
@property (nonatomic, strong) CAShapeLayer *volumn5_Layer;
@property (nonatomic, strong) CAShapeLayer *volumn10_Layer;
@property (nonatomic, strong) CAShapeLayer *volumn20_Layer;

/**
   usmart线
*/
@property (nonatomic, strong) CAShapeLayer *usmartUp_layer;
@property (nonatomic, strong) CAShapeLayer *usmartDown_layer;

@property (nonatomic, strong) CAShapeLayer *usmartBuy_layer;
@property (nonatomic, strong) CAShapeLayer *usmartSell_layer;

/**
    网格线
*/
@property (nonatomic, strong) CAShapeLayer *horizonLayer; //水平网格线
@property (nonatomic, strong) CAShapeLayer *verticalLayer;  //数值网格线

/**
    副指标网格线
*/
@property (nonatomic, strong) CAShapeLayer *subHorizonLayer; //水平网格线
@property (nonatomic, strong) CAShapeLayer *subVerticalLayer;  //数值网格线

@property (nonatomic, strong) CALayer *subMidHorizonLayer;  //数值网格线


@property (nonatomic, strong) CAShapeLayer *nowPrice_Layer;
@property (nonatomic, strong) CAShapeLayer *holdPrice_Layer;

@property (nonatomic, strong) CAShapeLayer *usMarketDayAndNight_Layer;

@end
