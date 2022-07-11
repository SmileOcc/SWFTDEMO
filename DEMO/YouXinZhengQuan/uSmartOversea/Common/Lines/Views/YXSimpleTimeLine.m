//
//  NSSimpleTimeLine.m
//  LIne
//
//  Created by Kelvin on 2019/4/4.
//  Copyright © 2019年 Kelvin. All rights reserved.
//

#import "YXSimpleTimeLine.h"
#import "YXLayerGenerator.h"
#import "YXTimeLineModel.h"
#import "YXSecuID.h"
#import <Masonry/Masonry.h>
#import "YXToolUtility.h"
#import "YXDateToolUtility.h"
#import "uSmartOversea-Swift.h"
#import <YXKit/YXKit.h>

//#define kDashPointCount 10.0
#define kDashLineWidth 2
#define kMaxXKey @"maxX"
@interface YXSimpleTimeLine ()

@property (nonatomic, assign) double pointMargin;
@property (nonatomic, strong) YXLayerGenerator *generator;

@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, assign) NSInteger pointCount;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
// 长按横线
@property (nonatomic, strong) UIView *hLongPressLineView;
// 长按纵线
@property (nonatomic, strong) UIView *vLongPressLineView;
// 分时点的Y坐标值
@property (nonatomic, strong) NSMutableDictionary *yValueDic;
@property (nonatomic, strong) UIView *longPressView;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *timeIconImageView;

@property (nonatomic, assign) int prePctchngValue;

@end

@implementation YXSimpleTimeLine

- (instancetype)initWithFrame:(CGRect)frame market:(NSString *)market {
    return [self initWithFrame:frame market:market minute:1];
}

- (instancetype)initWithFrame:(CGRect)frame market:(NSString *)market minute:(NSInteger)minute {
    self = [super initWithFrame:frame];
    if (self) {
        self.minute = minute;
        self.market = market;
//        self.backgroundColor = [UIColor whiteColor];
        self.dashPointCount = 10.0;
        [self addGestureRecognizer:self.longPressGestureRecognizer];
        [self addSubview:self.hLongPressLineView];
        [self addSubview:self.vLongPressLineView];
        [self addSubview:self.longPressView];
        [self.vLongPressLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(0.5);
            make.left.equalTo(self).offset(0);
        }];
        
        [self.hLongPressLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(0.5);
            make.top.equalTo(self).offset(0);
        }];
        
        [self.longPressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.vLongPressLineView);
            make.centerY.equalTo(self.hLongPressLineView);
            make.width.mas_greaterThanOrEqualTo(50);
        }];
    }
    return self;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updatePointMargin];
}

- (void)setEnableLongPress:(BOOL)enableLongPress {
    _enableLongPress = enableLongPress;
    self.longPressGestureRecognizer.enabled = enableLongPress;
}

- (void)setMarket:(NSString *)market {
    
    _market = market;
    [self updatePointMargin];
}

- (void)updatePointMargin {
    if ([self.market isEqualToString:kYXMarketUS] || [self.market isEqualToString:kYXMarketUsOption]) {
        self.pointCount = 390/self.minute + 1;
    } else if ([self.market isEqualToString:kYXMarketHK]) {
        self.pointCount = 330/self.minute + 2;
    } else if ([self.market isEqualToString:kYXMarketSG]) {
        self.pointCount = 466/self.minute + 2;
    } else if ([self.market isEqualToString:@"sh"] || [self.market isEqualToString:@"sz"]) {
        if (self.quote.listSector.value == OBJECT_MARKETListedSector_LsStar || self.quote.listSector.value == OBJECT_MARKETListedSector_LsGemb) {
            self.pointCount = 270/self.minute + 2;
        } else {
            if ([self.symbol hasPrefix:@"688"] || [self.symbol hasPrefix:@"3"]) {
                self.pointCount = 270/self.minute + 2;
            } else {
                self.pointCount = 240/self.minute + 2;
            }
        }
    }
    self.pointMargin = self.frame.size.width / self.pointCount;
}

- (void)setSymbol:(NSString *)symbol {
    
    _symbol = symbol;
    [self updatePointMargin];
}

- (void)setQuote:(YXV2Quote *)quote {
    _quote = quote;
    [self updatePointMargin];
    
    if(_timeModel.type != 3) {
        if (self.quote.pctchng > 0) {
            if (self.prePctchngValue <= 0) {
                [self refreshColor:[YXToolUtility stockChangeColor:_quote.pctchng.value]];
                self.prePctchngValue = _quote.pctchng.value;
            }
        }else if (self.quote.pctchng < 0) {
            if (self.prePctchngValue >= 0) {
                [self refreshColor:[YXToolUtility stockChangeColor:_quote.pctchng.value]];
                self.prePctchngValue = _quote.pctchng.value;
            }
        } else {
            if (self.prePctchngValue != 0) {
                [self refreshColor:[YXToolUtility stockChangeColor:_quote.pctchng.value]];
                self.prePctchngValue = _quote.pctchng.value;
            }
        }
    }
}


- (void)initBaseView {
    
    [self.layer addSublayer:self.generator.timePriceLineLayer];
    [self.layer addSublayer:self.generator.yesterdayCloseLayer];
    [self.layer addSublayer:self.generator.gradientLayer];
}

- (void)drawAllLayers {
    
    /*
    if (_timeModel.type != 0) { // 暗盘不显示分时图
        [self.generator.timePriceLineLayer removeFromSuperlayer];
        [self.generator.yesterdayCloseLayer removeFromSuperlayer];
        [self.generator.gradientLayer removeFromSuperlayer];
        return;
    }
     */
    
    if (_timeModel.list.count <= 0) {
        [self.generator.timePriceLineLayer removeFromSuperlayer];
        [self.generator.yesterdayCloseLayer removeFromSuperlayer];
        [self.generator.gradientLayer removeFromSuperlayer];
        self.generator.yesterdayCloseLayer = [YXKLineUtility shapeLayerWithStokeColor:[QMUITheme stockGrayColor] fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapRound lineJoin:kCALineJoinRound];
        [self.layer addSublayer:self.generator.yesterdayCloseLayer];
        
        UIBezierPath *pClosePath = [UIBezierPath bezierPath];
        CGFloat width = (self.frame.size.width - kDashLineWidth * 2) / self.dashPointCount;
        for (int x = 0; x <= self.dashPointCount; x++ ) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(x * width, self.frame.size.height/2)];
            [path addLineToPoint:CGPointMake(x * width + kDashLineWidth, self.frame.size.height/2)];
            [pClosePath appendPath:path];
        }
        self.generator.yesterdayCloseLayer.path = pClosePath.CGPath;
        return;
    }
    YXTimeLineSingleModel *singleTimeModel = _timeModel.list.firstObject;
    //除数位数比
    NSInteger square = _timeModel.price_base.length > 0 ? _timeModel.price_base.integerValue : 1;
    NSInteger priceBasic = pow(10.0, square);
    //当前区域的最高值
    double nowMaxHigh = [[_timeModel.list valueForKeyPath:@"@max.price.integerValue"] integerValue] * 1.0 / priceBasic;
    double pCloseMaxHigh = [[_timeModel.list valueForKeyPath:@"@max.pclose.integerValue"] integerValue] * 1.0 / priceBasic;
    double maxHigh = MAX(nowMaxHigh, pCloseMaxHigh);
    
    //当前区域的最低值
    double nowMinLow = [[_timeModel.list valueForKeyPath:@"@min.price.integerValue"] integerValue] * 1.0 / priceBasic;
    double avgMinLow = [[_timeModel.list valueForKeyPath:@"@min.pclose.integerValue"] integerValue] * 1.0 / priceBasic;
    double minLow = MIN(nowMinLow, avgMinLow);
    
    //分时线的画图区域
    double candleDistance = CGRectGetHeight(self.frame);
    //画图刻度 && 贝塞尔曲线
    double zeroY = CGRectGetMaxY(self.frame) - self.frame.origin.y;
    UIBezierPath *pricePath = [UIBezierPath bezierPath];
    UIBezierPath *pClosePath = [UIBezierPath bezierPath];
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    //填充部分
    [fillPath moveToPoint:CGPointMake(0, candleDistance)];
    //昨收
    double pClosePoint_y = [YXKLineUtility getYCoordinateWithMaxPrice:maxHigh minPrice:minLow price:singleTimeModel.pclose.doubleValue / priceBasic distance:candleDistance zeroY:zeroY];
    __block UIColor *color = [QMUITheme stockGrayColor];
    [_timeModel.list enumerateObjectsUsingBlock:^(YXTimeLineSingleModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        double x = idx * self.pointMargin;
        //价格
        double minuteTimePoint_y = [YXKLineUtility getYCoordinateWithMaxPrice:maxHigh minPrice:minLow price:obj.price.doubleValue / priceBasic distance:candleDistance zeroY:zeroY];
        //把y坐标缓存起来，长按的时候使用
//        [self.yValueDic setValue:@(minuteTimePoint_y) forKey:[NSString stringWithFormat:@"%lu", (unsigned long)idx]];
//        [self.yValueDic setValue:@(x) forKey:kMaxXKey];
        
        if (idx == 0) {
            
            [pricePath moveToPoint:CGPointMake(x, minuteTimePoint_y)];
            [fillPath addLineToPoint:CGPointMake(x, minuteTimePoint_y)];
            
        } else {
            
            [pricePath addLineToPoint:CGPointMake(x, minuteTimePoint_y)];
            [fillPath addLineToPoint:CGPointMake(x, minuteTimePoint_y)];
            
        }
        if (idx == _timeModel.list.count - 1) {
            
            [fillPath addLineToPoint:CGPointMake(x, candleDistance)];
            if (self.quote.pctchng) {
                color = [YXToolUtility stockChangeColor:self.quote.pctchng.value];
            } else {
                if (obj.price.doubleValue > obj.pclose.doubleValue) {
                    color = [QMUITheme stockRedColor];
                } else if (obj.price.doubleValue < obj.pclose.doubleValue) {
                    color = [QMUITheme stockGreenColor];
                } else if (obj.price.doubleValue == obj.pclose.doubleValue) {
                    color = [QMUITheme stockGrayColor];
                }
            }
        }
    }];
    
    [fillPath closePath];
    CGFloat width = (self.frame.size.width - kDashLineWidth * 2) / self.dashPointCount;
    for (int x = 0; x <= self.dashPointCount; x++ ) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(x * width, pClosePoint_y)];
        [path addLineToPoint:CGPointMake(x * width + kDashLineWidth, pClosePoint_y)];
        [pClosePath appendPath:path];
    }
    
    self.prePctchngValue = self.quote.pctchng.value;

    
    [self.generator.timePriceLineLayer removeFromSuperlayer];
    self.generator.timePriceLineLayer = [YXKLineUtility shapeLayerWithStokeColor:color fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapRound lineJoin:kCALineJoinRound];
    [self.layer addSublayer:self.generator.timePriceLineLayer];
    
    [self.generator.yesterdayCloseLayer removeFromSuperlayer];
    self.generator.yesterdayCloseLayer = [YXKLineUtility shapeLayerWithStokeColor:color fillColor:[UIColor clearColor] lineWidth:1 lineCap:kCALineCapRound lineJoin:kCALineJoinRound];
    [self.layer addSublayer:self.generator.yesterdayCloseLayer];
    
    self.generator.yesterdayCloseLayer.path = pClosePath.CGPath;
    self.generator.timePriceLineLayer.path = pricePath.CGPath;
    
    //填充色
    [self.generator.gradientLayer removeFromSuperlayer];
    [self.layer addSublayer:self.generator.gradientLayer];
    self.generator.gradientLayer.frame = self.bounds;
    self.generator.gradientLayer.colors = @[(__bridge id)[color colorWithAlphaComponent:0.2].CGColor,
                              (__bridge id)[color colorWithAlphaComponent:0.0].CGColor];
    CAShapeLayer *arc = [CAShapeLayer layer];
    arc.path = fillPath.CGPath;
    self.generator.gradientLayer.mask = arc;
}

#pragma mark - set
- (void)setTimeModel:(YXTimeLineModel *)timeModel {
    
    YXTimeLineModel *newTimeLineModel = [[YXTimeLineModel alloc] init];
    newTimeLineModel.price_base = timeModel.price_base;
    newTimeLineModel.market = timeModel.market;
    newTimeLineModel.days = timeModel.days;
    newTimeLineModel.chartType = timeModel.chartType;
    newTimeLineModel.delay = timeModel.delay;
    newTimeLineModel.type = timeModel.type;
    
    if (self.minute != 1) {
        NSMutableArray<YXTimeLineSingleModel *> *list = [NSMutableArray array];
          NSInteger count = timeModel.list.count;
          __block NSInteger pointCount = 1;
          [timeModel.list enumerateObjectsUsingBlock:^(YXTimeLineSingleModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
              if (idx == 0) {
                  [list addObject:obj];
              } else if (![self.market isEqualToString:kYXMarketUS] && ![self.market isEqualToString:kYXMarketUsOption] && [obj.time length] > 8 && [[obj.time substringFromIndex:8] isEqualToString:@"130000000"]) {
                  pointCount = 2;
                  [list addObject:obj];
              } else if ((idx - pointCount)%self.minute == 0) {
                  [list addObject:obj];
              } else if (idx + 1 == count) {
                  [list addObject:obj];
              }
          }];
          newTimeLineModel.list = list;
    } else {
        newTimeLineModel.list = timeModel.list;
    }
    
    _timeModel = newTimeLineModel;
    [self drawAllLayers];
    
}

- (void)longPressGestureRecognizerAction:(UILongPressGestureRecognizer *)gesture {
    
    if (self.timeModel.list.count == 0) {
        return;
    }
    //长按中
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint pointInView = [gesture locationInView:self];
        self.vLongPressLineView.hidden = NO;
        self.hLongPressLineView.hidden = NO;
        self.longPressView.hidden = NO;
        [self bringSubviewToFront:self.longPressView];
        
        CGFloat x = pointInView.x;
        NSNumber *maxX = self.yValueDic[kMaxXKey];
        
        if (x <= 0) {
            x = 0;
        }
        if (x >= maxX.floatValue) {
            x = maxX.floatValue;
        }
        NSInteger index = round(x / (self.pointMargin));
        
        if (index < self.timeModel.list.count) {
            YXTimeLineSingleModel *model = self.timeModel.list[index];
    
            self.valueLabel.text = [YXToolUtility stockPriceData:model.price.doubleValue deciPoint:model.priceBase.integerValue priceBase:model.priceBase.integerValue];
            
            YXDateModel *dateModel = [YXDateToolUtility dateTimeAndWeekWithTimeString:model.time];
            self.timeLabel.text = [NSString stringWithFormat:@"%@:%@", dateModel.hour, dateModel.minute];
        }
        
        NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
        NSNumber *y = self.yValueDic[key];
        
        [self.hLongPressLineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(y.floatValue);
        }];
        
        [self.vLongPressLineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(x);
        }];
        
        // 偏移十字交叉点
        CGFloat offset = 0.0;
        if (y.floatValue >= self.frame.size.height/2.0) {
            offset = -30;
        }else {
            offset = 30;
        }
        
        if (x <= 25) {
            [self.longPressView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.centerY.equalTo(self.hLongPressLineView).offset(offset);
                make.width.mas_greaterThanOrEqualTo(50);
            }];
        }else if (x >= self.bounds.size.width - 25) {
            [self.longPressView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self);
                make.centerY.equalTo(self.hLongPressLineView).offset(offset);
                make.width.mas_greaterThanOrEqualTo(50);
            }];
        }
        else {
           [self.longPressView mas_remakeConstraints:^(MASConstraintMaker *make) {
               make.centerX.equalTo(self.vLongPressLineView);
               make.centerY.equalTo(self.hLongPressLineView).offset(offset);
               make.width.mas_greaterThanOrEqualTo(50);
           }];
        }
        
    }else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self performSelector:@selector(hideLongPressView) withObject:nil afterDelay:2];
    }
}

- (void)hideLongPressView {
    self.vLongPressLineView.hidden = YES;
    self.hLongPressLineView.hidden = YES;
    self.longPressView.hidden = YES;
}

#pragma mark - lazy load
- (YXLayerGenerator *)generator {
    
    if (!_generator) {
        _generator = [[YXLayerGenerator alloc] init];
    }
    return _generator;
    
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
        _longPressGestureRecognizer.enabled = NO;
    }
    return _longPressGestureRecognizer;
}

- (UIView *)hLongPressLineView {
    if (!_hLongPressLineView) {
        _hLongPressLineView = [[UIView alloc] init];
        _hLongPressLineView.backgroundColor = [UIColor qmui_colorWithHexString:@"#000000"];
        _hLongPressLineView.hidden = YES;
    }
    return _hLongPressLineView;
}

- (UIView *)vLongPressLineView {
    if (!_vLongPressLineView) {
        _vLongPressLineView = [[UIView alloc] init];
        _vLongPressLineView.backgroundColor = [UIColor qmui_colorWithHexString:@"#000000"];
        _vLongPressLineView.hidden = YES;
    }
    return _vLongPressLineView;
}

- (NSMutableDictionary *)yValueDic {
    if (!_yValueDic) {
        _yValueDic = [NSMutableDictionary dictionary];
    }
    return _yValueDic;
}

- (UIView *)longPressView {
    if (!_longPressView) {
        _longPressView = [[UIView alloc] init];
        _longPressView.backgroundColor = QMUITheme.itemBorderColor;
        _longPressView.hidden = YES;
        _longPressView.layer.cornerRadius = 2;
        
        [_longPressView addSubview:self.valueLabel];
        
        UIView *view = [[UIView alloc] init];
        [view addSubview:self.timeLabel];
        [view addSubview:self.timeIconImageView];
        
        [_longPressView addSubview:view];
        
        [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_longPressView);
            make.top.equalTo(_longPressView).offset(2);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.timeIconImageView.mas_right).offset(2);
            make.centerY.equalTo(self.timeIconImageView);
            make.right.equalTo(view);
        }];
        
        [self.timeIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view);
            make.top.bottom.equalTo(view);
        }];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_longPressView);
            make.top.equalTo(self.valueLabel.mas_bottom).offset(1);
            make.bottom.equalTo(_longPressView).offset(-2);
        }];
    }
    
    return _longPressView;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.font = [UIFont systemFontOfSize:10];
        _valueLabel.textColor = [UIColor whiteColor];
    }
    return _valueLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.textColor = [UIColor whiteColor];
    }
    return _timeLabel;
}

- (UIImageView *)timeIconImageView {
    if (!_timeIconImageView) {
        _timeIconImageView = [[UIImageView alloc] init];
        _timeIconImageView.image = [UIImage imageNamed:@"little_clock"];
    }
    return _timeIconImageView;
}

- (void)refreshColor:(UIColor*) strokeColor {
    
    self.generator.timePriceLineLayer.strokeColor = strokeColor.CGColor;
    self.generator.yesterdayCloseLayer.strokeColor = strokeColor.CGColor;
    self.generator.gradientLayer.colors = @[(__bridge id)[strokeColor colorWithAlphaComponent:0.2].CGColor,
                              (__bridge id)[strokeColor colorWithAlphaComponent:0.0].CGColor];
    
}
@end
