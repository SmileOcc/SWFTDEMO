//
//  YXBTTimeLineView.m
//  uSmartOversea
//
//  Created by youxin on 2021/5/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXBTTimeLineView.h"
#import "YXKLineUtility.h"
#import "YXLayerGenerator.h"
#import <CoreText/CoreText.h>
#import <YYCategories/NSString+YYAdd.h>
#import "YXAccessoryTitleGenerator.h"
#import "MMKV.h"
#import "YXDateToolUtility.h"
#import "YXStockDetailUtility.h"
#import "YXStockLineMenuView.h"
#import "YXKlineSettingBtn.h"
#import "YXKLineSecondaryView.h"
#import "YXKLineOrderLayer.h"

#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "YXKLineConfigManager.h"
#import "UILabel+create.h"
#import "YYCategoriesMacro.h"

#define K_PonitDayNumber 1440
#define K_PonitFiveDayNumber 1440

@interface YXBTTimeLineView () <UIScrollViewDelegate>

//绘制k线图在scrollView上
@property (nonatomic, strong) UIScrollView *scrollView;
//layer生成器
@property (nonatomic, strong) YXLayerGenerator *generator;
//title生成器
@property (nonatomic, strong) YXAccessoryTitleGenerator *titleGenerator;

@property (nonatomic, assign) BOOL firstLoad;                               //是否第一次加载数据
@property (nonatomic, assign) CGRect candleRect;                            //整体蜡烛图显示区域 (width + height * 0.65)
@property (nonatomic, assign) CGRect volumeRect;                            //整体成交量显示区域 (width + HEIGHT - height * 0.65 - 20)
@property (nonatomic, assign) NSInteger location; //起点位置

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;  //长按手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer; //轻击手势
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer; //双击手势

@property (nonatomic, assign) double lastDrawRectY; //参数绘图区域

@property (nonatomic, assign) double priceBaseFullValue; //底除数

@property (nonatomic, assign) double maxHigh;
@property (nonatomic, assign) double minLow;

// 副指标的最大最小值
@property (nonatomic, assign) double subMaxHigh;
@property (nonatomic, assign) double subMinLow;

@property (nonatomic, assign) NSInteger longPressLocationIndex; //长按所在位置

@property (nonatomic, assign) BOOL isLandscape;

@property (nonatomic, strong) CALayer *mainLayer;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, assign) BOOL isLongPressLatest;

@property (nonatomic, strong) YXKLineSecondaryView *secondaryMAVOLView;

@property (nonatomic, strong) NSArray<YXKLineOrderLayer *> *orderLayerArray;


@property (nonatomic, assign) CGFloat topFixMargin;
@property (nonatomic, assign) CGFloat pointMargin;
@property (nonatomic, assign) double volumeWidth;


@end

@implementation YXBTTimeLineView

- (instancetype)initWithFrame:(CGRect)frame andIsLandscape:(BOOL)isLandscape {

    if (self = [super initWithFrame:frame]) {
        self.isLandscape = isLandscape;
        self.titleGenerator.isLandscape = isLandscape;
        [self initBaseView];
    }
    return self;
}


//初始化数据
- (void)initBaseView{

    //数据初始化

    self.topFixMargin = 0;
    //添加scrollView, 设置绘图区域 & 参数绘图区域
    [self addSubview:self.scrollView];
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.candleRect = CGRectMake(0, self.topFixMargin, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * 0.60);

    self.volumeRect = CGRectMake(0, CGRectGetMaxY(self.candleRect), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - (CGRectGetMaxY(self.candleRect)));

    //记录高度
    self.orderLayerArray = @[];

    //初次加载
    self.firstLoad = YES;

    self.mainLayer = [[CALayer alloc] init];
    self.mainLayer.frame = CGRectMake(0, self.topFixMargin, CGRectGetWidth(self.frame), CGRectGetHeight(self.candleRect));
    [self.scrollView.layer addSublayer:self.mainLayer];

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.candleRect))];
    self.maskLayer = [[CAShapeLayer alloc] init];
    self.maskLayer.frame =  CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.candleRect));
    self.maskLayer.path = maskPath.CGPath;
    self.mainLayer.mask = self.maskLayer;


    // 主指标
    //蜡烛图
    [self.mainLayer addSublayer:self.generator.timePriceLineLayer];
    self.generator.timePriceLineLayer.lineWidth = 0.5;
    [self.mainLayer addSublayer:self.generator.gradientLayer];

    // 现价线
    [self.layer addSublayer:self.generator.nowPrice_Layer];
    //持仓持本线
    [self.layer addSublayer:self.generator.holdPrice_Layer];

    [self.layer addSublayer:self.generator.crossLineLayer];
    self.generator.crossLineLayer.hidden = YES;

    //手势事件
    [self addGestureRecognizer:self.longPressGestureRecognizer];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    if (self.isLandscape) {
        [self addGestureRecognizer:self.doubleTapGestureRecognizer];
        [self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
    }

    //网格线
    [self.layer addSublayer:self.generator.horizonLayer];
    [self.layer addSublayer:self.generator.verticalLayer];

    // 副指标
    YXKLineSecondaryView *secondaryView = [[YXKLineSecondaryView alloc] initWithFrame:self.volumeRect subStatus:YXStockSubAccessoryStatus_MAVOL titleGenerator:self.titleGenerator layerGenerator:self.generator];
    [self addSubview:secondaryView];
    [secondaryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(self.volumeRect.size.height);
        make.top.equalTo(self).offset(self.volumeRect.origin.y);
    }];
    secondaryView.titleLabel.hidden = YES;
    self.secondaryMAVOLView = secondaryView;


    //最高/最低价格title
    [self addSubview:self.titleGenerator.kLineMaxPriceLabel];
    [self addSubview:self.titleGenerator.kLineMinPriceLabel];
    [self addSubview:self.titleGenerator.pclosePriceLabel];
    [self addSubview:self.titleGenerator.kLineSecondMaxPriceLabel];
    [self addSubview:self.titleGenerator.kLineSecondMinPriceLabel];

    [self adjustPirceLabelFrame];

    //起始和结束月份, 当前日期, 横线对应价格
    [self addSubview:self.titleGenerator.startDateLabel];
    [self addSubview:self.titleGenerator.endDateLabel];
    [self addSubview:self.titleGenerator.currentDateLabel];
    [self addSubview:self.titleGenerator.crossingLinePriceLabel];
    self.titleGenerator.currentDateLabel.hidden = YES;
    self.titleGenerator.crossingLinePriceLabel.hidden = YES;

    [self.titleGenerator.startDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(CGRectGetMaxY(self.candleRect) + 5);
    }];

    [self.titleGenerator.endDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right);
        make.top.mas_equalTo(self.titleGenerator.startDateLabel);
    }];

    [self.titleGenerator.crossingLinePriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(20);
    }];

    [self.layer qmui_sendSublayerToBack:self.generator.horizonLayer];
    [self.layer qmui_sendSublayerToBack:self.generator.verticalLayer];

    [self drawCrossingLayer];

}


- (void)drawCrossingLayer {

    // 主网格线(横5格竖4格)
    //    NSInteger hozizenCount = 5;
    //    NSInteger verticalCount = 4;
    UIBezierPath *horizenPath = [UIBezierPath bezierPath];
    //    UIBezierPath *verticalPath = [UIBezierPath bezierPath];
    //    for (int x = 0; x < hozizenCount; x ++) {
    //        UIBezierPath *path = [UIBezierPath bezierPath];
    //        [path moveToPoint:CGPointMake(self.candleRect.origin.x, self.candleRect.origin.y + CGRectGetHeight(self.candleRect) / (hozizenCount - 1) * x)];
    //        [path addLineToPoint:CGPointMake(self.candleRect.size.width, self.candleRect.origin.y + CGRectGetHeight(self.candleRect) / (hozizenCount - 1) * x)];
    //        [horizenPath appendPath:path];
    //    }
    //    for (int x = 0; x < verticalCount; x ++) {
    //        UIBezierPath *path = [UIBezierPath bezierPath];
    //        [path moveToPoint:CGPointMake(self.candleRect.origin.x + CGRectGetWidth(self.candleRect) / (verticalCount - 1) * x, self.candleRect.origin.y)];
    //        [path addLineToPoint:CGPointMake(self.candleRect.origin.x + CGRectGetWidth(self.candleRect) / (verticalCount - 1) * x, CGRectGetMaxY(self.candleRect))];
    //        [verticalPath appendPath:path];
    //    }
    //
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.candleRect.origin.x, self.candleRect.origin.y + CGRectGetHeight(self.candleRect))];
    [path addLineToPoint:CGPointMake(self.candleRect.size.width, self.candleRect.origin.y + CGRectGetHeight(self.candleRect))];
    [horizenPath appendPath:path];
    self.generator.horizonLayer.path = horizenPath.CGPath;
    //    self.generator.verticalLayer.path = verticalPath.CGPath;

    // 副网格线(横3格竖4格)
    //    NSInteger subHozizenCount = 3;
    //    NSInteger subVerticalCount = 4;
    //    UIBezierPath *subHorizenPath = [UIBezierPath bezierPath];
    //    UIBezierPath *subVerticalPath = [UIBezierPath bezierPath];
    //    for (int x = 0; x < subHozizenCount; x ++) {
    //        UIBezierPath *path = [UIBezierPath bezierPath];
    //        [path moveToPoint:CGPointMake(self.volumeRect.origin.x, self.volumeRect.origin.y + CGRectGetHeight(self.volumeRect) / (subHozizenCount - 1) * x)];
    //        [path addLineToPoint:CGPointMake(self.volumeRect.size.width, self.volumeRect.origin.y + CGRectGetHeight(self.volumeRect) / (subHozizenCount - 1) * x)];
    //        [subHorizenPath appendPath:path];
    //    }
    //    for (int x = 0; x < subVerticalCount; x ++) {
    //        UIBezierPath *path = [UIBezierPath bezierPath];
    //        [path moveToPoint:CGPointMake(self.volumeRect.origin.x + CGRectGetWidth(self.volumeRect) / (subVerticalCount - 1) * x, self.volumeRect.origin.y)];
    //        [path addLineToPoint:CGPointMake(self.volumeRect.origin.x + CGRectGetWidth(self.volumeRect) / (subVerticalCount - 1) * x, CGRectGetMaxY(self.volumeRect))];
    //        [subVerticalPath appendPath:path];
    //    }


    //    self.generator.subHorizonLayer.path = subHorizenPath.CGPath;
    //    self.generator.subVerticalLayer.path = subVerticalPath.CGPath;
}


//初始化基础数据
- (void)configureBaseDatas {

    double contentWidth = self.frame.size.width;
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.scrollView.frame.size.height);
    //月份
    NSArray *visibleArr = self.klineModel.list;
    if (visibleArr.count > 0) {
        YXKLine *startModel = visibleArr.firstObject;
        YXKLine *endModel = visibleArr.lastObject;

        self.titleGenerator.startDateLabel.text = [YXDateHelper commonDateStringWithNumber:startModel.latestTime.value format:YXCommonDateFormatDF_MDHM scaleType:YXCommonDateScaleTypeScale showWeek:NO];
        self.titleGenerator.endDateLabel.text = [YXDateHelper commonDateStringWithNumber:endModel.latestTime.value format:YXCommonDateFormatDF_MDHM scaleType:YXCommonDateScaleTypeScale showWeek:NO];

//        if (self.lineType == YXRtLineTypeDayTimeLine) {
//
//        } else {
//            self.titleGenerator.startDateLabel.text = [NSString stringWithFormat:@"%@-%@", startDateModel.month, startDateModel.day];
//            self.titleGenerator.endDateLabel.text = [NSString stringWithFormat:@"%@-%@", endDateModel.month, endDateModel.day];
//        }

    }
}

- (void)reload{

    //初始化参数
    [self configureBaseDatas];
    //画线
    [self drawAllLayers];

}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.candleRect = CGRectMake(0, self.topFixMargin, CGRectGetWidth(self.frame), self.frame.size.height * 0.60);
    self.volumeRect = CGRectMake(0, CGRectGetMaxY(self.candleRect), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - (CGRectGetMaxY(self.candleRect)));
    self.mainLayer.frame = CGRectMake(0, self.topFixMargin, CGRectGetWidth(self.frame), CGRectGetHeight(self.candleRect));
    self.maskLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.candleRect));

    [self adjustPirceLabelFrame];

    if (self.titleGenerator.startDateLabel.superview) {
        [self.titleGenerator.startDateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(CGRectGetMaxY(self.candleRect) + 5);
        }];

        [self.titleGenerator.endDateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleGenerator.startDateLabel);
        }];
    }

    [self drawCrossingLayer];
}

- (void)adjustPirceLabelFrame {
    self.titleGenerator.kLineMaxPriceLabel.frame = CGRectMake(0, self.candleRect.origin.y, 100, 15);
    self.titleGenerator.kLineSecondMaxPriceLabel.frame = CGRectMake(0, self.candleRect.origin.y + self.candleRect.size.height * 0.25 - 8, 100, 16);
    self.titleGenerator.pclosePriceLabel.frame = CGRectMake(0, self.candleRect.origin.y + self.candleRect.size.height * 0.5 - 8, 100, 16);
    self.titleGenerator.kLineSecondMinPriceLabel.frame = CGRectMake(0, self.candleRect.origin.y + self.candleRect.size.height * 0.75 - 8, 100, 16);
    self.titleGenerator.kLineMinPriceLabel.frame = CGRectMake(0, self.candleRect.origin.y + self.candleRect.size.height - 16, 100, 16);
}


- (void)setChange:(NSInteger)change {
    if (_change == change) {
        return ;
    }
    _change = change;
    
    if (change > 0) {
        self.generator.timePriceLineLayer.strokeColor = [QMUITheme stockRedColor].CGColor;
//        self.generator.timeLineDotLayer.strokeColor = [QMUITheme stockRedColor].CGColor;
        self.generator.gradientLayer.colors = @[(__bridge id)[[QMUITheme stockRedColor] colorWithAlphaComponent:0.2].CGColor,
                                                (__bridge id)[[QMUITheme stockRedColor] colorWithAlphaComponent:0.0].CGColor];
    } else if (change < 0) {
        self.generator.timePriceLineLayer.strokeColor = [QMUITheme stockGreenColor].CGColor;
//        self.generator.timeLineDotLayer.strokeColor = [QMUITheme stockGreenColor].CGColor;
        self.generator.gradientLayer.colors = @[(__bridge id)[[QMUITheme stockGreenColor] colorWithAlphaComponent:0.2].CGColor,
                                                (__bridge id)[[QMUITheme stockGreenColor] colorWithAlphaComponent:0.0].CGColor];
    } else {
        self.generator.timePriceLineLayer.strokeColor = [QMUITheme themeTextColor].CGColor;
//        self.generator.timeLineDotLayer.strokeColor = [QMUITheme themeTextColor].CGColor;
        self.generator.gradientLayer.colors = @[(__bridge id)[[QMUITheme themeTextColor] colorWithAlphaComponent:0.2].CGColor,
                                                (__bridge id)[[QMUITheme themeTextColor] colorWithAlphaComponent:0.0].CGColor];
    }
}

#pragma mark - 绘制图形
/**
 绘制所有layer
 */
- (void)drawAllLayers{

    //删除主指标参数
    [self cleanMainAcessoryLayer];

    //获取当前区域的最大最小值
    [self getMaxAndMinHigh];

    [self drawKLineLayer];

    //绘制副参数图
    [self drawAllSecondaryView];
}

/**
 绘制蜡烛图
 */
- (void)drawKLineLayer {

    NSArray<YXKLine *> *visibleArray = self.klineModel.list;
    if (visibleArray.count <= 0) {
        return;
    }
    //当前区域的最高值
    //最右边的那个点在区域内的时候, 算入最高/最低, 但是不算第0个; 不在的话, 不算入最右边的那个点, 但是算入第一个点....

//    double maxHigh = [[visibleArray valueForKeyPath:@"@max.high.doubleValue"] doubleValue] / self.priceBaseFullValue;
//    //当前区域的最低值
//    double minLow = [[visibleArray valueForKeyPath:@"@min.low.doubleValue"] doubleValue] / self.priceBaseFullValue;
    
    //价格的最大值
    double maxHigh = visibleArray.firstObject.high.stringValue.doubleValue;
    //价格的最低值
    double minLow = visibleArray.firstObject.low.stringValue.doubleValue;
    
    for (YXKLine *model in visibleArray) {
        if (maxHigh < model.high.stringValue.doubleValue) {
            maxHigh = model.high.stringValue.doubleValue;
        }
        
        if (minLow > model.low.stringValue.doubleValue) {
            minLow = model.low.stringValue.doubleValue;
        }
    }
    maxHigh = maxHigh / self.priceBaseFullValue;
    minLow = minLow / self.priceBaseFullValue;
    
    
    maxHigh = MAX(maxHigh, self.high);
    minLow = MIN(minLow, self.low);

    double candleDistance = CGRectGetHeight(self.candleRect) * 1;
    double zeroY = CGRectGetHeight(self.candleRect);
    UIBezierPath *closePath = [UIBezierPath bezierPath];
    UIBezierPath *fillPath = [UIBezierPath bezierPath];

    [fillPath moveToPoint:CGPointMake(0, CGRectGetMaxY(self.candleRect))];
    @weakify(self)
    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        double x = idx * self.pointMargin;

        double close = obj.close.stringValue.doubleValue / self.priceBaseFullValue;
        if (close > self.maxHigh) {
            close = self.maxHigh;
        } else if (close < self.minLow) {
            close = self.minLow;
        }

        double closeY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:close distance:candleDistance zeroY:zeroY];

        //存位置坐标
        obj.closePoint = [[NumberDouble alloc] init:x];

        if (idx == 0) {
            [closePath moveToPoint:CGPointMake(x, closeY)];
        } else {
            [closePath addLineToPoint:CGPointMake(x, closeY)];
        }

        [fillPath addLineToPoint:CGPointMake(x, closeY)];

        if (idx == visibleArray.count - 1) {
            [fillPath addLineToPoint:CGPointMake(x, CGRectGetMaxY(self.candleRect))];
        }

    }];

    [fillPath closePath];

    // 现价线
    YXKLine *model = self.klineModel.list.lastObject;
    double nowPrice = model.close.stringValue.doubleValue / self.priceBaseFullValue;
    if (nowPrice <= self.maxHigh && nowPrice >= self.minLow && [YXKLineConfigManager shareInstance].showNowPrice) {
        UIBezierPath *nowPath = [[UIBezierPath alloc] init];
        double nowY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:nowPrice distance:candleDistance zeroY:zeroY + self.topFixMargin];
        // 现价线
        NSInteger nowCount = YX_KLINE_NOWPRICE_COUNT * self.frame.size.width / 300;
        CGFloat padding = self.frame.size.width / nowCount * 0.4;
        CGFloat width = (self.frame.size.width - (padding * nowCount - 1)) / nowCount;
        for (int x = 0; x < nowCount; x++ ) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(x * (width + padding), nowY)];
            [path addLineToPoint:CGPointMake(x * (width + padding) + width, nowY)];
            [nowPath appendPath:path];
        }
        self.generator.nowPrice_Layer.path = nowPath.CGPath;
    } else {
        self.generator.nowPrice_Layer.path = nil;
    }

    //持仓成本线
    if ([YXKLineConfigManager shareInstance].showHoldPrice && self.holdPrice < self.maxHigh && self.holdPrice > self.minLow && self.holdPrice > 0) {
        UIBezierPath *holdPath = [UIBezierPath bezierPath];
        double y = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:self.holdPrice distance:candleDistance zeroY:zeroY + self.topFixMargin];

        NSInteger nowCount = YX_KLINE_NOWPRICE_COUNT * self.frame.size.width / 300;
        // 现价线
        CGFloat padding = self.frame.size.width / nowCount * 0.4;
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

    self.generator.timePriceLineLayer.hidden = NO;
    self.generator.timePriceLineLayer.path = closePath.CGPath;

    double pClose = (self.maxHigh + self.minLow) * 0.5;
    if (self.decimalCount == 0) {
        self.decimalCount = 2;
    }
    NSString *deciPointFormat = [NSString stringWithFormat:@"%%.%ldf", (long)self.decimalCount];
    self.titleGenerator.kLineMaxPriceLabel.text = [NSString stringWithFormat:deciPointFormat, self.maxHigh];
    self.titleGenerator.kLineMinPriceLabel.text = [NSString stringWithFormat:deciPointFormat, self.minLow];
    self.titleGenerator.pclosePriceLabel.text = [NSString stringWithFormat:deciPointFormat, pClose];
    self.titleGenerator.kLineSecondMaxPriceLabel.text = [NSString stringWithFormat:deciPointFormat, self.minLow + (self.maxHigh - self.minLow) * 0.75];
    self.titleGenerator.kLineSecondMinPriceLabel.text = [NSString stringWithFormat:deciPointFormat, self.minLow + (self.maxHigh - self.minLow) * 0.25];


    //填充色
    self.generator.gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.candleRect), CGRectGetHeight(self.candleRect));
    self.generator.gradientLayer.hidden = NO;
    CAShapeLayer *arc = [CAShapeLayer layer];
    arc.path = fillPath.CGPath;
    self.generator.gradientLayer.mask = arc;
}



// 获取蜡烛区域最大和最小值
- (void)getMaxAndMinHigh{

    //NSMutableArray *dataArr = [NSMutableArray array];

    NSArray<YXKLine *> *visibleArray = self.klineModel.list;
    
    //价格的最大值
    double maxHigh = visibleArray.firstObject.high.stringValue.doubleValue;
    //价格的最低值
    double minLow = visibleArray.firstObject.low.stringValue.doubleValue;
    
    for (YXKLine *model in visibleArray) {
        if (maxHigh < model.high.stringValue.doubleValue) {
            maxHigh = model.high.stringValue.doubleValue;
        }
        
        if (minLow > model.low.stringValue.doubleValue) {
            minLow = model.low.stringValue.doubleValue;
        }
    }
    maxHigh = maxHigh / self.priceBaseFullValue;
    minLow = minLow / self.priceBaseFullValue;
    
    
//    double maxHigh = [[visibleArray valueForKeyPath:@"@max.high.doubleValue"] doubleValue] / self.priceBaseFullValue;
//
//    double minLow = [[visibleArray valueForKeyPath:@"@min.low.doubleValue"] doubleValue] / self.priceBaseFullValue;

    //    [dataArr addObject:@(maxHigh)];
    //    [dataArr addObject:@(minLow)];

    self.maxHigh = maxHigh;
    self.minLow = minLow;  


    self.maxHigh = self.maxHigh + (self.maxHigh - self.minLow) * 0.1;
    self.minLow = self.minLow - (self.maxHigh - self.minLow) * 0.1;
}

/**
 删除主指标参数
 */
- (void)cleanMainAcessoryLayer{

    for (CALayer *layer in self.orderLayerArray) {
        [layer removeFromSuperlayer];
    }
    self.orderLayerArray = @[];

}

/**
 删除副指标参数layer
 */
- (void)cleanSubAccessoryLayer{

    //vol
    self.generator.redVolumeLayer.path = nil;
    self.generator.greenVolumeLayer.path = nil;
    self.generator.volumn5_Layer.path = nil;
    self.generator.volumn10_Layer.path = nil;
    self.generator.volumn20_Layer.path = nil;
}

- (YXKLineOrderLayer *)createOrderLayer {
    YXKLineOrderLayer *layer = [[YXKLineOrderLayer alloc] init];
    layer.bounds = CGRectMake(0, 0, 9, 9);
    layer.drawStyle = YXKLineOrderStyleArrow;
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.orderLayerArray];
    [array addObject:layer];
    self.orderLayerArray = array;
    return layer;
}

#pragma mark - 副指标
/**
 MAVOL
 */
- (void)drawMAVOLLayer{

    NSArray *visibleArray = self.klineModel.list;

    //当前区域的最大成交量/成交额
    double maxVolume = 0;

    maxVolume = [[visibleArray valueForKeyPath:@"@max.volume.doubleValue"] doubleValue];
//    double max5Volumn = 0;
//    double max10Volumn = 0;
//    double max20Volumn = 0;
//
//    if (![YXKLineConfigManager shareInstance].mavol.mavol_5_isHidden) {
//        max5Volumn = [[visibleArray valueForKeyPath:@"@max.MVOL5.value"] doubleValue];
//    }
//    if (![YXKLineConfigManager shareInstance].mavol.mavol_10_isHidden) {
//        max10Volumn = [[visibleArray valueForKeyPath:@"@max.MVOL10.value"] doubleValue];
//    }
//    if (![YXKLineConfigManager shareInstance].mavol.mavol_20_isHidden) {
//        max20Volumn = [[visibleArray valueForKeyPath:@"@max.MVOL20.value"] doubleValue];
//    }
//    maxVolume = MAX(MAX(MAX(maxVolume, max5Volumn), max10Volumn), max20Volumn);

    self.subMaxHigh = maxVolume;
    self.subMinLow = 0;

    //当前区域的最小成交量/成交额
    NSInteger minVolume = 0;
    UIBezierPath *greenVolumePath = [UIBezierPath bezierPath];
    UIBezierPath *redVolumePath = [UIBezierPath bezierPath];

    CGFloat distance = CGRectGetHeight(self.volumeRect) - kSecondaryTopFixMargin;

    @weakify(self)
    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        //计算蜡烛各个指标 的 x，y
        double x = idx * self.pointMargin;
        double volume = 0;
        volume = obj.volume.stringValue.doubleValue;
        double volumeY = [YXKLineUtility getYCoordinateWithMaxVolumn:maxVolume minVolumn:minVolume volume:volume distance:distance zeroY: distance];
//        if (CGRectGetMaxY(self.volumeRect) - volumeY <= 0.3) {
//            volumeY = CGRectGetMaxY(self.volumeRect) - 0.3;
//        }


        //交易量的path
        UIBezierPath *volumePath = [YXKLineUtility getVolumePathWithVoumeWidth:self.volumeWidth xCooordinate:x volumeY:volumeY zeroY:distance];
        if (obj.open.stringValue.doubleValue > obj.close.stringValue.doubleValue) { //阴线(开盘 > 收盘) -- 绿色
            [greenVolumePath appendPath:volumePath];

        } else if (obj.open.stringValue.doubleValue < obj.close.stringValue.doubleValue) { //阳线(开盘 < 收盘) - 阳线

            [redVolumePath appendPath:volumePath];
        } else {
            if (idx == 0) {
                [redVolumePath appendPath:volumePath];

            } else {

                YXKLine * preObj = visibleArray[idx - 1];
                if (obj.close.stringValue.doubleValue > preObj.close.stringValue.doubleValue) {
                    [redVolumePath appendPath:volumePath];
                } else if (obj.close.stringValue.doubleValue < preObj.close.stringValue.doubleValue) {
                    [greenVolumePath appendPath:volumePath];
                } else {
                    [redVolumePath appendPath:volumePath];
                }
            }

        }
    }];
    self.generator.redVolumeLayer.path = redVolumePath.CGPath;
    self.generator.greenVolumeLayer.path = greenVolumePath.CGPath;

    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}



- (void)drawAllSecondaryView {
    // 无数据返回
    if (self.klineModel.list.count == 0) {
        return;
    }

    [self cleanSubAccessoryLayer];

    [self drawMAVOLLayer];

    self.secondaryMAVOLView.scrollView.contentSize = CGSizeMake(self.volumeRect.size.width, self.volumeRect.size.height);
    self.secondaryMAVOLView.scrollView.contentOffset = CGPointMake(0, 0);

    [self setSubMaxAndMinPrice:self.secondaryMAVOLView.subStatus secondaryView:self.secondaryMAVOLView];


}

- (void)setSubMaxAndMinPrice:(YXStockSubAccessoryStatus)status secondaryView:(YXKLineSecondaryView *)secondaryView {

    if (status == YXStockSubAccessoryStatus_MAVOL) {

        secondaryView.subMinPriceLabel.hidden = YES;
        NSString *unitStr = [YXLanguageUtility kLangWithKey:@"stock_unit_en"];
        NSInteger pointCount = [YXToolUtility btDecimalPoint:@(self.subMaxHigh).stringValue];
    
        secondaryView.subMaxPriceLabel.text = [[YXToolUtility btNumberString:@(self.subMaxHigh).stringValue decimalPoint:pointCount isVol:YES showPlus:NO] stringByAppendingString:unitStr];
      
        secondaryView.subMidPriceLabel.text = [YXToolUtility btNumberString:@((self.subMaxHigh + self.subMinLow) * 0.5).stringValue decimalPoint:pointCount isVol:YES showPlus:NO];

        secondaryView.subMinPriceLabel.text = [YXToolUtility btNumberString:@(self.subMinLow).stringValue decimalPoint:pointCount isVol:YES showPlus:NO];

    } else {
        secondaryView.subMinPriceLabel.hidden = NO;
        secondaryView.subMaxPriceLabel.text = [NSString stringWithFormat:@"%.2f", self.subMaxHigh];
        secondaryView.subMidPriceLabel.text = [NSString stringWithFormat:@"%.2f", (self.subMaxHigh + self.subMinLow) * 0.5];
        secondaryView.subMinPriceLabel.text = [NSString stringWithFormat:@"%.2f", self.subMinLow];
    }
}


#pragma mark - lazy

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor]; _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
//        _scrollView.scrollEnabled = NO;
        _scrollView.userInteractionEnabled = NO;
    }
    return _scrollView;
}

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

#pragma mark - set


- (void)setKlineModel:(YXKLineData *)klineModel{

    // 无数据返回
    if (klineModel == nil || klineModel.list.count == 0) {
        return;
    }
    _klineModel = klineModel;

    //priceBase
//    NSInteger square = klineModel.priceBase.value > 0 ? klineModel.priceBase.value : 0;
//    double priceBasic = pow(10.0, square);
    self.priceBaseFullValue = 1;

    //左边为起点
    [self.scrollView setContentOffset:CGPointMake(0, 0)];

    if (self.lineType == YXRtLineTypeDayTimeLine) {
        _pointMargin = CGRectGetWidth(self.frame) / (K_PonitDayNumber);
    } else {
        _pointMargin = CGRectGetWidth(self.frame) / (K_PonitFiveDayNumber);
    }

    _volumeWidth = _pointMargin;

    //加载完数据, 非首次加载
    self.firstLoad = NO;

    if (self.isLongPressLatest) {
        YXKLine *model = _klineModel.list.lastObject;
        if (self.klineLongPressStartCallBack) {
            self.klineLongPressStartCallBack(model);
        }
    }

}


#pragma mark - lazy gestureRecognizer

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
        _longPressGestureRecognizer.minimumPressDuration = 0.25;
    }
    return _longPressGestureRecognizer;
}

- (UITapGestureRecognizer *)tapGestureRecognizer{

    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
    }
    return _tapGestureRecognizer;

}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer{

    if (!_doubleTapGestureRecognizer) {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizerAction:)];
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapGestureRecognizer;

}

#pragma mark - action
- (void)longPressGestureRecognizerAction:(UILongPressGestureRecognizer *)gesture {

    self.isLongPressLatest = NO;
    if (self.klineModel == nil || self.klineModel.list.count == 0) {
        return;
    }
    //长按中
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateBegan) {

        CGPoint point = [gesture locationInView:self.scrollView];
        if (point.x < 0) {
            point.x = 0;
        }
        [self handleLongPressActionWithPoint:point isScroll:NO];

    } else if (gesture.state == UIGestureRecognizerStateEnded) {

        [self performSelector:@selector(hideKlineLongPressView) withObject:nil afterDelay:3.0];
    }
}

- (void)handleLongPressActionWithPoint:(CGPoint)point isScroll:(BOOL)isScroll {

    NSInteger location = round(point.x / self.pointMargin);

    if (location >= self.klineModel.list.count) {
        location = self.klineModel.list.count - 1;
    }
    if (location < 0) {
        location = 0;
    }

    if (location == self.klineModel.list.count - 1) {
        self.isLongPressLatest = YES;
    }
    YXKLine *model = self.klineModel.list[location];
    self.longPressLocationIndex = location;

    self.generator.crossLineLayer.hidden = NO;
    self.titleGenerator.crossingLinePriceLabel.hidden = NO;

    UIBezierPath *path = [UIBezierPath bezierPath];
    double minX = CGRectGetMinX(self.candleRect);
    double maxX = CGRectGetMaxX(self.candleRect);
    double minY = 0;
    double crossingLabelY = point.y;

    double current_y = 0;
    if (point.y <= self.candleRect.origin.y) {
        current_y = self.candleRect.origin.y;
    } else if(point.y >= CGRectGetMaxY(self.candleRect)) {
        current_y = CGRectGetMaxY(self.candleRect);
    } else {
        current_y = point.y;
    }

    double current_x = point.x;
    if (point.x >= self.pointMargin * self.klineModel.list.count) { //最右边
        current_x = self.pointMargin * self.klineModel.list.count - self.pointMargin;
    }

    if (!isScroll) {
        //横线
        [path moveToPoint:CGPointMake(minX, current_y)];
        [path addLineToPoint:CGPointMake(maxX, current_y)];

        //纵线
        [path moveToPoint:CGPointMake(current_x, minY + self.candleRect.origin.y)];
        [path addLineToPoint:CGPointMake(current_x, self.frame.size.height)];
        [path closePath];
        self.generator.crossLineLayer.path = path.CGPath;

        //横线对应价格
        if (crossingLabelY <= self.candleRect.origin.y + self.titleGenerator.crossingLinePriceLabel.frame.size.height / 2.0) {
            crossingLabelY = self.candleRect.origin.y + self.titleGenerator.crossingLinePriceLabel.frame.size.height / 2.0;
        }
        if (crossingLabelY >= CGRectGetMaxY(self.candleRect) - self.titleGenerator.crossingLinePriceLabel.frame.size.height / 2.0) {
            crossingLabelY = CGRectGetMaxY(self.candleRect) - self.titleGenerator.crossingLinePriceLabel.frame.size.height / 2.0;
        }
        [self.titleGenerator.crossingLinePriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_top).offset(crossingLabelY);
        }];
    }


    if (self.maxHigh > 0) {
        NSString *deciPointFormat = [NSString stringWithFormat:@"%%.%ldf", (long)self.decimalCount];
        self.titleGenerator.crossingLinePriceLabel.text = [NSString stringWithFormat:deciPointFormat, [YXKLineUtility getPriceWithMaxPrice:self.maxHigh minPrice:self.minLow currentY:current_y distance:CGRectGetHeight(self.candleRect) * 1 zeroY:self.candleRect.origin.y + CGRectGetHeight(self.candleRect) * 0]];

    } else {
        self.titleGenerator.crossingLinePriceLabel.text = @"0.000";
    }

    //长按对应的日期
    self.titleGenerator.currentDateLabel.hidden = NO;
    self.titleGenerator.currentDateLabel.text = [YXDateHelper commonDateStringWithNumber:model.latestTime.value format:YXCommonDateFormatDF_MDYHM scaleType:YXCommonDateScaleTypeScale showWeek:NO];

    self.titleGenerator.currentDateLabel.frame = CGRectMake(model.closePoint.value - self.scrollView.contentOffset.x - 55, CGRectGetMaxY(self.candleRect), 110, 20);
    if (CGRectGetMaxX(self.titleGenerator.currentDateLabel.frame) >= self.frame.size.width) {
        self.titleGenerator.currentDateLabel.frame = CGRectMake(self.frame.size.width - 110, CGRectGetMaxY(self.candleRect), 110, 20);
    }
    if (self.titleGenerator.currentDateLabel.frame.origin.x <= self.frame.origin.x) {
        self.titleGenerator.currentDateLabel.frame = CGRectMake(0, CGRectGetMaxY(self.candleRect), 110, 20);
    }

    //动态改变参数数值
    [self dynamicChangeAccessoryLabelWithIndex:location];

    if (self.klineLongPressStartCallBack) {
        self.klineLongPressStartCallBack(model);
    }
}

//单击手势事件
- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)gesture{

    if (!self.generator.crossLineLayer.hidden) {
        [self hideKlineLongPressView];
    } else {
        // 点击主图还是副图
        if (self.canTapPush && self.pushToLandscapeRightCallBack) {
            self.pushToLandscapeRightCallBack();
        }
    }
}

//单击手势事件
- (void)doubleTapGestureRecognizerAction:(UITapGestureRecognizer *)gesture {

    if (self.doubleTapCallBack) {
        self.doubleTapCallBack();
    }
}



#pragma mark - other

//动态变更参数label
- (void)dynamicChangeAccessoryLabelWithIndex:(NSInteger)index{

//    self.titleGenerator.market = _klineModel.market;
//    self.titleGenerator.symbol = _klineModel.symbol;
//    if (self.generator.crossLineLayer.hidden) {
//        if (index < self.klineModel.list.count) {
//            self.titleGenerator.klineModel = self.klineModel.list[index];
//        }
//    } else {
//        if (self.longPressLocationIndex < self.klineModel.list.count) {
//            self.titleGenerator.klineModel = self.klineModel.list[self.longPressLocationIndex];
//        }
//    }
}

//隐藏长按线
- (void)hideKlineLongPressView {

    self.generator.crossLineLayer.hidden = YES;
    self.titleGenerator.crossingLinePriceLabel.hidden = YES;
    self.titleGenerator.currentDateLabel.hidden = YES;

    //动态改变参数数值
    self.titleGenerator.market = _klineModel.market;
    self.titleGenerator.symbol = _klineModel.symbol;
    self.titleGenerator.klineModel = self.klineModel.list.lastObject;
    self.isLongPressLatest = NO;
    //长按结束消失
    if (self.klineLongPressEndCallBack) {
        self.klineLongPressEndCallBack();
    }
}



@end

