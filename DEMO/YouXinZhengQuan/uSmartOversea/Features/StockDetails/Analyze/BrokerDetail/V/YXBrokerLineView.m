//
//  YXBrokerLineView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXBrokerLineView.h"
#import "YXAccessoryTitleGenerator.h"
#import "YXBrokerDetailLongPressView.h"
#import "UILabel+create.h"
#import "YXLayerGenerator.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import <YXKit/YXKit.h>
#import "uSmartOversea-Swift.h"

#define kBrokerChartFirstColor   [UIColor colorWithRGB:0x414FFF]
#define kBrokerChartSecondColor   [UIColor colorWithRGB:0x555665]
#define kBrokerChartThirdColor   [UIColor colorWithRGB:0x414FFF]

#define kCrossLineCount  7

@interface YXBrokerLineView ()<UIScrollViewDelegate>
//绘制k线图在scrollView上
@property (nonatomic, strong) UIScrollView *scrollView;
//蜡烛宽度 (单个蜡烛的宽度)
@property (nonatomic, assign) double candleWidth;
//整体蜡烛图显示区域 (width + height * 0.65)
@property (nonatomic, assign) CGRect candleRect;
@property (nonatomic, assign) CGRect volumeRect;

//layer生成器
@property (nonatomic, strong) YXLayerGenerator *generator;

@property (nonatomic, strong) YXAccessoryTitleGenerator *titleGenerator;

@property (nonatomic, strong) NSMutableArray *dateLabelArr; //日期数组

@property (nonatomic, strong) CALayer *mainLayer;

@property (nonatomic, assign) double priceBaseFullValue; //底除数

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic, strong) YXBrokerDetailLongPressView *pressView;

@property (nonatomic, assign) double maxRato;
@property (nonatomic, assign) double minRato;

@property (nonatomic, assign) double maxPrice;
@property (nonatomic, assign) double minPrice;


// 逆序后的数组
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, assign) NSInteger preListCount;

@property (nonatomic, assign) BOOL isSmall;

@property (nonatomic, strong) UILabel *holdUntiLabel;

@property (nonatomic, assign) CGFloat pressViewWidth;

@property (nonatomic, assign) YXBrokerLineType type;

@property (nonatomic, strong) NSArray *titleArr;

@property (nonatomic, strong) YXStockEmptyDataView *noDataView;

@property (nonatomic, strong) NSArray *ratoLabelArray;

@property (nonatomic, strong) NSArray *priceLabelArray;

@end

@implementation YXBrokerLineView

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (instancetype)initWithFrame:(CGRect)frame andType:(YXBrokerLineType)type {
    if (self = [super initWithFrame:frame]) {
        self.type = type;
        [self initUI];
    }

    return self;
}

- (void)initUI {

    if (self.type == YXBrokerLineTypeBroker) {
        self.titleArr = @[[YXLanguageUtility kLangWithKey:@"broker_percent"], [YXLanguageUtility kLangWithKey:@"economic_close"], [YXLanguageUtility kLangWithKey:@"economic_change_volume"]];
    } else if (self.type == YXBrokerLineTypeHkwolun) {
        self.titleArr = @[[YXLanguageUtility kLangWithKey:@"broker_percent"], [YXLanguageUtility kLangWithKey:@"economic_close"], [YXLanguageUtility kLangWithKey:@"economic_change_volume"]];
    } else {
        self.titleArr = @[[YXLanguageUtility kLangWithKey:@"sales_ratio"], [YXLanguageUtility kLangWithKey:@"economic_close"], [YXLanguageUtility kLangWithKey:@"sales_amount"]];
    }

    _pressViewWidth = 141;
    if ([YXUserManager isENMode]) {
        if (YXUserManager.curLanguage == YXLanguageTypeTH) {
            _pressViewWidth = 180;
        } else {            
            _pressViewWidth = 158;
        }
    }
    [self addSubview:self.scrollView];
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.candleRect = CGRectMake(0, 20, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * 0.52);
    self.volumeRect = CGRectMake(0, CGRectGetMaxY(self.candleRect) + 48, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * 0.16);
    //蜡烛宽度
    self.candleWidth = 6;
    self.space = 4.0;

    self.mainLayer = [[CALayer alloc] init];
    self.mainLayer.masksToBounds = true;
    self.mainLayer.frame = CGRectMake(0, self.candleRect.origin.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.candleRect));
    [self.scrollView.layer addSublayer:self.mainLayer];

    // 长按线
    [self.layer addSublayer:self.generator.crossLineLayer];
    self.generator.crossLineLayer.hidden = YES;

    //最高/最低比例
    [self addSubview:self.titleGenerator.kLineMaxRatoLabel];
    [self addSubview:self.titleGenerator.kLineSecondMaxRatoLabel];
    [self addSubview:self.titleGenerator.pcloseRatoLabel];
    [self addSubview:self.titleGenerator.kLineSecondMinRatoLabel];
    [self addSubview:self.titleGenerator.kLineMinRatoLabel];
    [self addSubview:self.titleGenerator.kLineThirdMaxRatoLabel];
    [self addSubview:self.titleGenerator.kLineThirdMinRatoLabel];

    //最高/最低价格title
    [self addSubview:self.titleGenerator.kLineMaxPriceLabel];
    [self addSubview:self.titleGenerator.kLineMinPriceLabel];
    [self addSubview:self.titleGenerator.pclosePriceLabel];
    [self addSubview:self.titleGenerator.kLineSecondMaxPriceLabel];
    [self addSubview:self.titleGenerator.kLineSecondMinPriceLabel];
    [self addSubview:self.titleGenerator.kLineThirdMaxPriceLabel];
    [self addSubview:self.titleGenerator.kLineThirdMinPriceLabel];

    // 顶部的单位
    UILabel *ratoUnti = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"economic_ratio_title"] textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:12]];
    ratoUnti.textAlignment = NSTextAlignmentLeft;
    UILabel *priceUnti = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"economic_price_title"] textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:12]];
    priceUnti.textAlignment = NSTextAlignmentRight;

    NSString *holdUntiLabelText = [NSString stringWithFormat:@"%@(%@)", [YXLanguageUtility kLangWithKey:@"economic_change_volume"], [YXLanguageUtility kLangWithKey:@"ten_thousand_shares"]];
    self.holdUntiLabel = [UILabel labelWithText:holdUntiLabelText textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:12]];
    self.holdUntiLabel.textAlignment = NSTextAlignmentLeft;

    [self addSubview:ratoUnti];
    [self addSubview:priceUnti];
    [self addSubview:self.holdUntiLabel];

    ratoUnti.frame = CGRectMake(0, 0, 130, 16);
    priceUnti.frame = CGRectMake(CGRectGetMaxX(self.candleRect) - 100, 0, 100, 16);
    self.holdUntiLabel.frame = CGRectMake(0, CGRectGetMaxY(self.candleRect) + 24, 150, 24);

    CGFloat ratioHeight = self.candleRect.size.height / (kCrossLineCount);
    NSArray *ratoLabelArray = @[self.titleGenerator.kLineMaxRatoLabel,
                                self.titleGenerator.kLineSecondMaxRatoLabel,
                                self.titleGenerator.kLineThirdMaxRatoLabel,
                                self.titleGenerator.pcloseRatoLabel,
                                self.titleGenerator.kLineThirdMinRatoLabel,
                                self.titleGenerator.kLineSecondMinRatoLabel,
                                self.titleGenerator.kLineMinRatoLabel];
    self.ratoLabelArray = ratoLabelArray;
    @weakify(self)
    [ratoLabelArray enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)

        label.frame = CGRectMake(0, self.candleRect.origin.y +  ratioHeight * (idx + 1) - 17, 100, 15);
    }];

    NSArray *priceLabelArray = @[self.titleGenerator.kLineMaxPriceLabel,
                                 self.titleGenerator.kLineSecondMaxPriceLabel,
                                 self.titleGenerator.kLineThirdMaxPriceLabel,
                                 self.titleGenerator.pclosePriceLabel,
                                 self.titleGenerator.kLineThirdMinPriceLabel,
                                 self.titleGenerator.kLineSecondMinPriceLabel,
                                 self.titleGenerator.kLineMinPriceLabel];
    self.priceLabelArray = priceLabelArray;

    [priceLabelArray enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)

        label.frame = CGRectMake(CGRectGetMaxX(self.candleRect) - 101, self.candleRect.origin.y +  ratioHeight * (idx + 1) - 17, 100, 15);
    }];

    self.titleGenerator.kLineMaxPriceLabel.textAlignment = NSTextAlignmentRight;
    self.titleGenerator.kLineMinPriceLabel.textAlignment = NSTextAlignmentRight;
    self.titleGenerator.pclosePriceLabel.textAlignment = NSTextAlignmentRight;
    self.titleGenerator.kLineSecondMaxPriceLabel.textAlignment = NSTextAlignmentRight;
    self.titleGenerator.kLineSecondMinPriceLabel.textAlignment = NSTextAlignmentRight;
    self.titleGenerator.kLineThirdMaxPriceLabel.textAlignment = NSTextAlignmentRight;
    self.titleGenerator.kLineThirdMinPriceLabel.textAlignment = NSTextAlignmentRight;

    //起始和结束月份, 当前日期, 横线对应价格
    [self addSubview:self.titleGenerator.startDateLabel];
    [self addSubview:self.titleGenerator.endDateLabel];
    [self addSubview:self.titleGenerator.currentDateLabel];
    [self addSubview:self.titleGenerator.crossingLinePriceLabel];
    self.titleGenerator.currentDateLabel.hidden = YES;
    self.titleGenerator.crossingLinePriceLabel.hidden = YES;
    self.titleGenerator.currentDateLabel.adjustsFontSizeToFitWidth = YES;
    self.titleGenerator.currentDateLabel.minimumScaleFactor = 0.3;

    [self.titleGenerator.startDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(CGRectGetMaxY(self.candleRect));
        make.height.mas_equalTo(22);
    }];

    [self.titleGenerator.endDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right);
        make.top.equalTo(self.titleGenerator.startDateLabel);
        make.height.mas_equalTo(22);
    }];

    [self.titleGenerator.crossingLinePriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(20);
    }];

    // 副指标最高最低
    [self addSubview:self.titleGenerator.subMaxPriceLabel];
    [self addSubview:self.titleGenerator.subMinPriceLabel];

    self.titleGenerator.subMaxPriceLabel.frame = CGRectMake(0, CGRectGetMinY(self.volumeRect) + 1, 100, 15);
    self.titleGenerator.subMinPriceLabel.frame = CGRectMake(0, CGRectGetMinY(self.volumeRect) + self.volumeRect.size.height - 16, 100, 16);

    [self drawCrossLayer];

    // 增加画线
    [self.mainLayer addSublayer:self.generator.ma5Layer];
    [self.mainLayer addSublayer:self.generator.ma20Layer];
    [self.scrollView.layer addSublayer:self.generator.greenVolumeLayer];

    self.generator.ma5Layer.strokeColor = kBrokerChartFirstColor.CGColor;
    self.generator.ma20Layer.strokeColor = kBrokerChartSecondColor.CGColor;
    self.generator.greenVolumeLayer.fillColor = kBrokerChartThirdColor.CGColor;
    self.generator.greenVolumeLayer.strokeColor = kBrokerChartThirdColor.CGColor;

    [self addGestureRecognizer:self.longPressGestureRecognizer];

    [self addSubview:self.pressView];

    UIView *sq1 = [self creatTypeViewWithTitle:self.titleArr[0] andColor:kBrokerChartFirstColor andIsSquare:NO];
    UIView *sq2 = [self creatTypeViewWithTitle:self.titleArr[1] andColor:kBrokerChartSecondColor andIsSquare:NO];
    UIView *sq3 = [self creatTypeViewWithTitle:self.titleArr[2] andColor:kBrokerChartThirdColor andIsSquare:YES];

    [self addSubview:sq1];
    [self addSubview:sq2];
    [self addSubview:sq3];

    float scale = YXConstant.screenWidth / 375;

    [sq1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.leading.equalTo(self).offset(37 *scale);
    }];

    [sq2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.leading.equalTo(self).offset(138 *scale);
    }];

    [sq3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        if ([YXUserManager isENMode]) {
            make.trailing.equalTo(self).offset(-34 * scale);
        } else {
            make.trailing.equalTo(self).offset(-54 * scale);
        }
    }];

    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];

    // 第一根
    [self.layer addSublayer: self.generator.longPressCirclePriceLayer];
    // 第二根
    [self.layer addSublayer: self.generator.longPressCircleAveragePriceLayer];
    self.generator.longPressCirclePriceLayer.strokeColor = kBrokerChartFirstColor.CGColor;
    self.generator.longPressCircleAveragePriceLayer.strokeColor = kBrokerChartSecondColor.CGColor;

    [self addSubview:self.noDataView];
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.noDataView.hidden = YES;
}


- (void)drawCrossLayer {

    //网格线
    [self.layer addSublayer:self.generator.horizonLayer];
    [self.layer addSublayer:self.generator.verticalLayer];
    [self.layer addSublayer:self.generator.subHorizonLayer];
    [self.layer addSublayer:self.generator.subVerticalLayer];
    [self.layer addSublayer:self.generator.subMidHorizonLayer];

    self.generator.horizonLayer.lineWidth = 0.5;
    self.generator.verticalLayer.lineWidth = 0.5;
    self.generator.subHorizonLayer.lineWidth = 0.5;
    self.generator.subVerticalLayer.lineWidth = 0.5;

    self.generator.horizonLayer.strokeColor = QMUITheme.pointColor.CGColor;
    self.generator.verticalLayer.strokeColor = QMUITheme.pointColor.CGColor;
    self.generator.subHorizonLayer.strokeColor = QMUITheme.pointColor.CGColor;
    self.generator.subVerticalLayer.strokeColor = QMUITheme.pointColor.CGColor;

    // 主网格线
    UIBezierPath *horizenPath = [UIBezierPath bezierPath];
//    UIBezierPath *verticalPath = [UIBezierPath bezierPath];
    for (int x = 0; x < kCrossLineCount ; x ++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(self.candleRect.origin.x, self.candleRect.origin.y + CGRectGetHeight(self.candleRect) / (kCrossLineCount) * (x + 1))];
        [path addLineToPoint:CGPointMake(self.candleRect.size.width, self.candleRect.origin.y + CGRectGetHeight(self.candleRect) / (kCrossLineCount) * (x + 1))];
        [horizenPath appendPath:path];
    }
//    for (int x = 0; x < 2; x ++) {
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        [path moveToPoint:CGPointMake(self.candleRect.origin.x + CGRectGetWidth(self.candleRect) * x, self.candleRect.origin.y)];
//        [path addLineToPoint:CGPointMake(self.candleRect.origin.x + CGRectGetWidth(self.candleRect) * x, CGRectGetMaxY(self.candleRect))];
//        [verticalPath appendPath:path];
//    }

    // 副网格线(横3格竖2格)
//    UIBezierPath *subHorizenPath = [UIBezierPath bezierPath];
//    UIBezierPath *subVerticalPath = [UIBezierPath bezierPath];
//    for (int x = 0; x < 2; x ++) {
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        [path moveToPoint:CGPointMake(self.volumeRect.origin.x, self.volumeRect.origin.y + CGRectGetHeight(self.volumeRect) * x)];
//        [path addLineToPoint:CGPointMake(self.volumeRect.size.width, self.volumeRect.origin.y + CGRectGetHeight(self.volumeRect) * x)];
//        [subHorizenPath appendPath:path];
//    }
//    for (int x = 0; x < 2; x ++) {
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        [path moveToPoint:CGPointMake(self.volumeRect.origin.x + CGRectGetWidth(self.volumeRect) * x, self.volumeRect.origin.y)];
//        [path addLineToPoint:CGPointMake(self.volumeRect.origin.x + CGRectGetWidth(self.volumeRect) * x, CGRectGetMaxY(self.volumeRect))];
//        [subVerticalPath appendPath:path];
//    }

    self.generator.horizonLayer.path = horizenPath.CGPath;
    //self.generator.verticalLayer.path = verticalPath.CGPath;
    //self.generator.subHorizonLayer.path = subHorizenPath.CGPath;
    //self.generator.subVerticalLayer.path = subVerticalPath.CGPath;

    self.generator.subMidHorizonLayer.frame = CGRectMake(0, self.volumeRect.origin.y - 24, self.volumeRect.size.width, 0.5);
    [self.layer qmui_sendSublayerToBack:self.generator.horizonLayer];
    //[self.layer qmui_sendSublayerToBack:self.generator.verticalLayer];
    //[self.layer qmui_sendSublayerToBack:self.generator.subHorizonLayer];
    //[self.layer qmui_sendSublayerToBack:self.generator.subVerticalLayer];
    [self.layer qmui_sendSublayerToBack:self.generator.subMidHorizonLayer];


}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if (object == self.scrollView) {
        if (self.scrollView.contentSize.width < self.frame.size.width) {
            self.mainLayer.frame = CGRectMake(0, self.candleRect.origin.y, self.frame.size.width, CGRectGetHeight(self.candleRect));
        } else {
            self.mainLayer.frame = CGRectMake(0, self.candleRect.origin.y, self.scrollView.contentSize.width, CGRectGetHeight(self.candleRect));
        }
    }
}

- (void)drawMainLayer {

    NSArray *visibleArray = [self getVisibleArr];
    if (visibleArray.count <= 0) {
        return;
    }

    double maxRatoHigh = [[visibleArray valueForKeyPath:@"@max.holdRatio"] intValue] * 1.05;
    //当前区域的最低值
    double minRatoLow = [[visibleArray valueForKeyPath:@"@min.holdRatio"] intValue] * 0.95;


    if (maxRatoHigh - minRatoLow < 4) {
        maxRatoHigh = minRatoLow + 4;
    }

    self.maxRato = maxRatoHigh;
    self.minRato = minRatoLow;
    if (maxRatoHigh < 100) {
        self.isSmall = YES;
    } else {
        self.isSmall = NO;
    }

    double maxPriceHigh = [[visibleArray valueForKeyPath:@"@max.close"] intValue] * 1.05;
    double minPriceLow = [[visibleArray valueForKeyPath:@"@min.close"] intValue] * 0.95;

    self.maxPrice = maxPriceHigh;
    self.minPrice = minPriceLow;

    int64_t maxVolume = [[visibleArray valueForKeyPath:@"@max.changeVolume"] longLongValue];
    int64_t minVolume = [[visibleArray valueForKeyPath:@"@min.changeVolume"] longLongValue];
    maxVolume = llabs(maxVolume);
    minVolume = llabs(minVolume);

    int64_t max = MAX(maxVolume, minVolume);
    maxVolume = max;
    minVolume = -max;

    CGFloat candleDistance = CGRectGetHeight(self.candleRect) * 1;
    CGFloat volumnDistance = CGRectGetHeight(self.volumeRect) * 1;

    if (self.type == YXBrokerLineTypeSell) {
        minVolume = 0;
    } else {
        volumnDistance = volumnDistance * 0.5;
    }

    CGFloat zeroVolumeY = CGRectGetMinY(self.volumeRect) + volumnDistance;

    UIBezierPath *firstPath = [UIBezierPath bezierPath];
    UIBezierPath *secondPath = [UIBezierPath bezierPath];
    UIBezierPath *volumePath = [UIBezierPath bezierPath];


    [visibleArray enumerateObjectsUsingBlock:^(YXBrokerDetailSubModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        CGFloat x = (self.candleWidth + self.space) * obj.index.integerValue + self.candleWidth * 0.5;

        int64_t volume = obj.changeVolume;

        CGFloat firstY = [YXKLineUtility getYCoordinateWithMaxPrice:maxRatoHigh minPrice:minRatoLow price:obj.holdRatio distance:candleDistance zeroY:candleDistance];
        CGFloat secondY = [YXKLineUtility getYCoordinateWithMaxPrice:maxPriceHigh minPrice:minPriceLow price:obj.close distance:candleDistance zeroY:candleDistance];
        CGFloat volumeY = 0;
        //存位置坐标
        //        obj.closePoint = [[NumberDouble alloc] init:x];

        if (idx == 0) {
            [firstPath moveToPoint:CGPointMake(x, firstY)];
            [secondPath moveToPoint:CGPointMake(x, secondY)];
        } else {
            [firstPath addLineToPoint:CGPointMake(x, firstY)];
            [secondPath addLineToPoint:CGPointMake(x, secondY)];
        }

        if (volume >= 0) {
            volumeY = [YXKLineUtility getYCoordinateWithMaxVolumn:maxVolume minVolumn:0 volume:volume distance:volumnDistance zeroY: zeroVolumeY];
            if ((zeroVolumeY - volumeY) < 0.5) {
                volumeY = zeroVolumeY - 0.5;
            }

            UIBezierPath *temp = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x - self.candleWidth * 0.5, volumeY, self.candleWidth, zeroVolumeY - volumeY) cornerRadius:1];

            [volumePath appendPath:temp];
        } else if (volume < 0) {
            volumeY = [YXKLineUtility getYCoordinateWithMaxVolumn:0 minVolumn:minVolume volume:volume distance:volumnDistance zeroY: volumnDistance];
            if (volumeY < 0.5) {
                volumeY = 0.5;
            }
            UIBezierPath *temp = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x - self.candleWidth * 0.5, zeroVolumeY, self.candleWidth, volumeY) cornerRadius:1];
            [volumePath appendPath:temp];
        }

    }];


    @weakify(self)
    [self.priceLabelArray enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {

        CGFloat ratio = idx * 1.0 / (kCrossLineCount - 1);
        @strongify(self)
        if (self.klineModel.priceBase == 3) {

            label.text = [NSString stringWithFormat:@"%.3f", (maxPriceHigh - (maxPriceHigh - minPriceLow) * ratio) / (self.priceBaseFullValue)];
        } else {

            label.text = [NSString stringWithFormat:@"%.2f", (maxPriceHigh - (maxPriceHigh - minPriceLow) * ratio) / (self.priceBaseFullValue)];
        }
    }];


    [self.ratoLabelArray enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {

        CGFloat ratio = idx * 1.0 / (kCrossLineCount - 1);
        @strongify(self)
        if (self.isSmall) {

            label.text = [NSString stringWithFormat:@"%.3f", (maxRatoHigh - (maxRatoHigh - minRatoLow) * ratio) / 100];
        } else {

            label.text = [NSString stringWithFormat:@"%.2f", (maxRatoHigh - (maxRatoHigh - minRatoLow) * ratio) / 100];
        }
    }];


    //日期
    YXBrokerDetailSubModel *startModel = visibleArray.firstObject;
    YXBrokerDetailSubModel *endModel = visibleArray.lastObject;
    self.titleGenerator.startDateLabel.text = [YXDateHelper commonDateString:startModel.date format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:NO];
    self.titleGenerator.endDateLabel.text = [YXDateHelper commonDateString:endModel.date format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:NO];

    self.generator.ma5Layer.path = firstPath.CGPath;
    self.generator.ma20Layer.path = secondPath.CGPath;
    self.generator.greenVolumeLayer.path = volumePath.CGPath;

    int64_t value = [self getUnitValue:maxVolume];
    //
    NSString *untiStr = self.titleArr[2];
    if ([YXUserManager isENMode]) {
        if (value == 1E9) {
            untiStr = [NSString stringWithFormat:@"%@(B %@)", untiStr,[YXLanguageUtility kLangWithKey:@"stock_unit"]];
        } else if (value == 1E6) {
            untiStr = [NSString stringWithFormat:@"%@(M %@)", untiStr,[YXLanguageUtility kLangWithKey:@"stock_unit"]];
        } else if (value == 1000) {
            untiStr = [NSString stringWithFormat:@"%@(K %@)", untiStr,[YXLanguageUtility kLangWithKey:@"stock_unit"]];
        } else {
            untiStr = [NSString stringWithFormat:@"%@(%@)", untiStr,[YXLanguageUtility kLangWithKey:@"stock_unit"]];
        }
    } else {
        if (value == 1E12) {
            untiStr = [NSString stringWithFormat:@"%@(%@)", untiStr,[YXLanguageUtility kLangWithKey:@"thousand_billion_shares"]];
        } else if (value == 1E8) {
            untiStr = [NSString stringWithFormat:@"%@(%@)", untiStr,[YXLanguageUtility kLangWithKey:@"hundred_million_shares"]];
        } else if (value == 10000) {
            untiStr = [NSString stringWithFormat:@"%@(%@)", untiStr,[YXLanguageUtility kLangWithKey:@"ten_thousand_shares"]];
        } else {
            untiStr = [NSString stringWithFormat:@"%@(%@)", untiStr,[YXLanguageUtility kLangWithKey:@"stock_unit"]];
        }
    }

    self.holdUntiLabel.text = untiStr;

    self.titleGenerator.subMaxPriceLabel.text = [NSString stringWithFormat:@"%.2f", maxVolume * 1.0 / value];
    self.titleGenerator.subMinPriceLabel.text = [NSString stringWithFormat:@"%.2f", minVolume * 1.0 / value];
}

/**
 获取当前可视图部分数据数组
 */
- (NSArray *)getVisibleArr{

    //算出取数组的位置(location这里已经进行了取整)
    NSMutableArray<YXBrokerDetailSubModel *> *visibleArray = [NSMutableArray<YXBrokerDetailSubModel *> array];
    for (int x = 0; x < self.dataSource.count; x ++) {
        if (x * (self.candleWidth + self.space) + self.candleWidth * 0.5 >= self.scrollView.contentOffset.x && x * (self.candleWidth + self.space) + self.candleWidth * 0.5 <= (self.scrollView.contentOffset.x + self.candleRect.size.width)) {
            YXBrokerDetailSubModel *kLineSingleModel = self.dataSource[x];
            kLineSingleModel.index = [[NSNumber alloc] initWithInt:x];

            [visibleArray addObject:kLineSingleModel];
        }
    }
    return visibleArray;
}

- (int64_t)getUnitValue: (int64_t)value {
    if ([YXUserManager isENMode]) {
        if (value >= 1E9) {
            return 1E9;
        } else if (value >= 1E6) {
            return 1E6;
        } else if (value >= 1000) {
            return 1000;
        } else {
            return 1;
        }
    } else {
        if (value >= 1E12) {
            return 1E12;
        } else if (value >= 1E8) {
            return 1E8;
        } else if (value >= 10000) {
            return 10000;
        } else {
            return 1;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView.contentOffset.x <= 0.0 && self.klineModel.hasMore) {  //加载更多(分页)
        if (self.loadMoreCallBack) {
            self.loadMoreCallBack();
        }
    } else {
        //重新绘制
        [self drawMainLayer];
    }
    //滑动时隐藏长按view
    [self hideKlineLongPressView];

}

#pragma mark - action
- (void)longPressGestureRecognizerAction:(UILongPressGestureRecognizer *)gesture {

    if (self.klineModel == nil || self.dataSource.count == 0) {
        return;
    }
    //长按中
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //
    if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateBegan) {

        CGPoint point = [gesture locationInView:self.scrollView];

        // 超出边界处理
        CGPoint pointInView = [gesture locationInView:self];
        if (pointInView.x < (self.candleWidth * 0.5) || pointInView.x > (CGRectGetWidth(self.candleRect) - self.candleWidth * 0.5)) {
            self.scrollView.scrollEnabled = YES;
            [self performSelector:@selector(hideKlineLongPressView) withObject:nil afterDelay:3.0];
            return;
        }

        NSInteger location = round(point.x / (self.candleWidth + self.space));

        if (location >= self.dataSource.count) {
            location = self.dataSource.count - 1;
        }
        if (location < 0) {
            location = 0;
        }
        YXBrokerDetailSubModel *model = self.dataSource[location];

        self.pressView.hidden = NO;
        self.pressView.subModel = model;

        self.scrollView.scrollEnabled = NO;
        self.generator.crossLineLayer.hidden = NO;
        self.titleGenerator.crossingLinePriceLabel.hidden = NO;

        UIBezierPath *path = [UIBezierPath bezierPath];
        double minX = CGRectGetMinX(self.candleRect);
        double maxX = CGRectGetMaxX(self.candleRect);
        double minY = 0;
        double crossingLabelY = point.y;

        double current_y = 0;
        if (point.y <= self.candleRect.origin.y + CGRectGetHeight(self.candleRect) * 0) {
            current_y = self.candleRect.origin.y + CGRectGetHeight(self.candleRect) * 0;
        } else if(point.y >= CGRectGetMaxY(self.candleRect) - CGRectGetHeight(self.candleRect) * 0) {
            current_y = CGRectGetMaxY(self.candleRect) - CGRectGetHeight(self.candleRect) * 0;
        } else {
            current_y = point.y;
        }

        double current_x = location * (self.candleWidth + self.space) +  self.candleWidth * 0.5 - self.scrollView.contentOffset.x;

        //横线
        [path moveToPoint:CGPointMake(minX, current_y)];
        [path addLineToPoint:CGPointMake(maxX, current_y)];

        //纵线
        [path moveToPoint:CGPointMake(current_x, minY + self.candleRect.origin.y)];
        [path addLineToPoint:CGPointMake(current_x, CGRectGetMaxY(self.volumeRect))];
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

        if (self.maxRato > 0) {
            if (self.isSmall) {
                self.titleGenerator.crossingLinePriceLabel.text = [NSString stringWithFormat:@"%.3f", [YXKLineUtility getPriceWithMaxPrice:self.maxRato minPrice:self.minRato currentY:current_y distance:CGRectGetHeight(self.candleRect) * 1 zeroY:self.candleRect.origin.y + CGRectGetHeight(self.candleRect) * 0] / 100.0];
            } else {
                self.titleGenerator.crossingLinePriceLabel.text = [NSString stringWithFormat:@"%.2f", [YXKLineUtility getPriceWithMaxPrice:self.maxRato minPrice:self.minRato currentY:current_y distance:CGRectGetHeight(self.candleRect) * 1 zeroY:self.candleRect.origin.y + CGRectGetHeight(self.candleRect) * 0] / 100.0];
            }

        } else {
            self.titleGenerator.crossingLinePriceLabel.text = @"0.00";
        }

        // 圈圈
        CGPoint circlePoint = CGPointMake(current_x, [YXKLineUtility getYCoordinateWithMaxPrice:self.maxRato minPrice:self.minRato price:model.holdRatio distance:CGRectGetHeight(self.candleRect) zeroY:CGRectGetMaxY(self.candleRect)]);
        UIBezierPath *pricecirclePath = [UIBezierPath bezierPathWithArcCenter:circlePoint radius:3 startAngle:0 endAngle:360 clockwise:YES];
        self.generator.longPressCirclePriceLayer.path = pricecirclePath.CGPath;

        CGPoint averagePonit = CGPointMake(current_x, [YXKLineUtility getYCoordinateWithMaxPrice:self.maxPrice minPrice:self.minPrice price:model.close distance:CGRectGetHeight(self.candleRect) zeroY:CGRectGetMaxY(self.candleRect)]);
        UIBezierPath *averagePath = [UIBezierPath bezierPathWithArcCenter:averagePonit radius:3 startAngle:0 endAngle:360 clockwise:YES];
        self.generator.longPressCircleAveragePriceLayer.path = averagePath.CGPath;


        //长按对应的日期
        self.titleGenerator.currentDateLabel.hidden = NO;
    
        if (current_x < CGRectGetWidth(self.candleRect) * 0.5) {
            self.pressView.mj_x = CGRectGetWidth(self.frame) - _pressViewWidth;
        } else {
            self.pressView.mj_x = 1;
        }
        CGFloat dateWidth = 90;
        if ([YXUserManager isENMode]) {
            dateWidth = 110;
        }
        self.titleGenerator.currentDateLabel.text = [YXDateHelper commonDateString:model.date format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:YES];
        self.titleGenerator.currentDateLabel.frame = CGRectMake(current_x - dateWidth / 2.0, CGRectGetMaxY(self.candleRect), dateWidth, 15);
        if (CGRectGetMaxX(self.titleGenerator.currentDateLabel.frame) >= self.frame.size.width) {
            self.titleGenerator.currentDateLabel.frame = CGRectMake(self.frame.size.width - dateWidth, CGRectGetMaxY(self.candleRect), dateWidth, 15);
        }
        if (self.titleGenerator.currentDateLabel.frame.origin.x <= self.frame.origin.x) {
            self.titleGenerator.currentDateLabel.frame = CGRectMake(0, CGRectGetMaxY(self.candleRect), dateWidth, 15);
        }

    } else if (gesture.state == UIGestureRecognizerStateEnded) {

        self.scrollView.scrollEnabled = YES;
        [self performSelector:@selector(hideKlineLongPressView) withObject:nil afterDelay:3.0];

    }
}

- (void)setKlineModel:(YXBrokerDetailModel *)klineModel {
    _klineModel = klineModel;
    // 无数据返回
    if (klineModel == nil || klineModel.list.count == 0) {
        if (self.type == YXBrokerLineTypeSell || self.type == YXBrokerLineTypeHkwolun) {
            self.noDataView.hidden = NO;
        } else {
            self.noDataView.hidden = YES;
        }
        return;
    }
    NSArray *list = [[self.klineModel.list reverseObjectEnumerator] allObjects];
    self.dataSource = list;
    //priceBase
    NSInteger square = klineModel.priceBase;
    double priceBasic = pow(10.0, square);
    self.priceBaseFullValue = priceBasic;

    self.pressView.priceBase = square;

    [self configureBaseDatas];


    NSInteger offset = klineModel.list.count - self.preListCount;
    if (self.preListCount == klineModel.list.count && self.preListCount > 0) {
        // 最后一次刷新到数据
    } else if (offset != 0 && self.preListCount != 0) {
        // 加载更多的时候
        self.scrollView.contentOffset = CGPointMake((self.klineModel.list.count - self.preListCount) * (self.candleWidth + self.space), 0);
    } else {
        // 第一次加载数据
        if (self.dataSource.count * (self.candleWidth + self.space) > CGRectGetWidth(self.candleRect)) {
            //右边为起点
            [self.scrollView setContentOffset:CGPointMake((self.dataSource.count * (self.candleWidth + self.space) - CGRectGetWidth(self.candleRect)), 0)];
        } else {
            //左边为起点
            [self.scrollView setContentOffset:CGPointMake(0, 0)];
        }
    }
    // 更新数量
    self.preListCount = self.dataSource.count;

    [self clear];
    [self drawMainLayer];
}

- (void)resetData {
    [self clear];
    self.preListCount = 0;
}

- (void)clear {
    self.generator.ma5Layer.path = nil;
    self.generator.ma20Layer.path = nil;
    self.generator.greenVolumeLayer.path = nil;

    self.titleGenerator.startDateLabel.text = @"";
    self.titleGenerator.endDateLabel.text = @"";
}

//初始化基础数据
- (void)configureBaseDatas {

    double contentWidth = self.dataSource.count >= 1 ?  (self.candleWidth + self.space) * (self.dataSource.count - 1) + self.candleWidth : 0;
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.scrollView.frame.size.height);
}
- (void)hideKlineLongPressView {
    self.pressView.hidden = YES;
    self.titleGenerator.currentDateLabel.hidden = YES;
    self.generator.crossLineLayer.path = nil;
    self.titleGenerator.crossingLinePriceLabel.hidden = YES;

    self.generator.longPressCirclePriceLayer.path = nil;
    self.generator.longPressCircleAveragePriceLayer.path = nil;
}

- (UIView *)creatTypeViewWithTitle: (NSString *)title andColor: (UIColor *)color andIsSquare:(BOOL)isSquare {

    UIView *view = [[UIView alloc] init];
    UIView *leftTypeView = [[UIView alloc] init];
    leftTypeView.backgroundColor = color;

    UILabel *label = [UILabel labelWithText:title textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:10]];
    [view addSubview:leftTypeView];
    [view addSubview:label];

    [leftTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view);
        make.width.mas_equalTo(12);
        make.centerY.equalTo(view);
        make.height.mas_equalTo(isSquare ? 6 : 2);
    }];

    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view);
        make.leading.equalTo(leftTypeView.mas_trailing).offset(4);
        make.trailing.equalTo(view);
        make.top.bottom.equalTo(view);
    }];

    return view;
}

#pragma mark - 懒加载
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
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

#pragma mark - lazy gestureRecognizer

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
    }
    return _longPressGestureRecognizer;
}

- (YXBrokerDetailLongPressView *)pressView {
    if (_pressView == nil) {
        _pressView = [[YXBrokerDetailLongPressView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.candleRect), _pressViewWidth, 148) andType:self.type];
        _pressView.hidden = YES;
    }
    return _pressView;
}

- (NSArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSArray alloc] init];
    }
    return _dataSource;
}

- (YXStockEmptyDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[YXStockEmptyDataView alloc] init];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}


@end
