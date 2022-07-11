//
//  YXTimeLineView.m
//  uSmartOversea
//
//  Created by rrd on 2018/8/10.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXTimeLineView.h"
#import "YXKLineUtility.h"
#import "YXStockConfig.h"
#import "YXLayerGenerator.h"
#import <CoreText/CoreText.h>
#import "YXAccessoryTitleGenerator.h"
#import "YXDateToolUtility.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import "UILabel+create.h"
#import "YXKLineOrderLayer.h"

#define K_HKPonitDayNumber 332
#define K_HKPonitFiveDayNumber (K_HKPonitDayNumber * 5)
#define K_USPointDayNumber 391
#define K_USPointHalfDayNumber 211
#define K_USPointFiveDayNumber (K_USPointDayNumber * 5)
#define K_CHPointDayNumber 242
#define K_CHPointFiveDayNumber (K_CHPointDayNumber * 5)
#define K_CHGEMPointDayNumber 272
#define K_CHGEMPointFiveDayNumber (K_CHGEMPointDayNumber * 5)

#define K_USPonitPreQuoteNumber 331
#define K_USPonitAfterQuoteNumber 241

#define K_SGPonitDayNumber 438
#define K_SGPointFiveDayNumber (K_SGPonitDayNumber * 5)

#define K_USPonitAllQuoteNumber 961
#define K_USPonitHalfAllQuoteNumber 781 // 半日式全部
#define K_USPointAllQuoteFiveDayNumber (K_USPonitAllQuoteNumber * 5)

@interface YXTimeLineView () <UIScrollViewDelegate>

//1, layer生成器
@property (nonatomic, strong) YXLayerGenerator *generator;
@property (nonatomic, strong) YXAccessoryTitleGenerator *titleGenerator;

//2, 分时线画图区域/交易量区域/交易量宽度/点间距
@property (nonatomic, assign) CGRect timeLineRect;
@property (nonatomic, assign) CGRect volumeRect;
@property (nonatomic, assign) double volumeWidth;
@property (nonatomic, assign) double pointMargin;

//3, 手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;  //长按手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer; //轻击手势
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer; //双击手势

//最高最低价 & 涨跌幅 & pclose
@property (nonatomic, strong) UILabel *highestPriceLabel;
@property (nonatomic, strong) UILabel *lowestPriceLabel;
@property (nonatomic, strong) UILabel *highestRatioLabel;
@property (nonatomic, strong) UILabel *lowestRatioLabel;
@property (nonatomic, strong) UILabel *pcloseLabel;
@property (nonatomic, strong) UILabel *pcloseRatioLabel;

@property (nonatomic, strong) UILabel *secondHighPriceLabel;
@property (nonatomic, strong) UILabel *secondHighRocLabel;

@property (nonatomic, strong) UILabel *secondLowerPriceLabel;
@property (nonatomic, strong) UILabel *secondLowerRocLabel;

@property (nonatomic, strong) UILabel *subMaxVolumnLabel;
@property (nonatomic, strong) UILabel *subMidVolumnLabel;
@property (nonatomic, strong) UIView *lineView;

//1日分时label(09:30 12:00/13:00 16:00)
@property (nonatomic, strong) NSMutableArray *oneDayTimeLabelArr;

//5日分时时间title(01-01 01-02 01-03..)
@property (nonatomic, strong) NSMutableArray *fiveDayTimeTitleArr;

//可以显示数组
@property (nonatomic, strong) NSArray *visibleArray;

//最高和最低价
@property (nonatomic, assign) double maxHigh;
@property (nonatomic, assign) double minLow;

//十字架下面的时间标签
@property (nonatomic, strong) QMUILabel *crossingTimeLabel;

@property (nonatomic, assign) NSInteger pointNumber;

//存储买卖点Layer的数组
@property (nonatomic, strong) NSArray<YXKLineOrderLayer *> *orderLayerArray;
//分时图距离顶部的距离（有无买卖点时，距离顶部距离不同）
@property (nonatomic, assign) CGFloat topFixMargin;

//买卖点宽高
@property (nonatomic, assign) CGFloat orderLayerHeight;
@property (nonatomic, assign) CGFloat orderLayerWidth;
// 盘前盘后的渲染色
@property (nonatomic, strong) CAShapeLayer *preAfterFillLayer;
@property (nonatomic, strong) UIImageView *timeLineDayImgaeView;
@property (nonatomic, strong) UIImageView *timeLineNightImgaeView;

@end

@implementation YXTimeLineView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initBaseView];
    }
    return self;
}

//初始化数据
- (void)initBaseView{
    
    self.layer.masksToBounds = YES;

    self.orderLayerArray = @[];

    self.chartType = YXTimeLineChartTypeDefault;

    _topFixMargin = 0;
    self.orderLayerHeight = 14;
    self.orderLayerWidth = 9;
    
    self.preAfterFillLayer = [YXKLineUtility shapeLayerWithStokeColor:UIColor.clearColor fillColor:[QMUITheme.textColorLevel1 colorWithAlphaComponent:0.05] lineWidth:0.5 lineCap:kCALineCapSquare lineJoin:kCALineCapSquare];
    [self.layer addSublayer:self.preAfterFillLayer];
    [self.layer addSublayer:self.generator.usMarketDayAndNight_Layer];
    
    //1, 网格横线/网格竖线/填充线/价格/均价/长按后十字线/长按后价格标签/长按后涨跌幅标签/盘中实心点
//    [self.layer addSublayer:self.generator.horizonLayer];
//    [self.layer addSublayer:self.generator.verticalLayer];
    [self.layer addSublayer:self.generator.timePriceLineLayer];
    [self.layer addSublayer:self.generator.averagePriceLayer];
    [self.layer addSublayer:self.generator.crossLineLayer];
    [self addSubview:self.titleGenerator.timeLineCrossingPriceLabel];
    [self addSubview:self.titleGenerator.timeLineCrossingRocLabel];
    [self.layer addSublayer:self.generator.gradientLayer];
    [self.layer addSublayer:self.generator.yesterdayCloseLayer];
    [self.layer addSublayer:self.generator.nowPrice_Layer];
    [self.layer addSublayer:self.generator.timeLineDotLayer];
    [self.layer addSublayer:self.generator.holdPrice_Layer];
    
    self.titleGenerator.timeLineCrossingRocLabel.hidden = YES;
    self.titleGenerator.timeLineCrossingPriceLabel.hidden = YES;
    self.generator.crossLineLayer.hidden = YES;
    self.generator.timeLineDotLayer.hidden = YES;
    
    //2, 手势
    [self addGestureRecognizer:self.tapGestureRecognizer];
    [self addGestureRecognizer:self.longPressGestureRecognizer];
    
    //3, 长按后交点圈圈
    [self.layer addSublayer:self.generator.longPressCirclePriceLayer];
    [self.layer addSublayer:self.generator.longPressCircleAveragePriceLayer];

    //4, 交易量
    [self.layer addSublayer:self.generator.redVolumeLayer];
    [self.layer addSublayer:self.generator.greenVolumeLayer];
    [self.layer addSublayer:self.generator.greyVolumeLayer];
    
    //最高价/最低价/涨跌幅/涨跌额/昨收/昨收幅/十字架下面时间
    [self addSubview:self.highestRatioLabel];
    [self addSubview:self.lowestRatioLabel];
    [self addSubview:self.highestPriceLabel];
    [self addSubview:self.lowestPriceLabel];
    [self addSubview:self.pcloseLabel];
    [self addSubview:self.pcloseRatioLabel];
    [self addSubview:self.crossingTimeLabel];
    
    [self addSubview:self.secondHighPriceLabel];
    [self addSubview:self.secondHighRocLabel];
    [self addSubview:self.secondLowerPriceLabel];
    [self addSubview:self.secondLowerRocLabel];
    
    [self addSubview:self.subMaxVolumnLabel];
    [self addSubview:self.subMidVolumnLabel];

    [self addSubview:self.lineView];
    
    self.timeLineRect = CGRectMake(0, _topFixMargin, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * 0.6);
    self.volumeRect = CGRectMake(0, CGRectGetMaxY(self.timeLineRect) + 25, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - (CGRectGetMaxY(self.timeLineRect) + 25));
    CGFloat topY = self.timeLineRect.origin.y;
    [self.highestPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self).offset(topY);
    }];
    
    [self.lowestPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.bottom.equalTo(self.mas_top).offset(CGRectGetMaxY(self.timeLineRect));
    }];
    
    [self.highestRatioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.centerY.equalTo(self.highestPriceLabel);
    }];
    
    [self.lowestRatioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.bottom.equalTo(self.lowestPriceLabel);
    }];
    
    [self.pcloseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lowestPriceLabel);
        make.height.mas_equalTo(16);
        make.top.equalTo(self).offset(self.timeLineRect.origin.y + 0.5 * CGRectGetHeight(self.timeLineRect) - 8);
    }];
    
    [self.pcloseRatioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.lowestRatioLabel);
        make.centerY.equalTo(self.pcloseLabel);
    }];
    
    [self.secondHighPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.height.mas_equalTo(16);
        make.top.equalTo(self).offset(self.timeLineRect.origin.y + 0.25 * CGRectGetHeight(self.timeLineRect) - 8);
    }];
    
    [self.secondLowerPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.height.mas_equalTo(16);
        make.top.equalTo(self).offset(self.timeLineRect.origin.y + 0.75 * CGRectGetHeight(self.timeLineRect) - 8);
    }];
    
    [self.secondHighRocLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.lowestRatioLabel);
        make.centerY.equalTo(self.secondHighPriceLabel);
    }];
    
    [self.secondLowerRocLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.lowestRatioLabel);
        make.centerY.equalTo(self.secondLowerPriceLabel);
    }];
    
    [self.subMaxVolumnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.height.mas_equalTo(16);
        make.top.equalTo(self).offset(self.volumeRect.origin.y);
    }];
    
    [self.subMidVolumnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.height.mas_equalTo(16);
        make.centerY.equalTo(self.mas_top).offset(CGRectGetMidY(self.volumeRect));
    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self).offset(CGRectGetMaxY(self.timeLineRect));
        make.height.mas_equalTo(1);
    }];
    
    [self.titleGenerator.timeLineCrossingPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(20);
    }];
    
    [self.titleGenerator.timeLineCrossingRocLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(20);
    }];
    
//    [self.layer qmui_sendSublayerToBack:self.generator.horizonLayer];
//    [self.layer qmui_sendSublayerToBack:self.generator.verticalLayer];
    [self bringSubviewToFront:self.titleGenerator.timeLineCrossingPriceLabel];
    [self bringSubviewToFront:self.titleGenerator.timeLineCrossingRocLabel];
    
    self.titleGenerator.timeLineCrossingPriceLabel.backgroundColor = QMUITheme.longPressBgColor;
    self.titleGenerator.timeLineCrossingPriceLabel.textColor = QMUITheme.longPressTextColor;
    
    self.titleGenerator.timeLineCrossingRocLabel.backgroundColor = QMUITheme.longPressBgColor;
    self.titleGenerator.timeLineCrossingRocLabel.textColor = QMUITheme.longPressTextColor;
    
    [self addTimeLabels];
    
    [self addSubview:self.timeLineDayImgaeView];
    [self addSubview:self.timeLineNightImgaeView];

}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.timeLineRect = CGRectMake(0, _topFixMargin, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * 0.6 - _topFixMargin);
    self.volumeRect = CGRectMake(0, CGRectGetMaxY(self.timeLineRect) + 25, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - (CGRectGetMaxY(self.timeLineRect) + 25));

    CGFloat topY = 0; //self.timeLineRect.origin.y;
    CGFloat topHeight = self.timeLineRect.origin.y + CGRectGetHeight(self.timeLineRect);
    if (self.highestPriceLabel.superview) {
        [self.highestPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(topY);
        }];
    }
    
    if (self.lowestPriceLabel.superview) {
        [self.lowestPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_top).offset(CGRectGetMaxY(self.timeLineRect));
        }];
    }
    if (self.pcloseLabel.superview) {
        [self.pcloseLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(topY + 0.5 * topHeight - 8);
        }];
    }
    
    if (self.secondHighPriceLabel.superview) {
        [self.secondHighPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(self.timeLineRect.origin.y + 0.25 * topHeight - 8);
        }];
    }
    
    if (self.secondLowerPriceLabel.superview) {
        [self.secondLowerPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(self.timeLineRect.origin.y + 0.75 * topHeight - 8);
        }];
    }
    
    if (self.subMaxVolumnLabel.superview) {
        [self.subMaxVolumnLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(self.volumeRect.origin.y);
        }];
    }
    
    if (self.subMidVolumnLabel.superview) {
        [self.subMidVolumnLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_top).offset(CGRectGetMidY(self.volumeRect));
        }];
    }

    if (self.lineView.superview) {
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(CGRectGetMaxY(self.timeLineRect));
        }];
    }

}

- (void)setChange:(NSInteger)change {
    if (_change == change) {
        return ;
    }
    _change = change;
    
    if (change > 0) {
        self.generator.timePriceLineLayer.strokeColor = [QMUITheme stockRedColor].CGColor;
        self.generator.timeLineDotLayer.strokeColor = [QMUITheme stockRedColor].CGColor;
        self.generator.timeLineDotLayer.fillColor = [QMUITheme stockRedColor].CGColor;
        self.generator.gradientLayer.colors = @[(__bridge id)[[QMUITheme stockRedColor] colorWithAlphaComponent:0.2].CGColor,
                                                (__bridge id)[[QMUITheme stockRedColor] colorWithAlphaComponent:0.0].CGColor];
    } else if (change < 0) {
        self.generator.timePriceLineLayer.strokeColor = [QMUITheme stockGreenColor].CGColor;
        self.generator.timeLineDotLayer.strokeColor = [QMUITheme stockGreenColor].CGColor;
        self.generator.timeLineDotLayer.fillColor = [QMUITheme stockGreenColor].CGColor;
        self.generator.gradientLayer.colors = @[(__bridge id)[[QMUITheme stockGreenColor] colorWithAlphaComponent:0.2].CGColor,
                                                (__bridge id)[[QMUITheme stockGreenColor] colorWithAlphaComponent:0.0].CGColor];
    } else {
        self.generator.timePriceLineLayer.strokeColor = [QMUITheme themeTextColor].CGColor;
        self.generator.timeLineDotLayer.strokeColor = [QMUITheme themeTextColor].CGColor;
        self.generator.timeLineDotLayer.fillColor = [QMUITheme themeTextColor].CGColor;
        self.generator.gradientLayer.colors = @[(__bridge id)[[QMUITheme themeTextColor] colorWithAlphaComponent:0.2].CGColor,
                                                (__bridge id)[[QMUITheme themeTextColor] colorWithAlphaComponent:0.0].CGColor];
    }
}

- (void)setHasOrder:(BOOL)hasOrder {

    if (_hasOrder == hasOrder) {
        return ;
    }
    _hasOrder = hasOrder;
    if (hasOrder) {
        _topFixMargin = self.orderLayerHeight + 1;
    } else {
        _topFixMargin = 0;
    }
    self.frame = self.frame;
}

- (void)setIsLandscape:(BOOL)isLandscape {
    _isLandscape = isLandscape;
    if (isLandscape && !_doubleTapGestureRecognizer) {
        [self addGestureRecognizer:self.doubleTapGestureRecognizer];
        [self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
    }
}

- (void)drawAllLayers {
    self.visibleArray = self.timeLineModel.list;
    if (self.visibleArray.count <= 0) {
        [self cleanData];
        return;
    }

    for (CALayer *layer in self.orderLayerArray) {
        [layer removeFromSuperlayer];
    }
    self.orderLayerArray = @[];

    YXTimeLine *sigModel = self.visibleArray[0];
    //除数位数比
    NSInteger square = _timeLineModel.priceBase.value > 0 ? _timeLineModel.priceBase.value : 3;
    double priceBasic = pow(10.0, square);
    //当前区域的最高值
    double nowMaxHigh = self.timeLineModel.list.firstObject.price.value;
    double nowMinLow = self.timeLineModel.list.firstObject.price.value;
    //当前区域的最低值
    double avgMaxHigh = self.timeLineModel.list.firstObject.avg.value;
    double avgMinLow = self.timeLineModel.list.firstObject.avg.value;
    
    for (YXTimeLine *item in self.timeLineModel.list) {
        double price = item.price.value;
        double avg = item.avg.value;
        if (nowMaxHigh < price) {
            nowMaxHigh = price;
        }
        
        if (nowMinLow > price) {
            nowMinLow = price;
        }
        
        if (avgMaxHigh < avg) {
            avgMaxHigh = avg;
        }
        
        if (avgMinLow > avg) {
            avgMinLow = avg;
        }
     }

    nowMaxHigh = nowMaxHigh / priceBasic;
    avgMaxHigh = avgMaxHigh / priceBasic;
    double maxHigh = MAX(nowMaxHigh, avgMaxHigh);
    
    nowMinLow = nowMinLow / priceBasic;
    avgMinLow = avgMinLow / priceBasic;
    double minLow = MIN(nowMinLow, avgMinLow);

    
    // 分时跟最高最低价比较, 从外部传进来
    if (self.high > 0) {
        maxHigh = MAX(self.high, maxHigh);
    }
    if (self.low > 0) {
        minLow = MIN(self.low, minLow);
    }
    
    if (maxHigh <= 0) {
        maxHigh = pow(10.0, -square) * 2.0;
        minLow = pow(10.0, -square) * -2.0;
    }
    
    //时间轴指数
    __block NSInteger timeIndex = 0;
    
    int64_t maxVolume;
    int64_t minVolume = 0;
    if (self.isIndexStock) {
        //当前区域的最大成交额
        maxVolume = [[self.timeLineModel.list valueForKeyPath:@"@max.amount.value"] longLongValue];
    } else {
        //当前区域的最小成交量
        maxVolume = [[self.timeLineModel.list valueForKeyPath:@"@max.volume.value"] longLongValue];
    }
    // 刻度值
    if ([YXUserManager isENMode] == YXLanguageTypeEN) {
        if (self.isIndexStock) {
            self.subMaxVolumnLabel.text = [YXToolUtility stockData:maxVolume deciPoint:2 stockUnit: @"" priceBase: square];
            self.subMidVolumnLabel.text = [YXToolUtility stockData:maxVolume * 0.5 deciPoint:2 stockUnit: @"" priceBase: square];
        } else {

            if ([_timeLineModel.market isEqualToString:kYXMarketUsOption]) {
                int deciPoint = 2;
                if (maxVolume < 1000) {
                    deciPoint = 0;
                }
                self.subMaxVolumnLabel.text = [YXToolUtility stockData:maxVolume deciPoint:deciPoint stockUnit: [YXLanguageUtility kLangWithKey:@"options_page"] priceBase: 0];
            } else {
                self.subMaxVolumnLabel.text = [YXToolUtility stockData:maxVolume deciPoint:2 stockUnit: @"" priceBase: 0];
            }
            self.subMidVolumnLabel.text = [YXToolUtility stockData:maxVolume * 0.5 deciPoint:2 stockUnit: @"" priceBase: 0];
        }
    } else {
        if (self.isIndexStock) {
            self.subMaxVolumnLabel.text = [NSString stringWithFormat:@"%.2f%@", maxVolume / 100000000.0 / priceBasic, [YXLanguageUtility kLangWithKey:@"common_billion"]];
            self.subMidVolumnLabel.text = [NSString stringWithFormat:@"%.2f", maxVolume * 0.5 / 100000000 / priceBasic];
        } else {

            NSString *unitString = [NSString stringWithFormat:@"%@%@", [YXLanguageUtility kLangWithKey:@"stock_detail_ten_thousand"], [YXLanguageUtility kLangWithKey:@"stock_unit_en"]];
            if ([_timeLineModel.market isEqualToString:kYXMarketUsOption]) {

                if (maxVolume > 10000) {
                    unitString = [NSString stringWithFormat:@"%@%@", [YXLanguageUtility kLangWithKey:@"stock_detail_ten_thousand"], [YXLanguageUtility kLangWithKey:@"options_page"]];
                    self.subMaxVolumnLabel.text = [NSString stringWithFormat:@"%.2f%@", maxVolume / 10000.0, unitString];
                } else {
                    unitString =  [YXLanguageUtility kLangWithKey:@"options_page"];
                    self.subMaxVolumnLabel.text = [NSString stringWithFormat:@"%lld%@", maxVolume, unitString];
                }
            } else {
                self.subMaxVolumnLabel.text = [NSString stringWithFormat:@"%.2f%@", maxVolume / 10000.0, unitString];
            }
            self.subMidVolumnLabel.text = [NSString stringWithFormat:@"%.2f", maxVolume * 0.5 / 10000];
        }
    }

    
    //分时线的画图区域
    double candleDistance = CGRectGetHeight(self.timeLineRect);
    double pClose = sigModel.preClose.value / priceBasic;
    if (pClose <= 0) {
        pClose = sigModel.price.value / priceBasic;
    }
    
    CGFloat midValue = pClose;
    
    if ([self.timeLineModel.market isEqualToString:kYXMarketHK] || [self.timeLineModel.market isEqualToString:kYXMarketUS] ||
        [self.timeLineModel.market isEqualToString:kYXMarketUsOption] || [self.timeLineModel.market isEqualToString:kYXMarketSG]) {
        if (maxHigh == minLow) {
            maxHigh = pClose + pow(10.0, -square) * 2.0;
            minLow = pClose - pow(10.0, -square) * 2.0;
        }
        // 正常画法
        midValue = minLow + (maxHigh - minLow) * 0.5;
    } else {
        // 对称画法(A股)
        if (maxHigh == minLow) {
            if (maxHigh == pClose) {
                maxHigh =  pClose * 1.25;
                minLow = pClose * 0.75;
            }
            if (maxHigh > pClose) {
                minLow = pClose * 2 - maxHigh;
            }
            if (maxHigh < pClose) {
                maxHigh = pClose * 2 -  minLow;
            }
        } else if (maxHigh <= pClose) {
            maxHigh = pClose * 2 - minLow;
        } else if (minLow >= pClose) {
            minLow = pClose * 2 - maxHigh;
        } else {
            if (maxHigh - pClose >= pClose - minLow) {
                minLow = pClose * 2 - maxHigh;
            } else {
                maxHigh = pClose * 2 - minLow;
            }
        }
    }
    
    float scaleValue = (maxHigh - minLow) * 0.25;
    
    //左边的文字(最高最低价)
    if (square == 3) {
        self.highestPriceLabel.text = [NSString stringWithFormat: @"%.3f", maxHigh];
        self.lowestPriceLabel.text = [NSString stringWithFormat:@"%.3f", minLow];
        self.secondHighPriceLabel.text = [NSString stringWithFormat:@"%.3f", midValue + scaleValue];
        self.secondLowerPriceLabel.text = [NSString stringWithFormat:@"%.3f", midValue - scaleValue];
        self.pcloseLabel.text = [NSString stringWithFormat:@"%.3lf", midValue];
    } else {
        self.highestPriceLabel.text = [NSString stringWithFormat: @"%.2f", maxHigh];
        self.lowestPriceLabel.text = [NSString stringWithFormat:@"%.2f", minLow];
        self.secondHighPriceLabel.text = [NSString stringWithFormat:@"%.2f", midValue + scaleValue];
        self.secondLowerPriceLabel.text = [NSString stringWithFormat:@"%.2f", midValue - scaleValue];
        self.pcloseLabel.text = [NSString stringWithFormat:@"%.2lf", midValue];
    }
    
    if (maxHigh - minLow < 0.005) {
        self.secondHighPriceLabel.hidden = true;
        self.secondLowerPriceLabel.hidden = true;
    } else {
        self.secondHighPriceLabel.hidden = false;
        self.secondLowerPriceLabel.hidden = false;
    }
    
    float offsetHighValue = maxHigh - pClose;
    float offsetSecondHighValue = midValue + scaleValue - pClose;
    float offsetMidValue = midValue-pClose;
    float offsetSecondLowValue = midValue - scaleValue - pClose;
    float offsetLowValue = minLow - pClose;
    
    //右边的文字(最高最低涨跌幅)
    if (pClose <= 0) {
        self.highestRatioLabel.text = @"0.00%";
        self.lowestRatioLabel.text = @"0.00%";
        self.secondHighRocLabel.text = @"0.00%";
        self.secondLowerRocLabel.text = @"0.00%";
        self.pcloseRatioLabel.text = @"0.00%";
    } else {
        self.highestRatioLabel.text = [NSString stringWithFormat: @"%.2f%@", offsetHighValue / pClose * 100, @"%"];
        self.lowestRatioLabel.text = [NSString stringWithFormat: @"%.2f%@", offsetLowValue / pClose * 100, @"%"];
        self.secondHighRocLabel.text = [NSString stringWithFormat: @"%.2f%@", offsetSecondHighValue / pClose * 100, @"%"];
        self.secondLowerRocLabel.text = [NSString stringWithFormat: @"%.2f%@", offsetSecondLowValue / pClose * 100, @"%"];
        self.pcloseRatioLabel.text = [NSString stringWithFormat: @"%.2f%@", offsetMidValue / pClose * 100, @"%"];
    }
    
    
    self.highestRatioLabel.hidden = midValue <= 0;
    self.lowestRatioLabel.hidden = midValue <= 0;
    self.pcloseRatioLabel.hidden = midValue <= 0;
    self.secondHighRocLabel.hidden = midValue <= 0;
    self.secondLowerRocLabel.hidden = midValue <= 0;
    
    //交易量的画图区域
    double volumeDistance = CGRectGetHeight(self.volumeRect);
    
    double zeroY = CGRectGetMaxY(self.timeLineRect);
    double zeroVolumeY = CGRectGetMaxY(self.volumeRect);
    
    UIBezierPath *minuteTimePath = [UIBezierPath bezierPath];
    UIBezierPath *greenVolumePath = [UIBezierPath bezierPath];
    UIBezierPath *redVolumePath = [UIBezierPath bezierPath];
    UIBezierPath *greyVolumePath = [UIBezierPath bezierPath];
    
    UIBezierPath *preClosePath = [UIBezierPath bezierPath];
    UIBezierPath *avergePricePath = [UIBezierPath bezierPath];
    UIBezierPath *nowPath = [UIBezierPath bezierPath];
    
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    __block UIBezierPath *dotPath = [UIBezierPath bezierPath];
    //填充部分
    [fillPath moveToPoint:CGPointMake(0, CGRectGetMaxY(self.timeLineRect))];
    __block BOOL minuteFirst = YES;
    
    self.maxHigh = maxHigh;
    self.minLow = minLow;
    
    __block CGFloat preAfterShadowX = 0;
    __block BOOL isCloseShadow = YES;
    __block NSString *preAfterTimeStr = @"";
    UIBezierPath *preAfterShadowPath = [UIBezierPath bezierPath];
    
    UIBezierPath *dayAndNightPath = [UIBezierPath bezierPath];
    
    double margin = (_pointMargin - self.volumeWidth)/2.0;
    [self.visibleArray enumerateObjectsUsingBlock:^(YXTimeLine * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        double x = idx * self.pointMargin;
        if (obj) {
            //当前价格线
            double minuterTimePoint_y = [YXKLineUtility getYCoordinateWithMaxPrice:maxHigh minPrice:minLow price:obj.price.value / priceBasic distance:candleDistance zeroY:zeroY];
            //价格均线
            double averagePricePoint_y = [YXKLineUtility getYCoordinateWithMaxPrice:maxHigh minPrice:minLow price:obj.avg.value / priceBasic distance:candleDistance zeroY:zeroY];
            [fillPath addLineToPoint:CGPointMake(x, minuterTimePoint_y)];
            if (idx == 0) {
                minuteFirst = YES;
                //时间轴时间
                UILabel *timeLabel = self.fiveDayTimeTitleArr[0];
                timeLabel.text = [YXDateHelper commonDateStringWithNumber:obj.latestTime.value format:YXCommonDateFormatDF_MD scaleType:YXCommonDateScaleTypeScale showWeek:NO];
                timeLabel.mj_x = x;
                if ([self.timeLineModel.market isEqualToString:kYXMarketHK] || [self.timeLineModel.market isEqualToString:kYXMarketUS] ||
                    [self.timeLineModel.market isEqualToString:kYXMarketUsOption] || [self.timeLineModel.market isEqualToString:kYXMarketSG]) {
                    
                    float pClosePrice = obj.preClose.value / priceBasic;
                    // 昨收在最高最低内
                    if (pClosePrice <= maxHigh && pClosePrice >= minLow) {
                        // 增加昨收线
                        double y = [YXKLineUtility getYCoordinateWithMaxPrice:maxHigh minPrice:minLow price:pClosePrice distance:candleDistance zeroY:zeroY];
                        NSInteger nowCount = YX_KLINE_NOWPRICE_COUNT * self.frame.size.width / 300;
                        // 现价线
                        CGFloat padding = self.frame.size.width / nowCount * 0.5;
                        CGFloat width = (self.frame.size.width - (padding * nowCount - 1)) / nowCount;
                        for (int x = 0; x < nowCount; x++ ) {
                            UIBezierPath *path = [UIBezierPath bezierPath];
                            [path moveToPoint:CGPointMake(x * (width + padding), y)];
                            [path addLineToPoint:CGPointMake(x * (width + padding) + width, y)];
                            [preClosePath appendPath:path];
                        }
                    }
                    
                }                
            } else {
                
                YXTimeLine *preObj = self.visibleArray[idx - 1];
                YXDateModel *preDateModel = [YXDateToolUtility dateTimeWithTimeValue:preObj.latestTime.value];
                YXDateModel *dateModel = [YXDateToolUtility dateTimeWithTimeValue:obj.latestTime.value];
                if ([[NSString stringWithFormat:@"%@%@", preDateModel.month, preDateModel.day] isEqualToString: [NSString stringWithFormat:@"%@%@", dateModel.month, dateModel.day]]) {
                    minuteFirst = NO;
                } else {
                    minuteFirst = YES;
                    timeIndex += 1;
                    //时间轴时间
                    if (timeIndex < self.fiveDayTimeTitleArr.count) {
                        UILabel *timeLabel = self.fiveDayTimeTitleArr[timeIndex];
                        timeLabel.text = [YXDateHelper commonDateStringWithNumber:obj.latestTime.value format:YXCommonDateFormatDF_MD scaleType:YXCommonDateScaleTypeScale showWeek:NO];
                        timeLabel.mj_x = x - 40 * 0.5;
                    }
                }
            }
            
            if (minuteFirst == YES) {
                //分时图
                //价格线
                [minuteTimePath moveToPoint:CGPointMake(x, minuterTimePoint_y)];
                //价格均线
                [avergePricePath moveToPoint:CGPointMake(x, averagePricePoint_y)];
                minuteFirst = NO;
                
            } else {
                // 分时图
                [minuteTimePath addLineToPoint:CGPointMake(x, minuterTimePoint_y)];
                // 价格均线
                [avergePricePath addLineToPoint:CGPointMake(x, averagePricePoint_y)];
            }

            if ([YXKLineConfigManager shareInstance].showBuySellPoint) {
                YXKLineInsideEvent *orderEvent = nil;
                if (obj.klineEvents.count > 0) {
                    for (YXKLineInsideEvent *event in obj.klineEvents) {
                        if (event.type.value == 0 && (event.bought.count > 0 || event.sold.count > 0)) {
                            orderEvent = event;
                            break;
                        }
                    }
                }
                if (orderEvent.bought.count > 0 || orderEvent.sold.count > 0) {
                    YXKLineOrderLayer *orderlayer = [self createOrderLayer];
                    [self.layer addSublayer:orderlayer];
                    if (orderEvent.bought.count > 0 && orderEvent.sold.count > 0) {
                        orderlayer.orderDirection = YXKLineOrderDirectionBoth;
                    } else if (orderEvent.bought.count > 0) {
                        orderlayer.orderDirection = YXKLineOrderDirectionBuy;
                    } else {
                        orderlayer.orderDirection = YXKLineOrderDirectionSell;
                    }

                    CGFloat layerX = x;
                    CGFloat lineStartX = self.orderLayerWidth / 2.0;
                    if (x < self.orderLayerWidth / 2.0) {
                        layerX = self.orderLayerWidth / 2.0;
                        lineStartX = x;
                    } else if (x > self.frame.size.width - self.orderLayerWidth / 2.0) {
                        layerX = self.frame.size.width - self.orderLayerWidth / 2.0;
                        lineStartX = self.orderLayerWidth / 2.0 + x - (self.frame.size.width - self.orderLayerWidth / 2.0);
                    }

                    orderlayer.startX = lineStartX;
                    orderlayer.position = CGPointMake(layerX, minuterTimePoint_y - self.orderLayerHeight/2);
                }
            }
            
            // 找出5日k线的阴影
            if (self.timeLineModel.isAll.value && self.timeLineModel.days.value == 5) {
                NSString *timeStr = [NSString stringWithFormat:@"%llu", obj.latestTime.value];
                timeStr = [timeStr substringWithRange:NSMakeRange(8, 4)];
                NSString *nextTimeStr = [self nextTimeStr:preAfterTimeStr];
                if ([timeStr isEqualToString:nextTimeStr]) {
                    preAfterTimeStr = nextTimeStr;
                    if (isCloseShadow) {
                        isCloseShadow = NO;
                        preAfterShadowX = x;
                    } else {
                        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(preAfterShadowX, 0, x - preAfterShadowX, self.timeLineRect.size.height)];
                        isCloseShadow = YES;
                        [preAfterShadowPath appendPath:path];
                    }
                }
                
                // 最后一个点,且盘前盘后阴影没闭合
                if ((idx == self.visibleArray.count - 1) && !isCloseShadow) {
                    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(preAfterShadowX, 0, x - preAfterShadowX, self.timeLineRect.size.height)];
                    isCloseShadow = YES;
                    [preAfterShadowPath appendPath:path];
                }
            }
            
            // 找出美股全日的白天和夜晚
            if (self.timeLineModel.isAll.value && self.timeLineModel.days.value == 1) {
                NSString *timeStr = [NSString stringWithFormat:@"%llu", obj.latestTime.value];
                timeStr = [timeStr substringWithRange:NSMakeRange(8, 4)];
                // 白天
                NSInteger nowCount = YX_KLINE_NOWPRICE_COUNT * self.frame.size.width / 300;
                CGFloat padding = self.timeLineRect.size.height / nowCount * 0.5;
                CGFloat height = (self.timeLineRect.size.height - (padding * nowCount - 1)) / nowCount;
                NSString *nightStr = @"1600";
                if (self.timeLineModel.type.value == 6) {
                    nightStr = @"1300";
                }
                if ([timeStr isEqualToString:@"0930"]) {
                    for (int i = 0; i < nowCount; i++ ) {
                        UIBezierPath *path = [UIBezierPath bezierPath];
                        [path moveToPoint:CGPointMake(x, i * (height + padding))];
                        [path addLineToPoint:CGPointMake(x, i * (height + padding) + height)];
                        [dayAndNightPath appendPath:path];
                    }
                } else if ([timeStr isEqualToString:nightStr]) {
                    // 夜晚
                    for (int i = 0; i < nowCount; i++ ) {
                        UIBezierPath *path = [UIBezierPath bezierPath];
                        [path moveToPoint:CGPointMake(x, i * (height + padding))];
                        [path addLineToPoint:CGPointMake(x, i * (height + padding) + height)];
                        [dayAndNightPath appendPath:path];
                    }
                }
            }

        }
        
        if (idx == self.visibleArray.count - 1) {
            [fillPath addLineToPoint:CGPointMake(x, CGRectGetMaxY(self.timeLineRect))];
            
            double y = [YXKLineUtility getYCoordinateWithMaxPrice:maxHigh minPrice:minLow price:obj.price.value / priceBasic distance:candleDistance zeroY:zeroY];
            
            //实心点
            dotPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:3 startAngle:0 endAngle:360 clockwise:YES];
            
            NSInteger nowCount = YX_KLINE_NOWPRICE_COUNT * self.frame.size.width / 300;
            // 现价线
            CGFloat padding = self.frame.size.width / nowCount * 0.5;
            CGFloat width = (self.frame.size.width - (padding * nowCount - 1)) / nowCount;
            
            for (int x = 0; x < nowCount; x++ ) {
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:CGPointMake(x * (width + padding), y)];
                [path addLineToPoint:CGPointMake(x * (width + padding) + width, y)];
                [nowPath appendPath:path];
            }
        }
        
        double volumeY;
        if (self.isIndexStock) {
            volumeY = [YXKLineUtility getYCoordinateWithMaxVolumn:maxVolume minVolumn:minVolume volume:obj.amount.value distance:volumeDistance zeroY:zeroVolumeY];
        } else {
            volumeY = [YXKLineUtility getYCoordinateWithMaxVolumn:maxVolume minVolumn:minVolume volume:obj.volume.value distance:volumeDistance zeroY:zeroVolumeY];
        }
        
        x += margin;
        if (idx == 0) { //第一天
            if (obj.price.value >= obj.preClose.value) {
                //交易量的path
                UIBezierPath *volumePath = [YXKLineUtility getVolumePathWithVoumeWidth:self.volumeWidth xCooordinate:x volumeY:volumeY zeroY:zeroVolumeY];
                [redVolumePath appendPath:volumePath];
            } else {
                UIBezierPath *volumePath = [YXKLineUtility getVolumePathWithVoumeWidth:self.volumeWidth xCooordinate:x volumeY:volumeY zeroY:zeroVolumeY];
                [greenVolumePath appendPath:volumePath];
            }
        } else {
            YXTimeLine *pObj = self.visibleArray[idx - 1];
            //交易量的path
            UIBezierPath *volumePath = [YXKLineUtility getVolumePathWithVoumeWidth:self.volumeWidth xCooordinate:x volumeY:volumeY zeroY:zeroVolumeY];
            if (obj.price.value > pObj.price.value) {
                [redVolumePath appendPath:volumePath];
            } else if (obj.price.value < pObj.price.value) {
                [greenVolumePath appendPath:volumePath];
            } else {
                [greyVolumePath appendPath:volumePath];
            }
        }
    }];
    [fillPath closePath];
    
    //盘中实心点
    YXTimeLine *lastTimeModel = self.visibleArray.lastObject;
    NSString *timeStr = [NSString stringWithFormat:@"%lld", lastTimeModel.latestTime.value];
    if (timeStr.length >= 12) {
        NSString *string = [timeStr substringWithRange:NSMakeRange(8, 4)];
        if ([string isEqualToString:@"1600"]) {
            self.generator.timeLineDotLayer.hidden = YES;
        } else {
            self.generator.timeLineDotLayer.hidden = NO;
        }
    }
    self.generator.timeLineDotLayer.path = dotPath.CGPath;
    
    //分时价格线
    self.generator.timePriceLineLayer.path = minuteTimePath.CGPath;
    
    //交易量线
    self.generator.redVolumeLayer.path =  redVolumePath.CGPath;
    self.generator.greenVolumeLayer.path = greenVolumePath.CGPath;
    self.generator.greyVolumeLayer.path = greyVolumePath.CGPath;
    
    //米黄色价格均线
    if (self.chartType != YXTimeLineChartTypeHistory) {
        self.generator.averagePriceLayer.path = avergePricePath.CGPath;
        self.generator.yesterdayCloseLayer.path = preClosePath.CGPath;
    }

    //现价线
    if ([YXKLineConfigManager shareInstance].showNowPrice && self.chartType != YXTimeLineChartTypeHistory) {
        self.generator.nowPrice_Layer.path = nowPath.CGPath;
    } else {
        self.generator.nowPrice_Layer.path = nil;
    }

    //持仓成本线
    if ([YXKLineConfigManager shareInstance].showHoldPrice && self.holdPrice < maxHigh && self.holdPrice > minLow && self.holdPrice > 0) {
        UIBezierPath *holdPath = [UIBezierPath bezierPath];
        double y = [YXKLineUtility getYCoordinateWithMaxPrice:maxHigh minPrice:minLow price:self.holdPrice distance:candleDistance zeroY:zeroY];

        NSInteger nowCount = YX_KLINE_NOWPRICE_COUNT * self.frame.size.width / 300;
        // 现价线
        CGFloat padding = self.frame.size.width / nowCount * 0.5;
        CGFloat width = (self.frame.size.width - (padding * nowCount - 1)) / nowCount;
        for (int x = 0; x < nowCount; x++ ) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(x * (width + padding), y)];
            [path addLineToPoint:CGPointMake(x * (width + padding) + width, y)];
            [holdPath appendPath:path];
        }
        self.generator.holdPrice_Layer.path = holdPath.CGPath;
    } else {
        self.generator.holdPrice_Layer.path = nil;
    }
    
    //填充色
    self.generator.gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.timeLineRect), CGRectGetHeight(self.timeLineRect));
    self.generator.gradientLayer.hidden = NO;
    CAShapeLayer *arc = [CAShapeLayer layer];
    arc.path = fillPath.CGPath;
    self.generator.gradientLayer.mask = arc;
    
    // 盘前盘后填充色
    if (self.timeLineModel.isAll.value) {
        if (self.timeLineModel.days.value == 1) {
            // 一日
            NSInteger count = self.timeLineModel.list.count;
            NSInteger preAndIntraCount = (K_USPointDayNumber + K_USPonitPreQuoteNumber - 1);
            if (self.timeLineModel.type.value == 6) {
                preAndIntraCount = (K_USPointHalfDayNumber + K_USPonitPreQuoteNumber - 1);
            }
            BOOL fullPre = count >= K_USPonitPreQuoteNumber;
            BOOL needAfter = count >= preAndIntraCount;
            CGFloat preW = 0;
            if (fullPre) {
                preW = K_USPonitPreQuoteNumber * self.pointMargin;
            } else {
                preW = count * self.pointMargin;
            }
            UIBezierPath *prePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, preW, self.timeLineRect.size.height)];
            if (needAfter) {
                CGFloat afterX = preAndIntraCount * self.pointMargin;
                CGFloat afterW = (count - preAndIntraCount) * self.pointMargin;
                UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(afterX, 0, afterW, self.timeLineRect.size.height)];
                [prePath appendPath:path];
            }
            self.preAfterFillLayer.path = prePath.CGPath;
        } else {
            self.preAfterFillLayer.path = preAfterShadowPath.CGPath;
        }
    } else {
        self.preAfterFillLayer.path = nil;
    }
    self.generator.usMarketDayAndNight_Layer.path = dayAndNightPath.CGPath;
    
    // 盘前盘后图标
    if (self.timeLineModel.days.value == 1 && self.timeLineModel.isAll.value) {
        self.timeLineDayImgaeView.frame = CGRectMake(self.pointMargin * K_USPonitPreQuoteNumber - 5, self.timeLineRect.size.height + 2, 10, 10);
        if (self.timeLineModel.type.value == 6) {
            self.timeLineNightImgaeView.frame = CGRectMake(self.pointMargin * (K_USPonitPreQuoteNumber + K_USPointHalfDayNumber) - 5, self.timeLineRect.size.height + 2, 10, 10);
        } else {
            self.timeLineNightImgaeView.frame = CGRectMake(self.pointMargin * (K_USPonitPreQuoteNumber + K_USPointDayNumber) - 5, self.timeLineRect.size.height + 2, 10, 10);
        }
        self.timeLineDayImgaeView.hidden = NO;
        self.timeLineNightImgaeView.hidden = NO;
    } else {
        self.timeLineDayImgaeView.hidden = YES;
        self.timeLineNightImgaeView.hidden = YES;
    }
    
}

- (YXKLineOrderLayer *)createOrderLayer {
    YXKLineOrderLayer *layer = [[YXKLineOrderLayer alloc] init];
    layer.bounds = CGRectMake(0, 0, self.orderLayerWidth, self.orderLayerHeight);
    layer.drawStyle = YXKLineOrderStyleDashLine;
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.orderLayerArray];
    [array addObject:layer];
    self.orderLayerArray = array;
    return layer;
}

- (void)cleanData {
    
    // 分时价格线
    self.generator.timePriceLineLayer.path = nil;
    
    self.generator.nowPrice_Layer.path = nil;
    self.generator.yesterdayCloseLayer.path = nil;
    
    // 交易量线
    self.generator.redVolumeLayer.path = nil;
    self.generator.greenVolumeLayer.path = nil;
    self.generator.greyVolumeLayer.path = nil;

    // 米黄色价格均线
    self.generator.averagePriceLayer.path = nil;
    
    // 填充色
    self.generator.timeLineFillLayer.path = nil;
    
    // 价格&涨跌幅
    self.highestPriceLabel.text = @"--";
    self.lowestPriceLabel.text = @"--";
    self.pcloseLabel.text = @"--";
    self.highestRatioLabel.text = @"--";
    self.lowestRatioLabel.text = @"--";
    self.pcloseRatioLabel.text = @"--";

    self.secondHighPriceLabel.text = @"--";
    self.secondHighRocLabel.text = @"--";
    self.secondLowerPriceLabel.text = @"--";
    self.secondLowerRocLabel.text = @"--";

    self.subMaxVolumnLabel.text = @"--";
    self.subMidVolumnLabel.text = @"--";
    
    // 实心点
    self.generator.timeLineDotLayer.path = nil;
    // 填充
    self.generator.gradientLayer.hidden = YES;

    for (CALayer *layer in self.orderLayerArray) {
        [layer removeFromSuperlayer];
    }
    self.orderLayerArray = @[];
}

- (void)drawCrossingLayer {
    [self fitTimeLineLabelSize];
}

//时间轴时间frame调整
- (void)fitTimeLineLabelSize {
    if (self.timeLineModel.days.value != 5) {
        UILabel *timeLabel = self.oneDayTimeLabelArr[1];
       
        CGFloat offset;
        if ([self.timeLineModel.market isEqualToString:kYXMarketChinaSH] || [self.timeLineModel.market isEqualToString:kYXMarketChinaSZ]) {
            if (self.isGem) {
                offset = CGRectGetWidth(self.timeLineRect) * (2 / 4.5);
            } else {
                offset = CGRectGetWidth(self.timeLineRect) * 0.5;
            }
        } else if ([self.timeLineModel.market isEqualToString:kYXMarketSG]) {
            offset = 210 * CGRectGetWidth(self.frame) / (K_SGPonitDayNumber);
        } else {
            if (self.pointMargin == 0.0) {
                offset = 150 * CGRectGetWidth(self.frame) / (K_HKPonitDayNumber);
            } else {
                if ([self.timeLineModel.market isEqualToString:kYXMarketUS] || [self.timeLineModel.market isEqualToString:kYXMarketUsOption]) {
                    offset = CGRectGetWidth(self.timeLineRect) * 0.5;
                } else {
                    offset = CGRectGetWidth(self.timeLineRect) * (2.5 / 5.5);
                }
            }
        }
        [timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.mas_equalTo(self.mas_left).offset(offset);
        }];
    }
}


//时间轴时间frame调整
- (void)addTimeLabels {
    //时间轴时间(分时)
    for (int x = 0; x < 3; x ++) {
        UILabel *timeLabel = self.oneDayTimeLabelArr[x];
        [self addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(CGRectGetMaxY(self.timeLineRect) + 4);
            if (x == 0) {
                make.left.mas_equalTo(self.mas_left);
            } else if (x == 1) {
                CGFloat offset;

                if ([self.timeLineModel.market isEqualToString:kYXMarketChinaSH] || [self.timeLineModel.market isEqualToString:kYXMarketChinaSZ]) {
                    if (self.isGem) {
                        offset = CGRectGetWidth(self.timeLineRect) * (2 / 4.5);
                    } else {
                        offset = CGRectGetWidth(self.timeLineRect) * 0.5;
                    }
                } else if ([self.timeLineModel.market isEqualToString:kYXMarketSG]) {
                    offset = 210 * CGRectGetWidth(self.frame) / (K_SGPonitDayNumber);
                } else {
                    if (self.pointMargin == 0.0) {
                        offset = 150 * CGRectGetWidth(self.frame) / (K_HKPonitDayNumber);
                    } else {
                        if ([self.timeLineModel.market isEqualToString:kYXMarketUS] ||
                            [self.timeLineModel.market isEqualToString:kYXMarketUsOption]) {
                            offset = CGRectGetWidth(self.timeLineRect) * 0.5;
                        } else {
                            offset = CGRectGetWidth(self.timeLineRect) * (2.5 / 5.5);
                        }
                    }
                }
                make.centerX.mas_equalTo(self.mas_left).offset(offset);
            } else {
                make.right.mas_equalTo(self.mas_right);
            }
        }];
    }
    
    //时间轴时间(五日)
    for (int x = 0; x < 5; x ++) {
        UILabel *timeLabel = self.fiveDayTimeTitleArr[x];
        [self addSubview:timeLabel];
        timeLabel.frame = CGRectMake(0, CGRectGetMaxY(self.timeLineRect) + 4, 40, 12);
    }
    [self bringSubviewToFront:self.crossingTimeLabel];
}

- (void)reload {
    //画线
    [self drawAllLayers];
    //网格线
    [self drawCrossingLayer];
}

#pragma mark - lazy load
- (YXLayerGenerator *)generator {
    if (!_generator) {
        _generator = [[YXLayerGenerator alloc] init];
    }
    return _generator;
}

- (YXAccessoryTitleGenerator *)titleGenerator{
    
    if (!_titleGenerator) {
        _titleGenerator = [[YXAccessoryTitleGenerator alloc] init];
    }
    return _titleGenerator;
    
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer{

    if (!_doubleTapGestureRecognizer) {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizerAction:)];
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapGestureRecognizer;
}

- (UITapGestureRecognizer *)tapGestureRecognizer{
    
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
    }
    return _tapGestureRecognizer;
    
}

//单击手势事件
- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)gesture{
    
    if (self.canTapPush) {
        
        if (!self.generator.crossLineLayer.hidden) {
            [self hideTimeLinePressView];
        } else if (self.pushToLandscapeRightCallBack) {
            self.pushToLandscapeRightCallBack();
        }
        
    } else {
        
        [self hideTimeLinePressView];
        
    }
}

//双击手势事件
- (void)doubleTapGestureRecognizerAction:(UITapGestureRecognizer *)gesture {

    if (self.doubleTapCallBack) {
        self.doubleTapCallBack();
    }
}

//长按手势
- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
        _longPressGestureRecognizer.minimumPressDuration = 0.22;
    }
    return _longPressGestureRecognizer;
}

- (void)longPressGestureRecognizerAction:(UILongPressGestureRecognizer *)gesture {
    
    if (self.visibleArray.count == 0) {
        return;
    }
    //长按中
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    CGPoint point = [gesture locationInView:self];
    if (point.x < 0) {
        point.x = 0;
    }
    NSInteger location = round(point.x / self.pointMargin);
    
    
    if (location >= self.visibleArray.count) {
        location = self.visibleArray.count - 1;
    }
    if (location < 0) {
        location = 0;
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateBegan) {
        [self longPregressDrawWithLocation:location andPoint:point];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (location == 0 || (location == self.visibleArray.count - 1)) {
            [self longPregressDrawWithLocation:location andPoint:point];
        }
        [self performSelector:@selector(hideTimeLinePressView) withObject:nil afterDelay:3.0];
        
    }
}

- (void)longPregressDrawWithLocation:(NSInteger )location andPoint:(CGPoint)point{
    //这里是长按后圆圈
    double candleDistance = CGRectGetHeight(self.timeLineRect);
    double zeroY = CGRectGetMaxY(self.timeLineRect);
    
    //除数位数比
    NSInteger square = _timeLineModel.priceBase.value > 0 ? _timeLineModel.priceBase.value  : 3;
    double priceBasic = pow(10.0, square);
    
    self.generator.longPressCirclePriceLayer.hidden = NO;
    self.generator.longPressCircleAveragePriceLayer.hidden = NO;
    self.generator.crossLineLayer.hidden = NO;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    double minX = 0.0;
    double maxX = CGRectGetWidth(self.frame);
    double minY = self.timeLineRect.origin.y;
    double maxY = CGRectGetHeight(self.frame);
    double crossingLabelY = point.y - 10;
    
    double location_x = point.x;
    double location_y = point.y;
    
    if (point.x >= self.pointMargin * self.timeLineModel.list.count) { //最右边
        location_x = self.pointMargin * self.timeLineModel.list.count - self.pointMargin;
    }
    if (point.x <= 0.0) { //最左边
        location_x = 0.0;
    }
    if (point.y <= minY) {
        location_y = minY;
    }
    if (point.y >= CGRectGetMaxY(self.timeLineRect)) {
        location_y = CGRectGetMaxY(self.timeLineRect);
    }
    //横线
    [path moveToPoint:CGPointMake(minX, location_y)];
    [path addLineToPoint:CGPointMake(maxX, location_y)];
    //竖线
    [path moveToPoint:CGPointMake(location_x, minY)];
    [path addLineToPoint:CGPointMake(location_x, maxY )];
    [path closePath];
    self.generator.crossLineLayer.path = path.CGPath;
    
    //价格 && 涨跌幅
    self.titleGenerator.timeLineCrossingRocLabel.hidden = NO;
    self.titleGenerator.timeLineCrossingPriceLabel.hidden = NO;
    if (crossingLabelY <= minY) {
        crossingLabelY = minY;
    }
    if (crossingLabelY >= CGRectGetMaxY(self.timeLineRect) - 20) {
        crossingLabelY = CGRectGetMaxY(self.timeLineRect) - 20;
    }
    [self.titleGenerator.timeLineCrossingPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(crossingLabelY);
    }];
    [self.titleGenerator.timeLineCrossingRocLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(crossingLabelY);
    }];
    
    NSString *price;
    if (square == 3) {
        price = [NSString stringWithFormat:@"%.3lf", [YXKLineUtility getPriceWithMaxPrice:self.maxHigh minPrice:self.minLow currentY:location_y distance:CGRectGetHeight(self.timeLineRect) zeroY:minY]];
    } else {
        price = [NSString stringWithFormat:@"%.2lf", [YXKLineUtility getPriceWithMaxPrice:self.maxHigh minPrice:self.minLow currentY:location_y distance:CGRectGetHeight(self.timeLineRect) zeroY:minY]];
    }
    NSString *roc;
    if (self.timeLineModel.list.count > 0) {
        YXTimeLine *firstTimeLineModel = self.timeLineModel.list.firstObject;
        if (firstTimeLineModel.preClose.value == 0) {
            roc = @"";
        } else {
            roc = [NSString stringWithFormat: @"%.2f%@", (price.doubleValue - firstTimeLineModel.preClose.value / priceBasic) / (firstTimeLineModel.preClose.value / priceBasic) * 100, @"%"];
        }
    } else {
        roc = @"--";
    }
    self.titleGenerator.timeLineCrossingPriceLabel.text = price;
    self.titleGenerator.timeLineCrossingRocLabel.text = roc;
    
    //圆圈
    YXTimeLine *obj = self.visibleArray[location];
    CGPoint circlePoint = CGPointMake(location_x, [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.price.value / priceBasic distance:candleDistance zeroY:zeroY]);
    UIBezierPath *pricecirclePath = [UIBezierPath bezierPathWithArcCenter:circlePoint radius:3 startAngle:0 endAngle:360 clockwise:YES];
    self.generator.longPressCirclePriceLayer.path = pricecirclePath.CGPath;
    
    CGPoint averagePonit = CGPointMake(location_x, [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.avg.value * 1.0 / priceBasic distance:candleDistance zeroY:zeroY]);
    UIBezierPath *averagePath = [UIBezierPath bezierPathWithArcCenter:averagePonit radius:3 startAngle:0 endAngle:360 clockwise:YES];
    self.generator.longPressCircleAveragePriceLayer.path = averagePath.CGPath;
    
    //分时时间
    self.crossingTimeLabel.hidden = NO;
    YXTimeLine *timeLineSingleModel = self.timeLineModel.list[location];
    self.crossingTimeLabel.text = timeLineSingleModel.latestTime.value > 0 ? [YXDateHelper commonDateStringWithNumber:timeLineSingleModel.latestTime.value format:YXCommonDateFormatDF_MDHM scaleType:YXCommonDateScaleTypeScale showWeek:NO] : @"--:--";
    self.crossingTimeLabel.frame = CGRectMake(location_x - 37, CGRectGetMaxY(self.timeLineRect), 74, 20);
    if (self.crossingTimeLabel.frame.origin.x <= self.frame.origin.x) {
        self.crossingTimeLabel.frame = CGRectMake(0, CGRectGetMaxY(self.timeLineRect), 74, 20);
    }
    if (CGRectGetMaxX(self.crossingTimeLabel.frame) >= self.frame.size.width) {
        self.crossingTimeLabel.frame = CGRectMake(self.frame.size.width - 74, CGRectGetMaxY(self.timeLineRect), 74, 20);
    }
    
    //动态改变参数数值
    if (self.timeLineLongPressStartCallBack) {
        self.timeLineLongPressStartCallBack(self.visibleArray[location]);
    }
}

- (double)getCrossingPriceWithCurrentY:(double)currentY{
    
    double candleDistance = CGRectGetHeight(self.timeLineRect);
    double zeroY = CGRectGetMaxY(self.timeLineRect);
    
    return [YXKLineUtility getPriceWithMaxPrice:self.minLow minPrice:self.maxHigh currentY:currentY distance:candleDistance zeroY:zeroY];
    
}

//最高价
- (UILabel *)highestPriceLabel{
    if (!_highestPriceLabel) {
        _highestPriceLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _highestPriceLabel;
}

//最低价
- (UILabel *)lowestPriceLabel{
    
    if (!_lowestPriceLabel) {
        _lowestPriceLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _lowestPriceLabel;
    
}
//最高涨跌幅
- (UILabel *)highestRatioLabel{
    
    if (!_highestRatioLabel) {
        _highestRatioLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _highestRatioLabel;
    
}
//最低涨跌幅
- (UILabel *)lowestRatioLabel{
    
    if (!_lowestRatioLabel) {
        _lowestRatioLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _lowestRatioLabel;
    
}

- (UILabel *)pcloseLabel{
    
    if (!_pcloseLabel) {
        _pcloseLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _pcloseLabel;
    
}

- (UILabel *)pcloseRatioLabel{
    
    if (!_pcloseRatioLabel) {
        _pcloseRatioLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _pcloseRatioLabel;
    
}

// 次高价
- (UILabel *)secondHighPriceLabel{
    if (!_secondHighPriceLabel) {
        _secondHighPriceLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _secondHighPriceLabel;
}
// 次高涨幅
- (UILabel *)secondHighRocLabel{
    if (!_secondHighRocLabel) {
        _secondHighRocLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _secondHighRocLabel;
}

// 次低价
- (UILabel *)secondLowerPriceLabel{
    if (!_secondLowerPriceLabel) {
        _secondLowerPriceLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _secondLowerPriceLabel;
}
// 次低涨幅
- (UILabel *)secondLowerRocLabel{
    if (!_secondLowerRocLabel) {
        _secondLowerRocLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _secondLowerRocLabel;
}

- (UILabel *)subMaxVolumnLabel{
    if (!_subMaxVolumnLabel) {
        _subMaxVolumnLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _subMaxVolumnLabel;
}
- (UILabel *)subMidVolumnLabel{
    if (!_subMidVolumnLabel) {
        _subMidVolumnLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _subMidVolumnLabel;
}

- (QMUILabel *)crossingTimeLabel{
    
    if (!_crossingTimeLabel) {
        _crossingTimeLabel = [QMUILabel labelWithText:@"" textColor:QMUITheme.longPressTextColor textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
        //_crossingTimeLabel.contentEdgeInsets = UIEdgeInsetsMake(3, 4, 3, 4);
        _crossingTimeLabel.backgroundColor = QMUITheme.longPressBgColor;
        _crossingTimeLabel.textAlignment = NSTextAlignmentCenter;
        _crossingTimeLabel.layer.cornerRadius = 2.0;
        _crossingTimeLabel.layer.masksToBounds = YES;
        
    }
    return _crossingTimeLabel;
    
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = QMUITheme.separatorLineColor;
    }
    return _lineView;
}

- (NSMutableArray *)oneDayTimeLabelArr{
    
    if (!_oneDayTimeLabelArr) {
        _oneDayTimeLabelArr = [NSMutableArray array];
        NSArray *timeArr = @[@"09:30", @"12:00", @"16:00"];
        for (int x = 0; x < 3; x ++) {
            UILabel *timeLabel = [UILabel labelWithText:@"" textColor:YX_TEXT_COLOR2 textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
            [_oneDayTimeLabelArr addObject:timeLabel];
            timeLabel.text = timeArr[x];
        }
    }
    return _oneDayTimeLabelArr;
    
}

- (NSMutableArray *)fiveDayTimeTitleArr{
    
    if (!_fiveDayTimeTitleArr) {
        _fiveDayTimeTitleArr = [NSMutableArray array];
        for (int x = 0; x < 5; x ++) {
            UILabel *timeLabel = [UILabel labelWithText:@"" textColor:YX_TEXT_COLOR2 textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
            if (x > 0) {                
                timeLabel.textAlignment = NSTextAlignmentCenter;
            }
            [_fiveDayTimeTitleArr addObject:timeLabel];
        }
    }
    
    return _fiveDayTimeTitleArr;
    
}

- (UIImageView *)timeLineDayImgaeView {
    if (_timeLineDayImgaeView == nil) {
        _timeLineDayImgaeView = [[UIImageView alloc] init];
        _timeLineDayImgaeView.image = [UIImage imageNamed:@"timeline_day"];
        _timeLineDayImgaeView.hidden = YES;
    }
    return _timeLineDayImgaeView;
}

- (UIImageView *)timeLineNightImgaeView {
    if (_timeLineNightImgaeView == nil) {
        _timeLineNightImgaeView = [[UIImageView alloc] init];
        _timeLineNightImgaeView.image = [UIImage imageNamed:@"timeline_night"];
        _timeLineNightImgaeView.hidden = YES;
    }
    return _timeLineNightImgaeView;
}



- (void)setTimeLineModel:(YXTimeLineData *)timeLineModel{
    
    _timeLineModel = timeLineModel;

    if (timeLineModel.days.value == 5) {
        self.hasOrder = NO;
    }
    if ([timeLineModel.market isEqualToString:kYXMarketHK]) {
        if (timeLineModel.days.value == 1) {
            
            for (UILabel *timeLabel in self.fiveDayTimeTitleArr) {
                timeLabel.hidden = YES;
            }
            for (UILabel *timeLabel in self.oneDayTimeLabelArr) {
                timeLabel.hidden = NO;
            }
            // 0：非暗盘，1：暗盘全日（16:15~18:30），2：暗盘半日（14:15~16:30）
            if (timeLineModel.type.value == 1 || timeLineModel.type.value == 2) {

                UILabel *openTimeLabel = self.oneDayTimeLabelArr[0];
                UILabel *midTimeLabel = self.oneDayTimeLabelArr[1];
                UILabel *closeTimeLabel = self.oneDayTimeLabelArr[2];
                midTimeLabel.hidden = true;
                if (timeLineModel.type.value == 1) {
                    openTimeLabel.text = @"16:15";
                    closeTimeLabel.text = @"18:30";
                } else {
                    openTimeLabel.text = @"14:15";
                    closeTimeLabel.text = @"16:30";
                }
                _pointMargin = CGRectGetWidth(self.frame) / (135);
            } else {
                _pointMargin = CGRectGetWidth(self.frame) / (K_HKPonitDayNumber);
                UILabel *timeLabel = self.oneDayTimeLabelArr[1];
                timeLabel.text = @"12:00/13:00";
            }
            
        } else if (timeLineModel.days.value == 5) {
            _pointMargin = CGRectGetWidth(self.frame) / (K_HKPonitFiveDayNumber);
            for (UILabel *timeLabel in self.oneDayTimeLabelArr) {
                timeLabel.hidden = YES;
            }
            for (UILabel *timeLabel in self.fiveDayTimeTitleArr) {
                timeLabel.hidden = NO;
            }
        }
        //0：非暗盘，1：暗盘全日（16:15~18:30），2：暗盘半日（14:15~16:30）,3：科创版分时, 4：盘前行情，5：盘后行情。6：美股盘后半日市（13:00~17:00）。
    } else if ([timeLineModel.market isEqualToString:kYXMarketUS] || [timeLineModel.market isEqualToString:kYXMarketUsOption]) {
        if (timeLineModel.days.value == 1) {
            for (UILabel *timeLabel in self.fiveDayTimeTitleArr) {
                timeLabel.hidden = YES;
            }
            if (timeLineModel.isAll.value) {
                if (timeLineModel.type.value == 6) {
                    _pointMargin = CGRectGetWidth(self.frame) / (K_USPonitHalfAllQuoteNumber);
                    for (UILabel *timeLabel in self.oneDayTimeLabelArr) {
                        timeLabel.hidden = NO;
                    }
                    UILabel *openTimeLabel = self.oneDayTimeLabelArr[0];
                    UILabel *midTimeLabel = self.oneDayTimeLabelArr[1];
                    UILabel *closeTimeLabel = self.oneDayTimeLabelArr[2];
                    openTimeLabel.text = @"04:00";
                    midTimeLabel.hidden = YES;
                    closeTimeLabel.text = @"17:00";
                } else {
                    _pointMargin = CGRectGetWidth(self.frame) / (K_USPonitAllQuoteNumber);
                    for (UILabel *timeLabel in self.oneDayTimeLabelArr) {
                        timeLabel.hidden = NO;
                    }
                    UILabel *openTimeLabel = self.oneDayTimeLabelArr[0];
                    UILabel *midTimeLabel = self.oneDayTimeLabelArr[1];
                    UILabel *closeTimeLabel = self.oneDayTimeLabelArr[2];
                    openTimeLabel.text = @"04:00";
                    midTimeLabel.text = @"12:00";
                    closeTimeLabel.text = @"20:00";
                }
            } else {
                //4：盘前行情，5：盘后行情，6：美股盘后半日市（13:00~17:00）。
                if (timeLineModel.type.value == 4) {
                    UILabel *openTimeLabel = self.oneDayTimeLabelArr[0];
                    UILabel *midTimeLabel = self.oneDayTimeLabelArr[1];
                    UILabel *closeTimeLabel = self.oneDayTimeLabelArr[2];
                    openTimeLabel.text = @"04:00";
                    midTimeLabel.text = @"06:45";
                    closeTimeLabel.text = @"09:30";
                    _pointMargin = CGRectGetWidth(self.frame) / (K_USPonitPreQuoteNumber);
                } else if (timeLineModel.type.value == 5) {
                    UILabel *openTimeLabel = self.oneDayTimeLabelArr[0];
                    UILabel *midTimeLabel = self.oneDayTimeLabelArr[1];
                    UILabel *closeTimeLabel = self.oneDayTimeLabelArr[2];
                    openTimeLabel.text = @"16:00";
                    midTimeLabel.text = @"18:00";
                    closeTimeLabel.text = @"20:00";
                    _pointMargin = CGRectGetWidth(self.frame) / (K_USPonitAfterQuoteNumber);
                } else if (timeLineModel.type.value == 6) {
                    UILabel *openTimeLabel = self.oneDayTimeLabelArr[0];
                    UILabel *midTimeLabel = self.oneDayTimeLabelArr[1];
                    UILabel *closeTimeLabel = self.oneDayTimeLabelArr[2];
                    midTimeLabel.hidden = true;
                    openTimeLabel.text = @"13:00";
                    closeTimeLabel.text = @"17:00";
                    _pointMargin = CGRectGetWidth(self.frame) / (K_USPonitAfterQuoteNumber);
                } else {
                    _pointMargin = CGRectGetWidth(self.frame) / (K_USPointDayNumber);
                    for (UILabel *timeLabel in self.oneDayTimeLabelArr) {
                        timeLabel.hidden = NO;
                    }
                    UILabel *openTimeLabel = self.oneDayTimeLabelArr[0];
                    UILabel *midTimeLabel = self.oneDayTimeLabelArr[1];
                    UILabel *closeTimeLabel = self.oneDayTimeLabelArr[2];
                    openTimeLabel.text = @"09:30";
                    midTimeLabel.text = @"12:45";
                    closeTimeLabel.text = @"16:00";
                }
            }
        } else if (timeLineModel.days.value == 5) {
            if (timeLineModel.isAll.value) {
                _pointMargin = CGRectGetWidth(self.frame) / (K_USPointAllQuoteFiveDayNumber);
            } else {
                _pointMargin = CGRectGetWidth(self.frame) / (K_USPointFiveDayNumber);
            }
            for (UILabel *timeLabel in self.oneDayTimeLabelArr) {
                timeLabel.hidden = YES;
            }
            for (UILabel *timeLabel in self.fiveDayTimeTitleArr) {
                timeLabel.hidden = NO;
            }
        }
        
    } else if ([timeLineModel.market isEqualToString:kYXMarketChinaSH] || [timeLineModel.market isEqualToString:kYXMarketChinaSZ]) {
        if (self.isGem) {
            // 科创板
            if (timeLineModel.days.value == 1) {
                _pointMargin = CGRectGetWidth(self.frame) / (K_CHGEMPointDayNumber);
                for (UILabel *timeLabel in self.fiveDayTimeTitleArr) {
                    timeLabel.hidden = YES;
                }
                for (UILabel *timeLabel in self.oneDayTimeLabelArr) {
                    timeLabel.hidden = NO;
                }
                UILabel *midLabel = self.oneDayTimeLabelArr[1];
                midLabel.text = @"11:30/13:00";
                UILabel *lastLabel = self.oneDayTimeLabelArr[2];
                lastLabel.text = @"15:30";
            } else if (timeLineModel.days.value == 5) {
                _pointMargin = CGRectGetWidth(self.frame) / (K_CHGEMPointFiveDayNumber);
                for (UILabel *timeLabel in self.oneDayTimeLabelArr) {
                    timeLabel.hidden = YES;
                }
                for (UILabel *timeLabel in self.fiveDayTimeTitleArr) {
                    timeLabel.hidden = NO;
                }
            }
        } else {
            if (timeLineModel.days.value == 1) {
                _pointMargin = CGRectGetWidth(self.frame) / (K_CHPointDayNumber);
                for (UILabel *timeLabel in self.fiveDayTimeTitleArr) {
                    timeLabel.hidden = YES;
                }
                for (UILabel *timeLabel in self.oneDayTimeLabelArr) {
                    timeLabel.hidden = NO;
                }
                UILabel *midLabel = self.oneDayTimeLabelArr[1];
                midLabel.text = @"11:30/13:00";
                UILabel *lastLabel = self.oneDayTimeLabelArr[2];
                lastLabel.text = @"15:00";
            } else if (timeLineModel.days.value == 5) {
                _pointMargin = CGRectGetWidth(self.frame) / (K_CHPointFiveDayNumber);
                for (UILabel *timeLabel in self.oneDayTimeLabelArr) {
                    timeLabel.hidden = YES;
                }
                for (UILabel *timeLabel in self.fiveDayTimeTitleArr) {
                    timeLabel.hidden = NO;
                }
            }
        }
    } else if ([timeLineModel.market isEqualToString:kYXMarketSG]) {
        if (timeLineModel.days.value == 1) {
            
            for (UILabel *timeLabel in self.fiveDayTimeTitleArr) {
                timeLabel.hidden = YES;
            }
            for (UILabel *timeLabel in self.oneDayTimeLabelArr) {
                timeLabel.hidden = NO;
            }
            _pointMargin = CGRectGetWidth(self.frame) / (K_SGPonitDayNumber);
            
            UILabel *openTimeLabel = self.oneDayTimeLabelArr[0];
            UILabel *midTimeLabel = self.oneDayTimeLabelArr[1];
            UILabel *closeTimeLabel = self.oneDayTimeLabelArr[2];
            openTimeLabel.text = @"9:00";
            midTimeLabel.text = @"12:00/13:00";
            closeTimeLabel.text = @"17:16";
            
        } else if (timeLineModel.days.value == 5) {
            _pointMargin = CGRectGetWidth(self.frame) / (K_SGPointFiveDayNumber);
            for (UILabel *timeLabel in self.oneDayTimeLabelArr) {
                timeLabel.hidden = YES;
            }
            for (UILabel *timeLabel in self.fiveDayTimeTitleArr) {
                timeLabel.hidden = NO;
            }
        }
        //0：非暗盘，1：暗盘全日（16:15~18:30），2：暗盘半日（14:15~16:30）,3：科创版分时, 4：盘前行情，5：盘后行情。6：美股盘后半日市（13:00~17:00）。
    }
    
    for (YXTimeLine * singleModel in timeLineModel.list) {
        if (timeLineModel.priceBase) {
            singleModel.priceBase = timeLineModel.priceBase;
        }
    }
    _volumeWidth = _pointMargin;

    if (timeLineModel.days.value == 1) {
        _volumeWidth = 1.5 > _pointMargin ? _pointMargin: 1.5;
    } else if (timeLineModel.days.value == 5) {
        _volumeWidth = 0.75 > _pointMargin ? _pointMargin: 0.75;
    }
}

- (void)hideTimeLinePressView {
    
    self.generator.crossLineLayer.hidden = YES;
    self.generator.longPressCirclePriceLayer.hidden = YES;
    self.generator.longPressCircleAveragePriceLayer.hidden = YES;
    self.crossingTimeLabel.hidden = YES;
    
    self.titleGenerator.timeLineCrossingRocLabel.hidden = YES;
    self.titleGenerator.timeLineCrossingPriceLabel.hidden = YES;
    
    //动态改变参数数值
    if (self.timeLineLongPressEndCallBack) {
        self.timeLineLongPressEndCallBack();
    }
    
}

- (NSString *)nextTimeStr: (NSString *)currentStr {
    
    if ([currentStr isEqualToString:@"0400"]) {
        return @"0930";
    } else if ([currentStr isEqualToString:@"0930"]) {
        return @"1600";
    } else if ([currentStr isEqualToString:@"1600"]) {
        return @"0930";
    }
    return @"0400";

}

@end
