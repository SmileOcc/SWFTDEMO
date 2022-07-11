//
//  YXLayerGeneratorUtility.m
//  uSmartOversea
//
//  Created by rrd on 2018/9/3.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXLayerGenerator.h"
#import "YXStockConfig.h"
#import <YYCategories/YYCategories.h>

@implementation YXLayerGenerator

- (CAShapeLayer *)redLineLayer {
    if (!_redLineLayer) {
        _redLineLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_RED_COLOR fillColor:YX_RED_COLOR lineWidth:YX_KLINE_CANDLE_LINE_WIDTH lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _redLineLayer;
}

- (CAShapeLayer *)greenLineLayer {
    if (!_greenLineLayer) {
        _greenLineLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_GREEN_COLOR fillColor:(YX_KLINE_REDCANDLE_HELLOW ? [UIColor clearColor] : YX_GREEN_COLOR ) lineWidth:YX_KLINE_CANDLE_LINE_WIDTH lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _greenLineLayer;
}

- (CAShapeLayer *)crossLineLayer {
    if (!_crossLineLayer) {
        UIColor *color = [QMUITheme textColorLevel3];
        _crossLineLayer = [YXKLineUtility shapeLayerWithStokeColor:color fillColor:[UIColor clearColor] lineWidth:YX_KLINE_CROSS_LINE_WIDTH lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
        _crossLineLayer.lineDashPattern = @[@(4), @(4)];
    }
    return _crossLineLayer;
}

- (CAShapeLayer *)greenVolumeLayer {
    if (!_greenVolumeLayer) {
        _greenVolumeLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_GREEN_COLOR fillColor:YX_GREEN_COLOR lineWidth:0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _greenVolumeLayer;
}


- (CAShapeLayer *)redVolumeLayer {
    if (!_redVolumeLayer) {
        _redVolumeLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_RED_COLOR fillColor:YX_RED_COLOR lineWidth: 0  lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _redVolumeLayer;
}

- (CAShapeLayer *)greyVolumeLayer {
    if (!_greyVolumeLayer) {
        _greyVolumeLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_GREY_COLOR fillColor:YX_GREY_COLOR lineWidth: 0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _greyVolumeLayer;
}


/**
 ma
 */
- (CAShapeLayer *)ma5Layer {
    if (!_ma5Layer) {
        _ma5Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA5_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _ma5Layer;
}

- (CAShapeLayer *)ma20Layer {
    if (!_ma20Layer) {
        _ma20Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA20_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _ma20Layer;
}

- (CAShapeLayer *)ma60Layer {
    if (!_ma60Layer) {
        _ma60Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA60_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _ma60Layer;
}

- (CAShapeLayer *)ma120Layer {
    if (!_ma120Layer) {
        _ma120Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA120_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _ma120Layer;
}

- (CAShapeLayer *)ma250Layer {
    if (!_ma250Layer) {
        _ma250Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA250_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _ma250Layer;
}

/**
 ema
 */
- (CAShapeLayer *)ema5Layer {
    if (!_ema5Layer) {
        _ema5Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA5_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _ema5Layer;
}


- (CAShapeLayer *)ema20Layer {
    if (!_ema20Layer) {
        _ema20Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA20_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _ema20Layer;
}

- (CAShapeLayer *)ema60Layer {
    if (!_ema60Layer) {
        _ema60Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA60_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _ema60Layer;
}

- (CAShapeLayer *)ema120Layer {
    if (!_ema120Layer) {
        _ema120Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA120_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _ema120Layer;
}

- (CAShapeLayer *)ema250Layer {
    if (!_ema250Layer) {
        _ema250Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA250_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _ema250Layer;
}

- (CAShapeLayer *)boll_MBLayer{
    
    if (!_boll_MBLayer) {
        _boll_MBLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA5_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _boll_MBLayer;
    
}

- (CAShapeLayer *)boll_UPLayer{
    
    if (!_boll_UPLayer) {
        _boll_UPLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA20_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _boll_UPLayer;
    
}

- (CAShapeLayer *)boll_DNLayer{
    
    if (!_boll_DNLayer) {
        _boll_DNLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA60_COLOR fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _boll_DNLayer;
    
}

- (CAShapeLayer *)sar_redLayer{
    
    if (!_sar_redLayer) {
      _sar_redLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_RED_COLOR fillColor:[UIColor clearColor] lineWidth:0.2 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _sar_redLayer;
    
}

- (CAShapeLayer *)sar_greenLayer{
    
    if (!_sar_greenLayer) {
        _sar_greenLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_GREEN_COLOR fillColor:[UIColor clearColor] lineWidth:0.2 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _sar_greenLayer;
    
}

- (CAShapeLayer *)redMACDLayer{
    
    if (!_redMACDLayer) {
        _redMACDLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_RED_COLOR fillColor:YX_RED_COLOR lineWidth:0.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _redMACDLayer;
    
}

- (CAShapeLayer *)greenMACDLayer{
    
    if (!_greenMACDLayer) {
       _greenMACDLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_GREEN_COLOR fillColor:YX_GREEN_COLOR lineWidth:0.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _greenMACDLayer;
    
}

- (CAShapeLayer *)difLayer{
    
    if (!_difLayer) {
        _difLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA5_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _difLayer;
    
}

- (CAShapeLayer *)deaLayer{
    
    if (!_deaLayer) {
        _deaLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA20_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _deaLayer;
    
}

- (CAShapeLayer *)kdj_k_layer{
    
    if (!_kdj_k_layer) {
        _kdj_k_layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA5_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _kdj_k_layer;
    
}

- (CAShapeLayer *)kdj_d_layer{
    
    if (!_kdj_d_layer) {
        _kdj_d_layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA20_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _kdj_d_layer;
    
}

- (CAShapeLayer *)kdj_j_layer{
    
    if (!_kdj_j_layer) {
        _kdj_j_layer = [YXKLineUtility shapeLayerWithStokeColor: YX_KLINE_MA60_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _kdj_j_layer;
    
}

- (CAShapeLayer *)RSI_6_layer{
    
    if (!_RSI_6_layer) {
        _RSI_6_layer = [YXKLineUtility shapeLayerWithStokeColor: YX_KLINE_MA5_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _RSI_6_layer;
    
}

- (CAShapeLayer *)RSI_12_layer{
    
    if (!_RSI_12_layer) {
        _RSI_12_layer = [YXKLineUtility shapeLayerWithStokeColor: YX_KLINE_MA20_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _RSI_12_layer;
    
}

- (CAShapeLayer *)RSI_24_layer{
    
    if (!_RSI_24_layer) {
        _RSI_24_layer = [YXKLineUtility shapeLayerWithStokeColor: YX_KLINE_MA60_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _RSI_24_layer;
    
}

- (CAShapeLayer *)timePriceLineLayer{
    
    if (!_timePriceLineLayer) {
        _timePriceLineLayer = [YXKLineUtility shapeLayerWithStokeColor:[UIColor colorWithRGB:0x414FFF] fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapRound lineJoin:kCALineJoinRound];
    }
    return _timePriceLineLayer;
    
}

- (CAShapeLayer *)timeLineFillLayer{
    if (!_timeLineFillLayer) {
        _timeLineFillLayer = [YXKLineUtility shapeLayerWithStokeColor:[UIColor redColor] fillColor:[UIColor colorWithRGB:0x0484CE alpha:0.4] lineWidth:0 lineCap:kCALineCapRound lineJoin:kCALineJoinRound];
    }
    return _timeLineFillLayer;
}

- (CAShapeLayer *)averagePriceLayer{
    if (!_averagePriceLayer) {
        _averagePriceLayer = [YXKLineUtility shapeLayerWithStokeColor:[UIColor colorWithRGB:0xF9A800] fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapRound lineJoin:kCALineJoinRound];
    }
    return _averagePriceLayer;
    
}

- (CAShapeLayer *)yesterdayCloseLayer{
    
    if (!_yesterdayCloseLayer) {
        _yesterdayCloseLayer =  [YXKLineUtility shapeLayerWithStokeColor:[UIColor colorWithRGB:0xC0C5FF] fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapRound lineJoin:kCALineJoinRound];
    }
    return _yesterdayCloseLayer;
    
}

- (CAShapeLayer *)longPressCirclePriceLayer{
    
    if (!_longPressCirclePriceLayer) {
        _longPressCirclePriceLayer = [YXKLineUtility shapeLayerWithStokeColor:[UIColor colorWithRGB:0x414FFF] fillColor:YX_FOREGROUND_COLOR lineWidth:0.8 lineCap:kCALineCapRound lineJoin:kCALineJoinRound];
    }
    return _longPressCirclePriceLayer;
    
}

- (CAShapeLayer *)longPressCircleAveragePriceLayer{
    
    if (!_longPressCircleAveragePriceLayer) {
        _longPressCircleAveragePriceLayer = [YXKLineUtility shapeLayerWithStokeColor:[UIColor colorWithRGB:0xF9A800] fillColor:YX_FOREGROUND_COLOR lineWidth:0.8 lineCap:kCALineCapRound lineJoin:kCALineJoinRound];
    }
    return _longPressCircleAveragePriceLayer;
}

- (CAShapeLayer *)timeLineDotLayer {
    
    if (!_timeLineDotLayer) {
        _timeLineDotLayer = [YXKLineUtility shapeLayerWithStokeColor:[UIColor colorWithRGB:0x414FFF] fillColor:[UIColor colorWithRGB:0x414FFF] lineWidth:0 lineCap:kCALineCapRound lineJoin:kCALineJoinRound];
    }
    return _timeLineDotLayer;
    
}


- (CAShapeLayer *)upArrowLayer {
    if (!_upArrowLayer) {
        _upArrowLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_TEXT_COLOR2 fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _upArrowLayer;
}

- (CAShapeLayer *)downArrowLayer {
    if (!_downArrowLayer) {
        _downArrowLayer = [YXKLineUtility shapeLayerWithStokeColor:YX_TEXT_COLOR2 fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _downArrowLayer;
}

- (CAShapeLayer *)horizonLayer{
    if (!_horizonLayer) {
        UIColor *color = QMUITheme.separatorLineColor;
         _horizonLayer = [YXKLineUtility shapeLayerWithStokeColor:color fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _horizonLayer;
}

- (CAShapeLayer *)verticalLayer{
    if (!_verticalLayer) {
        UIColor *color = QMUITheme.separatorLineColor;
        _verticalLayer = [YXKLineUtility shapeLayerWithStokeColor:color fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _verticalLayer;
}

- (CAShapeLayer *)subHorizonLayer{
    if (!_subHorizonLayer) {
        UIColor *color = QMUITheme.separatorLineColor;
         _subHorizonLayer = [YXKLineUtility shapeLayerWithStokeColor:color fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _subHorizonLayer;
}

- (CAShapeLayer *)subVerticalLayer{
    if (!_subVerticalLayer) {
        UIColor *color = QMUITheme.separatorLineColor;
        _subVerticalLayer = [YXKLineUtility shapeLayerWithStokeColor:color fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _subVerticalLayer;
}

- (CALayer *)subMidHorizonLayer{
    if (!_subMidHorizonLayer) {
        UIColor *color = [UIColor colorWithRGB:0xEAEAEA];
        _subMidHorizonLayer = [[CALayer alloc] init];
        _subMidHorizonLayer.backgroundColor = color.CGColor;
    }
    return _subMidHorizonLayer;
}



- (CATextLayer *)maxPriceLayer {
    if (!_maxPriceLayer) {
        _maxPriceLayer = [[CATextLayer alloc] init];
        _maxPriceLayer.contentsScale = [UIScreen mainScreen].scale;
        UIFont *font = [UIFont systemFontOfSize:10];
        CFStringRef fontName = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef =CGFontCreateWithFontName(fontName);
        _maxPriceLayer.font = fontRef;
        _maxPriceLayer.fontSize = 7;
        CGFontRelease(fontRef);
        _maxPriceLayer.bounds = CGRectMake(0, 0, 100, 20);
        _maxPriceLayer.alignmentMode = kCAAlignmentCenter;
        _maxPriceLayer.foregroundColor = YX_TEXT_COLOR2.CGColor;
    }
    return _maxPriceLayer;
}


- (CATextLayer *)minPriceLayer {
    if (!_minPriceLayer) {
        _minPriceLayer = [[CATextLayer alloc] init];
        _minPriceLayer.contentsScale = [UIScreen mainScreen].scale;
        UIFont *font = [UIFont systemFontOfSize:10];
        CFStringRef fontName = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef =CGFontCreateWithFontName(fontName);
        _minPriceLayer.font = fontRef;
        _minPriceLayer.fontSize = 7;
        CGFontRelease(fontRef);
        _minPriceLayer.bounds = CGRectMake(0, 0, 100, 20);
        _minPriceLayer.alignmentMode = kCAAlignmentCenter;
        _minPriceLayer.foregroundColor = YX_TEXT_COLOR2.CGColor;
    }
    return _minPriceLayer;
}


- (CAGradientLayer *)gradientLayer {
    
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors = @[(__bridge id)[[UIColor colorWithRGB:0x414FFF] colorWithAlphaComponent:0.2].CGColor,
                                  (__bridge id)[[UIColor colorWithRGB:0x414FFF] colorWithAlphaComponent:0.0].CGColor];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(0, 1);
    }
    return _gradientLayer;
    
}


- (CAShapeLayer *)D_DIF_layer{
    
    if (!_D_DIF_layer) {
        _D_DIF_layer = [YXKLineUtility shapeLayerWithStokeColor: YX_KLINE_MA5_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _D_DIF_layer;
    
}

- (CAShapeLayer *)D_AMA_layer{
    
    if (!_D_AMA_layer) {
        _D_AMA_layer = [YXKLineUtility shapeLayerWithStokeColor: YX_KLINE_MA20_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _D_AMA_layer;
    
}


- (CAShapeLayer *)AR_layer{
    
    if (!_AR_layer) {
        _AR_layer = [YXKLineUtility shapeLayerWithStokeColor: YX_KLINE_MA5_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _AR_layer;
    
}

- (CAShapeLayer *)BR_layer{
    
    if (!_BR_layer) {
        _BR_layer = [YXKLineUtility shapeLayerWithStokeColor: YX_KLINE_MA20_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _BR_layer;
    
}

- (CAShapeLayer *)WR1_layer{
    
    if (!_WR1_layer) {
        _WR1_layer = [YXKLineUtility shapeLayerWithStokeColor: YX_KLINE_MA5_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _WR1_layer;
    
}

- (CAShapeLayer *)WR2_layer{
    
    if (!_WR2_layer) {
        _WR2_layer = [YXKLineUtility shapeLayerWithStokeColor: YX_KLINE_MA20_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _WR2_layer;
    
}

- (CAShapeLayer *)EMV_layer{
    
    if (!_EMV_layer) {
        _EMV_layer = [YXKLineUtility shapeLayerWithStokeColor: YX_KLINE_MA5_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _EMV_layer;
    
}

- (CAShapeLayer *)AEMV_layer{
    
    if (!_AEMV_layer) {
        _AEMV_layer = [YXKLineUtility shapeLayerWithStokeColor: YX_KLINE_MA20_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _AEMV_layer;
    
}


- (CAShapeLayer *)CR_layer{
    
    if (!_CR_layer) {
        _CR_layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA5_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _CR_layer;
    
}

- (CAShapeLayer *)CR1_layer{
    
    if (!_CR1_layer) {
        _CR1_layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA20_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _CR1_layer;
    
}

- (CAShapeLayer *)CR2_layer{
    
    if (!_CR2_layer) {
        _CR2_layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA60_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _CR2_layer;
    
}
- (CAShapeLayer *)CR3_layer{
    
    if (!_CR3_layer) {
        _CR3_layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA120_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _CR3_layer;
    
}

- (CAShapeLayer *)CR4_layer{
    
    if (!_CR4_layer) {
        _CR4_layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA250_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _CR4_layer;
}

- (CAShapeLayer *)volumn5_Layer{
    if (!_volumn5_Layer) {
        _volumn5_Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA20_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _volumn5_Layer;
}

- (CAShapeLayer *)volumn10_Layer{
    
    if (!_volumn10_Layer) {
        _volumn10_Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA60_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _volumn10_Layer;
}

- (CAShapeLayer *)volumn20_Layer{
    if (!_volumn20_Layer) {
        _volumn20_Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_MA120_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _volumn20_Layer;    
}

- (CAShapeLayer *)nowPrice_Layer{
    if (!_nowPrice_Layer) {
        _nowPrice_Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_NOPRICE_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _nowPrice_Layer;
}

- (CAShapeLayer *)holdPrice_Layer{
    if (!_holdPrice_Layer) {
        _holdPrice_Layer = [YXKLineUtility shapeLayerWithStokeColor:YX_KLINE_HOldPRICE_COLOR fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _holdPrice_Layer;
}


- (CAShapeLayer *)usmartUp_layer{
    
    if (!_usmartUp_layer) {
        _usmartUp_layer = [YXKLineUtility shapeLayerWithStokeColor:[QMUITheme stockRedColor] fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _usmartUp_layer;
    
}

- (CAShapeLayer *)usmartDown_layer{
    
    if (!_usmartDown_layer) {
        _usmartDown_layer = [YXKLineUtility shapeLayerWithStokeColor:[QMUITheme stockGreenColor] fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _usmartDown_layer;
    
}

- (CAShapeLayer *)usmartBuy_layer{
    
    if (!_usmartBuy_layer) {
        _usmartBuy_layer = [YXKLineUtility shapeLayerWithStokeColor:[QMUITheme stockRedColor] fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _usmartBuy_layer;
    
}

- (CAShapeLayer *)usmartSell_layer{
    
    if (!_usmartSell_layer) {
        _usmartSell_layer = [YXKLineUtility shapeLayerWithStokeColor:[QMUITheme stockGreenColor] fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _usmartSell_layer;
    
}

- (CAShapeLayer *)usMarketDayAndNight_Layer{
    if (!_usMarketDayAndNight_Layer) {
        _usMarketDayAndNight_Layer = [YXKLineUtility shapeLayerWithStokeColor:[QMUITheme.textColorLevel2 colorWithAlphaComponent:0.2] fillColor:[UIColor clearColor] lineWidth:1.0 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    }
    return _usMarketDayAndNight_Layer;
}

@end
