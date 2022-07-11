//
//  YXA_HKKLineView.m
//  uSmartOversea
//
//  Created by youxin on 2020/3/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXA_HKKLineView.h"
#import "YXAccessoryTitleGenerator.h"
#import "YXA_HKKLineLongPressView.h"
#import "YXLayerGenerator.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

typedef enum : NSUInteger {
    YXA_HKChartTypeFundAstock = 100, // A股通
    YXA_HKChartTypeFundSH, // 沪股通
    YXA_HKChartTypeFundSZ, // 深股通
    YXA_HKChartTypeFundHK, // 港股通
    YXA_HKChartTypeFundHKSH, // 港股通（沪）
    YXA_HKChartTypeFundHKSZ, // 港股通深）
    YXA_HKChartTypeIndexSH, // 上证指数
    YXA_HKChartTypeIndexSZ, // 上证指数
    YXA_HKChartTypeIndexHSI // 深证指数
} YXA_HKChartType;

#define kBrokerChartFirstColor   [UIColor colorWithRGB:0xF48053]
#define kBrokerChartSecondColor   [UIColor colorWithRGB:0x684BDE]

#define ktotalFundColor [UIColor qmui_colorWithHexString:@"#0055FF"]
#define kshFundColor [UIColor qmui_colorWithHexString:@"#F1B92D"]
#define kszFundColor [UIColor qmui_colorWithHexString:@"#28CAF1"]
#define kshIndexLineColor [UIColor qmui_colorWithHexString:@"#F1B92D"]
#define kszIndexLineColor [UIColor qmui_colorWithHexString:@"#28CAF1"]

#define kSHCODE @"HKSCSH"
#define kSZCODE @"HKSCSZ"
#define kACODE @"HKSCHS"
#define kHKCODE @"HSSCHK"
#define kHKSHCODE @"SHSCHK"
#define kHKSZCODE @"SZSCHK"

#define kIsShowTotalFundTrend [self realKeyWithOriKey:@"isShowTotalFundTrend" direction:self.type]
#define kIsShowSHFundTrend [self realKeyWithOriKey:@"isShowSHFundTrend" direction:self.type]
#define kIsShowSZFundTrend [self realKeyWithOriKey:@"isShowSZFundTrend" direction:self.type]
#define kIsShowSHIndexLine [self realKeyWithOriKey:@"isShowSHIndexLine" direction:self.type]
#define kIsShowSZIndexLine [self realKeyWithOriKey:@"isShowSZIndexLine" direction:self.type]


#define MAXThreeNum(a,b,c) (a>b?(a>c?a:c):(b>c?b:c))

@interface YXA_HKKLineView () <UIScrollViewDelegate>
//绘制k线图在scrollView上
@property (nonatomic, strong) UIScrollView *scrollView;
//宽度
@property (nonatomic, assign) double candleWidth;
//显示区域
@property (nonatomic, assign) CGRect candleRect;

//@property (nonatomic, assign) CGRect volumeRect;

//layer生成器
@property (nonatomic, strong) YXLayerGenerator *generator;

@property (nonatomic, strong) YXAccessoryTitleGenerator *titleGenerator;

@property (nonatomic, strong) CALayer *mainLayer;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic, strong) YXA_HKKLineLongPressView *pressView;

// 指数最大价格
@property (nonatomic, assign) double maxPrice;
@property (nonatomic, assign) double minPrice;

// 柱状图最大值
@property (nonatomic, assign) double maxFund;
@property (nonatomic, assign) double minFund;

@property (nonatomic, assign) NSInteger preListCount;

// 南向、北向
@property (nonatomic, assign) YXA_HKKLineDirection type;

// 资金流向图例
@property (nonatomic, strong) NSArray *fundGraphicViews;

// 指数图例
@property (nonatomic, strong) NSArray *indexGraphicViews;

//@property (nonatomic, strong) YXNoDataView *noDataView;

// 资金净流入流出
@property (nonatomic, strong) NSArray *fundLabels;

// 指数点数
@property (nonatomic, strong) NSArray *indexValueLabels;

@property (nonatomic, strong) UIStackView *fundLabelsStackView;

@property (nonatomic, strong) UIStackView *indexValueLabelsStackView;

// 图例
@property (nonatomic, strong) UIStackView *graphicSymbolStackView;

@property (nonatomic, assign) BOOL isShowTotalFundTrend;

@property (nonatomic, assign) BOOL isShowSHFundTrend;

@property (nonatomic, assign) BOOL isShowSZFundTrend;

@property (nonatomic, assign) BOOL isShowSHIndexLine;

@property (nonatomic, assign) BOOL isShowSZIndexLine;

@property (nonatomic, strong) UILabel *updateTimeLabel;

@property (nonatomic, strong) UILabel *unitLabel;

@property (nonatomic, strong) UILabel *titleLabel;

// 资金流向绝对值最大值
@property (nonatomic, assign) double maxFundAbsoluteValue;

// 日期
@property (nonatomic, strong) UILabel *dateLabel1;
@property (nonatomic, strong) UILabel *dateLabel2;
@property (nonatomic, strong) UILabel *dateLabel3;

@end

@implementation YXA_HKKLineView

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    
}


- (instancetype)initWithFrame:(CGRect)frame andType:(YXA_HKKLineDirection)direction {
    if (self = [super initWithFrame:frame]) {
        self.type = direction;

        self.isShowTotalFundTrend = [[MMKV defaultMMKV] getBoolForKey:kIsShowTotalFundTrend defaultValue:YES];
        self.isShowSHFundTrend = [[MMKV defaultMMKV] getBoolForKey:kIsShowSHFundTrend];
        self.isShowSZFundTrend = [[MMKV defaultMMKV] getBoolForKey:kIsShowSZFundTrend];
        self.isShowSHIndexLine = [[MMKV defaultMMKV] getBoolForKey:kIsShowSHIndexLine defaultValue: YES];
        self.isShowSZIndexLine = [[MMKV defaultMMKV] getBoolForKey:kIsShowSZIndexLine];
        [self initUI];
    }
    
    return self;
}

- (void)initUI {
    self.backgroundColor = QMUITheme.foregroundColor;
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(2);
        make.top.equalTo(self).offset(10);
    }];
    
    [self addSubview:self.scrollView];
    self.scrollView.frame = CGRectMake(0, 90, self.frame.size.width, 160);
    self.candleRect = self.scrollView.frame;
    
    // 图例
    [self addSubview:self.graphicSymbolStackView];
    [self.graphicSymbolStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([YXUserManager isENMode]) {
            make.left.equalTo(self);
            make.right.equalTo(self);
        }else {
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
        }
        
        
        make.height.mas_equalTo(30);
        make.bottom.equalTo(self).offset(-8);
    }];
    
    // 顶部左侧的单位
    [self addSubview:self.unitLabel];
    
    // 更新时间
    [self addSubview:self.updateTimeLabel];

    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(2);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
    }];
    
    [self.updateTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-2);
        make.top.equalTo(self.unitLabel);
    }];
    
    // 左侧资金额度
    [self addSubview:self.fundLabelsStackView];
    [self.fundLabelsStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(2);
        make.bottom.equalTo(self.scrollView);
        make.height.mas_equalTo(172);
    }];
    
    // 右侧指数点数
    [self addSubview:self.indexValueLabelsStackView];
    [self.indexValueLabelsStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-2);
        make.bottom.equalTo(self.scrollView);
        make.height.mas_equalTo(172);
    }];
    
    //起始和结束月份, 当前日期, 横线对应价格
    [self addSubview:self.titleGenerator.startDateLabel];
    [self addSubview:self.titleGenerator.endDateLabel];
    [self addSubview:self.titleGenerator.currentDateLabel];
    
    self.titleGenerator.currentDateLabel.hidden = YES;
    self.titleGenerator.crossingLinePriceLabel.hidden = YES;
    self.titleGenerator.timeLineCrossingPriceLabel.hidden = YES;
    
    [self.titleGenerator.startDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(5);
        make.top.mas_equalTo(CGRectGetMaxY(self.candleRect)+5) ;
    }];
    
    [self.titleGenerator.endDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-5);
        make.top.equalTo(self.titleGenerator.startDateLabel);
    }];
    
    // 宽度
    self.candleWidth = 12;
    self.space = self.candleWidth * 0.5;
    
    self.mainLayer = [[CALayer alloc] init];
    self.mainLayer.masksToBounds = true;
    self.mainLayer.frame = self.scrollView.bounds;
    [self.scrollView.layer addSublayer:self.mainLayer];

    // 长按线
    [self.layer addSublayer:self.generator.crossLineLayer];
    self.generator.crossLineLayer.hidden = YES;
    
    [self addSubview:self.titleGenerator.crossingLinePriceLabel]; // 十字线左侧显示的价格
    [self addSubview:self.titleGenerator.timeLineCrossingPriceLabel]; // 十字线右侧指数值
    
    [self.titleGenerator.crossingLinePriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(20);
    }];
    
    [self.titleGenerator.timeLineCrossingPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(20);
    }];
    
    [self addSubview:self.pressView];
    [self.pressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.mas_equalTo(self.candleRect.origin.y);
        make.width.mas_equalTo(130);
    }];
    
    [self drawCrossLayer];
    
    // 增加画线
    [self.mainLayer addSublayer:self.generator.ma5Layer]; // 上证指数
    [self.mainLayer addSublayer:self.generator.ma20Layer]; // 深圳指数
    [self.mainLayer addSublayer:self.generator.greenVolumeLayer]; // A股通
    [self.mainLayer addSublayer:self.generator.redVolumeLayer]; // 沪股通
    [self.mainLayer addSublayer:self.generator.greyVolumeLayer]; // 深股通
    
    [self.mainLayer addSublayer:self.generator.subVerticalLayer];
    
    self.generator.ma5Layer.strokeColor = kshIndexLineColor.CGColor;
    self.generator.greenVolumeLayer.fillColor = ktotalFundColor.CGColor;
    self.generator.greenVolumeLayer.strokeColor = ktotalFundColor.CGColor;
    self.generator.redVolumeLayer.fillColor = kshFundColor.CGColor;
    self.generator.redVolumeLayer.strokeColor = kshFundColor.CGColor;
    self.generator.greyVolumeLayer.fillColor = kszFundColor.CGColor;
    self.generator.greyVolumeLayer.strokeColor = kszFundColor.CGColor;
    
    // 与指数相交的小圆圈
    [self.layer addSublayer: self.generator.longPressCircleAveragePriceLayer];
    self.generator.longPressCircleAveragePriceLayer.strokeColor = [UIColor grayColor].CGColor;//kBrokerChartSecondColor.CGColor;
    
    [self addGestureRecognizer:self.longPressGestureRecognizer];
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)drawCrossLayer {
    //网格线
    [self.layer addSublayer:self.generator.horizonLayer];
    [self.layer addSublayer:self.generator.verticalLayer];

    // 主网格线
    UIBezierPath *horizenPath = [UIBezierPath bezierPath];
    UIBezierPath *verticalPath = [UIBezierPath bezierPath];
    for (int x = 0; x < 3; x ++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(self.candleRect.origin.x, self.candleRect.origin.y + CGRectGetHeight(self.candleRect) / 2.0 * x)];
        [path addLineToPoint:CGPointMake(self.candleRect.size.width, self.candleRect.origin.y + CGRectGetHeight(self.candleRect) / 2.0 * x)];
        [horizenPath appendPath:path];
    }
    for (int x = 0; x < 2; x ++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(self.candleRect.origin.x + CGRectGetWidth(self.candleRect) * x, self.candleRect.origin.y)];
        [path addLineToPoint:CGPointMake(self.candleRect.origin.x + CGRectGetWidth(self.candleRect) * x, CGRectGetMaxY(self.candleRect))];
        [verticalPath appendPath:path];
    }
    
    self.generator.horizonLayer.path = horizenPath.CGPath;
    self.generator.verticalLayer.path = verticalPath.CGPath;
    [self.layer qmui_sendSublayerToBack:self.generator.horizonLayer];
    [self.layer qmui_sendSublayerToBack:self.generator.verticalLayer];
}

- (NSString *)realKeyWithOriKey:(NSString *)oriKey direction:(YXA_HKKLineDirection)direction {
    NSString *str = direction == YXA_HKKLineDirectionNorth ? @"north" : @"south";
    return  [NSString stringWithFormat:@"%@_%@", oriKey, str];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (object == self.scrollView) {
        if (self.scrollView.contentSize.width < self.frame.size.width) {
            self.mainLayer.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, CGRectGetHeight(self.candleRect));
        } else {
            self.mainLayer.frame = CGRectMake(0, 0, self.scrollView.contentSize.width, CGRectGetHeight(self.candleRect));
        }
    }
}

- (void)drawMainLayer {
    
    NSArray *visibleArray = [self getVisibleArr];
    if (visibleArray.count <= 0) {
        return;
    }
    
    // 指数曲线
    if (self.type == YXA_HKKLineDirectionNorth) {
        // 北向要画上证指数和深证指数，两条二选一显示
        if (self.isShowSHIndexLine) {
            self.maxPrice = [[visibleArray valueForKeyPath:@"@max.shIndexPrice"] doubleValue];
            self.minPrice = [[visibleArray valueForKeyPath:@"@min.shIndexPrice"] doubleValue];
            self.generator.ma5Layer.strokeColor = kshIndexLineColor.CGColor;
        }else {
            self.maxPrice = [[visibleArray valueForKeyPath:@"@max.szIndexPrice"] doubleValue];
            self.minPrice = [[visibleArray valueForKeyPath:@"@min.szIndexPrice"] doubleValue];
            self.generator.ma5Layer.strokeColor = kszIndexLineColor.CGColor;
        }
        
    }else {
        // 南向只画恒生指数
        self.maxPrice = [[visibleArray valueForKeyPath:@"@max.HSIIndexPrice"] doubleValue];
        self.minPrice = [[visibleArray valueForKeyPath:@"@min.HSIIndexPrice"] doubleValue];
        self.generator.ma5Layer.strokeColor = kshIndexLineColor.CGColor;
    }

    // 资金流入流出柱状图
    if (self.isShowTotalFundTrend && self.isShowSHFundTrend && self.isShowSZFundTrend) {
        NSArray *maxArr = @[[visibleArray valueForKeyPath:@"@max.totalAmount"], [visibleArray valueForKeyPath:@"@max.shAmount"], [visibleArray valueForKeyPath:@"@max.szAmount"]];
        NSArray *minArr = @[[visibleArray valueForKeyPath:@"@min.totalAmount"], [visibleArray valueForKeyPath:@"@min.shAmount"], [visibleArray valueForKeyPath:@"@min.szAmount"]];
        self.maxFund = [[maxArr valueForKeyPath:@"@max.self"] doubleValue];
        self.minFund = [[minArr valueForKeyPath:@"@min.self"] doubleValue];
        
    }else if (self.isShowTotalFundTrend && self.isShowSHFundTrend) {
        int64_t totalmax = [[visibleArray valueForKeyPath:@"@max.totalAmount"] doubleValue];
        int64_t totalmin = [[visibleArray valueForKeyPath:@"@min.totalAmount"] doubleValue];
        int64_t shmax = [[visibleArray valueForKeyPath:@"@max.shAmount"] doubleValue];
        int64_t shmin = [[visibleArray valueForKeyPath:@"@min.shAmount"] doubleValue];
        self.maxFund = MAX(totalmax, shmax);
        self.minFund = MIN(totalmin, shmin);
    }else if (self.isShowTotalFundTrend && self.isShowSZFundTrend) {
        int64_t totalmax = [[visibleArray valueForKeyPath:@"@max.totalAmount"] doubleValue];
        int64_t totalmin = [[visibleArray valueForKeyPath:@"@min.totalAmount"] doubleValue];
        int64_t szmax = [[visibleArray valueForKeyPath:@"@max.szAmount"] doubleValue];
        int64_t szmin = [[visibleArray valueForKeyPath:@"@min.szAmount"] doubleValue];
        self.maxFund = MAX(totalmax, szmax);
        self.minFund = MIN(totalmin, szmin);
    }else if (self.isShowSHFundTrend && self.isShowSZFundTrend) {
        int64_t shmax = [[visibleArray valueForKeyPath:@"@max.shAmount"] doubleValue];
        int64_t shmin = [[visibleArray valueForKeyPath:@"@min.shAmount"] doubleValue];
        int64_t szmax = [[visibleArray valueForKeyPath:@"@max.szAmount"] doubleValue];
        int64_t szmin = [[visibleArray valueForKeyPath:@"@min.szAmount"] doubleValue];
        self.maxFund = MAX(shmax, szmax);
        self.minFund = MIN(shmin, szmin);
    }else if (self.isShowSHFundTrend) {
        self.maxFund = [[visibleArray valueForKeyPath:@"@max.shAmount"] doubleValue];
        self.minFund = [[visibleArray valueForKeyPath:@"@min.shAmount"] doubleValue];
    }else if (self.isShowSZFundTrend) {
        self.maxFund = [[visibleArray valueForKeyPath:@"@max.szAmount"] doubleValue];
        self.minFund = [[visibleArray valueForKeyPath:@"@min.szAmount"] doubleValue];
    }else if (self.isShowTotalFundTrend) {
        self.maxFund = [[visibleArray valueForKeyPath:@"@max.totalAmount"] doubleValue];
        self.minFund = [[visibleArray valueForKeyPath:@"@min.totalAmount"] doubleValue];
    }
    
    double maxVolume = self.maxFund;
    double minVolume = self.minFund;
    maxVolume = fabs(maxVolume);
    minVolume = fabs(minVolume);
    
    self.maxFundAbsoluteValue = MAX(maxVolume, minVolume);
    maxVolume = self.maxFundAbsoluteValue;
    minVolume = -self.maxFundAbsoluteValue;
    
    CGFloat candleDistance = CGRectGetHeight(self.candleRect) * 1;
    
    CGFloat volumnDistance = candleDistance * 0.5;
    
    CGFloat zeroVolumeY = volumnDistance;
    
    UIBezierPath *indexPath = [UIBezierPath bezierPath];
    UIBezierPath *TotalFundPath = [UIBezierPath bezierPath];
    UIBezierPath *SHFundPath = [UIBezierPath bezierPath];
    UIBezierPath *SZFundPath = [UIBezierPath bezierPath];
    
    YXA_HKFundTrendKlineCustomModel *firstItem = visibleArray.firstObject;
    YXA_HKFundTrendKlineCustomModel *lastItem = visibleArray.lastObject;
    
    for (int i = 0; i < self.fundLabels.count; i++) {
        UILabel *label = self.fundLabels[i];
        NSInteger count = self.fundLabels.count;
        NSInteger t = count/2 - i;
        float value = maxVolume/(count/2) * t;
        label.text = [NSString stringWithFormat:@"%.2lf", value];
    }
    
    for (int i = 0; i < self.indexValueLabels.count; i++) {
        NSInteger count = self.indexValueLabels.count;
        
        UILabel *priceLabel = self.indexValueLabels[i];
        float indexValue = self.maxPrice - ((self.maxPrice-self.minPrice)/(count-1)) * i;
        priceLabel.text = [NSString stringWithFormat:@"%.2lf", indexValue];
    }
    
    UIBezierPath *verticalPath = [UIBezierPath bezierPath];
    [visibleArray enumerateObjectsUsingBlock:^(YXA_HKFundTrendKlineCustomModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat x = (self.candleWidth + self.space) * obj.index.integerValue + self.candleWidth * 0.5;
        
        // 日期线
//        if (obj.index.integerValue % 14 == 0) {
//            UIBezierPath *path = [UIBezierPath bezierPath];
//            [path moveToPoint:CGPointMake(x, 0)];
//            [path addLineToPoint:CGPointMake(x, CGRectGetHeight(self.candleRect))];
//            [verticalPath appendPath:path];
//        }
       
        CGFloat priceY;
        if (self.type == YXA_HKKLineDirectionNorth) {
            if (self.isShowSHIndexLine) {
                priceY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxPrice minPrice:self.minPrice price:obj.shIndexPrice distance:candleDistance zeroY:candleDistance];
            }else {
                priceY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxPrice minPrice:self.minPrice price:obj.szIndexPrice distance:candleDistance zeroY:candleDistance];
            }
        }else {
            priceY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxPrice minPrice:self.minPrice price:obj.HSIIndexPrice distance:candleDistance zeroY:candleDistance];
        }
        
        CGFloat volumeY = 0;
    
        if (idx == 0) {
            [indexPath moveToPoint:CGPointMake(x, priceY)];
        } else {
            [indexPath addLineToPoint:CGPointMake(x, priceY)];
        }
        
        NSArray *fundArr;
        NSArray *pathArr;
        if (self.isShowTotalFundTrend && self.isShowSHFundTrend && self.isShowSZFundTrend) {
            fundArr = @[@(obj.totalAmount), @(obj.shAmount), @(obj.szAmount)];
            pathArr = @[TotalFundPath, SHFundPath, SZFundPath];
        }else if (self.isShowTotalFundTrend && self.isShowSHFundTrend) {
            fundArr = @[@(obj.totalAmount), @(obj.shAmount)];
            pathArr = @[TotalFundPath, SHFundPath];
        }else if (self.isShowTotalFundTrend && self.isShowSZFundTrend) {
            fundArr = @[@(obj.totalAmount), @(obj.szAmount)];
            pathArr = @[TotalFundPath, SZFundPath];
        }else if (self.isShowSHFundTrend && self.isShowSZFundTrend) {
            fundArr = @[@(obj.shAmount), @(obj.szAmount)];
            pathArr = @[SHFundPath, SZFundPath];
        }else if (self.isShowSHFundTrend) {
            fundArr = @[@(obj.shAmount)];
            pathArr = @[SHFundPath];
        }else if (self.isShowSZFundTrend) {
            fundArr = @[@(obj.szAmount)];
            pathArr = @[SZFundPath];
        }else if (self.isShowTotalFundTrend) {
            fundArr = @[@(obj.totalAmount)];
            pathArr = @[TotalFundPath];
        }
        
        float count = fundArr.count;
        for (int i = 0; i < count; i++) {
            UIBezierPath *path = pathArr[i];
            int64_t fund = [fundArr[i] longLongValue];
            if (fund >= 0) {
                volumeY = [YXKLineUtility getYCoordinateWithMaxVolumn:maxVolume minVolumn:0 volume:fund distance:volumnDistance zeroY: zeroVolumeY];
                if ((zeroVolumeY - volumeY) < 0.5) {
                    volumeY = zeroVolumeY - 0.5;
                }
                UIBezierPath *temp = [UIBezierPath bezierPathWithRect:CGRectMake((x - self.candleWidth * 0.5) + (self.candleWidth/count * i), volumeY, self.candleWidth/count, zeroVolumeY - volumeY)];
                [path appendPath:temp];
            } else if (fund < 0) {
                volumeY = [YXKLineUtility getYCoordinateWithMaxVolumn:0 minVolumn:minVolume volume:fund distance:volumnDistance zeroY: volumnDistance];
                if (volumeY < 0.5) {
                    volumeY = 0.5;
                }
                UIBezierPath *temp = [UIBezierPath bezierPathWithRect:CGRectMake((x - self.candleWidth * 0.5) + (self.candleWidth/count * i), zeroVolumeY, self.candleWidth/count, volumeY)];
                [path appendPath:temp];
            }
        }
        
    }];
    
    self.generator.ma5Layer.path = indexPath.CGPath;
    self.generator.greenVolumeLayer.path = TotalFundPath.CGPath;
    self.generator.redVolumeLayer.path = SHFundPath.CGPath;
    self.generator.greyVolumeLayer.path = SZFundPath.CGPath;
    
    self.generator.subVerticalLayer.path = verticalPath.CGPath;
    [self.mainLayer qmui_sendSublayerToBack:self.generator.subVerticalLayer];
    
    self.titleGenerator.startDateLabel.text = [YXDateHelper commonDateString:firstItem.time format:YXCommonDateFormatDF_MD scaleType:YXCommonDateScaleTypeSlash showWeek:NO];
    self.titleGenerator.endDateLabel.text = [YXDateHelper commonDateString:lastItem.time format:YXCommonDateFormatDF_MD scaleType:YXCommonDateScaleTypeSlash showWeek:NO];
}

/**
 获取当前可视图部分数据数组
 */
- (NSArray *)getVisibleArr{
    
    //算出取数组的位置(location这里已经进行了取整)
    NSMutableArray<YXA_HKFundTrendKlineCustomModel *> *visibleArray = [NSMutableArray<YXA_HKFundTrendKlineCustomModel *> array];
    for (int x = 0; x < self.dataSource.count; x ++) {
        if (x * (self.candleWidth + self.space) + self.candleWidth * 0.5 >= self.scrollView.contentOffset.x && x * (self.candleWidth + self.space) + self.candleWidth * 0.5 <= (self.scrollView.contentOffset.x + self.candleRect.size.width)) {
            YXA_HKFundTrendKlineCustomModel *kLineSingleModel = self.dataSource[x];
            kLineSingleModel.index = [[NSNumber alloc] initWithInt:x];
            
            [visibleArray addObject:kLineSingleModel];
        }
    }
    return visibleArray;
}

- (float)getUnitValue: (float)value {
    if (value >= 100000000) {
        return 100000000;
    } else if (value >= 10000) {
        return 10000;
    } else {
        return 1;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x <= 0.0) {  //加载更多(分页)
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
    
    if (self.dataSource.count == 0) {
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
        
        YXA_HKFundTrendKlineCustomModel *model = self.dataSource[location];
        
        self.pressView.hidden = NO;
        self.pressView.isShowTotalFundTrend = self.isShowTotalFundTrend;
        self.pressView.isShowSHFundTrend = self.isShowSHFundTrend;
        self.pressView.isShowSZFundTrend = self.isShowSZFundTrend;
        self.pressView.isShowSHIndexLine = self.isShowSHIndexLine;
        self.pressView.isShowSZIndexLine = self.isShowSZIndexLine;
        self.pressView.model = model;

        self.scrollView.scrollEnabled = NO;
        self.generator.crossLineLayer.hidden = NO;
        self.titleGenerator.crossingLinePriceLabel.hidden = NO;
        self.titleGenerator.timeLineCrossingPriceLabel.hidden = NO;

        UIBezierPath *path = [UIBezierPath bezierPath];
        double minX = CGRectGetMinX(self.candleRect);
        double maxX = CGRectGetMaxX(self.candleRect);
        double minY = 0;

        double current_y = 0;
        if (point.y <= 0) {
            current_y = self.candleRect.origin.y + CGRectGetHeight(self.candleRect) * 0;
        } else if(point.y >= CGRectGetHeight(self.candleRect)) {
            current_y = CGRectGetMaxY(self.candleRect);
        } else {
            current_y = point.y;
            current_y = current_y + self.candleRect.origin.y;
        }
        double current_x = location * (self.candleWidth + self.space) +  self.candleWidth * 0.5 - self.scrollView.contentOffset.x;
        
        double crossingLabelY = current_y;
        
        //横线
        [path moveToPoint:CGPointMake(minX, current_y)];
        [path addLineToPoint:CGPointMake(maxX, current_y)];

        //纵线
        [path moveToPoint:CGPointMake(current_x, minY + self.candleRect.origin.y)];
        [path addLineToPoint:CGPointMake(current_x, CGRectGetMaxY(self.candleRect))];
        [path closePath];
        self.generator.crossLineLayer.path = path.CGPath;

        //横线对应价格
        if (crossingLabelY <= self.candleRect.origin.y + self.titleGenerator.crossingLinePriceLabel.frame.size.height / 2.0) {
            crossingLabelY = self.candleRect.origin.y + self.titleGenerator.crossingLinePriceLabel.frame.size.height / 2.0;
        }
        //横线对应的指数值
        if (crossingLabelY >= CGRectGetMaxY(self.candleRect) - self.titleGenerator.crossingLinePriceLabel.frame.size.height / 2.0) {
            crossingLabelY = CGRectGetMaxY(self.candleRect) - self.titleGenerator.crossingLinePriceLabel.frame.size.height / 2.0;
        }
        [self.titleGenerator.crossingLinePriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_top).offset(crossingLabelY);
        }];
        
        [self.titleGenerator.timeLineCrossingPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_top).offset(crossingLabelY);
        }];
        
        float priceY = point.y;
        if (priceY < 0) {
            priceY = 0;
        }
        if (priceY > self.candleRect.size.height) {
            priceY = self.candleRect.size.height;
        }
        
        float distance = self.candleRect.size.height/2;
        double crossingLineFundPrice = self.maxFundAbsoluteValue * (distance - priceY)/distance;
        
        self.titleGenerator.crossingLinePriceLabel.text = [NSString stringWithFormat:@"%.2f", crossingLineFundPrice];
        
        double crossingLineIndexPrice = self.maxPrice - (priceY/self.candleRect.size.height * (self.maxPrice - self.minPrice));
        self.titleGenerator.timeLineCrossingPriceLabel.text = [NSString stringWithFormat:@"%.2f", crossingLineIndexPrice];
        
        double currentPrice;
        if (self.type == YXA_HKKLineDirectionNorth) {
            if (self.isShowSHIndexLine) {
                currentPrice = model.shIndexPrice;
            }else {
                currentPrice = model.szIndexPrice;
            }
        }else {
            currentPrice = model.HSIIndexPrice;
        }
        
        CGPoint averagePonit = CGPointMake(current_x, [YXKLineUtility getYCoordinateWithMaxPrice:self.maxPrice minPrice:self.minPrice price:currentPrice distance:CGRectGetHeight(self.candleRect) zeroY:CGRectGetMaxY(self.candleRect)]);
        UIBezierPath *averagePath = [UIBezierPath bezierPathWithArcCenter:averagePonit radius:3 startAngle:0 endAngle:360 clockwise:YES];
        self.generator.longPressCircleAveragePriceLayer.path = averagePath.CGPath;
        
        //长按对应的日期
        self.titleGenerator.currentDateLabel.hidden = NO;
        
        if (current_x < CGRectGetWidth(self.candleRect) * 0.5) {
            [self.pressView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self);
                make.top.mas_equalTo(self.candleRect.origin.y);
                make.width.mas_equalTo(130);
            }];
            
        } else {
            [self.pressView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.top.mas_equalTo(self.candleRect.origin.y);
                make.width.mas_equalTo(130);
            }];
        }

        self.titleGenerator.currentDateLabel.text = [YXDateHelper commonDateString:model.time format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:YES];
        self.titleGenerator.currentDateLabel.frame = CGRectMake(current_x - 50, CGRectGetMaxY(self.candleRect), 100, 15);
        if (CGRectGetMaxX(self.titleGenerator.currentDateLabel.frame) >= self.frame.size.width) {
            self.titleGenerator.currentDateLabel.frame = CGRectMake(self.frame.size.width - 100, CGRectGetMaxY(self.candleRect), 100, 15);
        }
        if (self.titleGenerator.currentDateLabel.frame.origin.x <= self.frame.origin.x) {
            self.titleGenerator.currentDateLabel.frame = CGRectMake(0, CGRectGetMaxY(self.candleRect), 100, 15);
        }

    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        self.scrollView.scrollEnabled = YES;
        [self performSelector:@selector(hideKlineLongPressView) withObject:nil afterDelay:3.0];
    }
}


- (void)setDataSource:(NSArray *)dataSource {
    if (dataSource.count == 0) {
        return;
    }
    YXA_HKFundTrendKlineCustomModel *firstItem = dataSource.firstObject;

    NSString *timeStr = [YXDateHelper commonDateString:firstItem.time format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeSlash showWeek:NO];
    self.updateTimeLabel.text = [NSString stringWithFormat:@"%@：%@", [YXLanguageUtility kLangWithKey:@"bubear_update_time"], timeStr];
    
    NSArray *list = [[dataSource reverseObjectEnumerator] allObjects];
    _dataSource = list;
    
    [self configureBaseDatas];
    
    NSInteger offset = dataSource.count - self.preListCount;
    if (self.preListCount == dataSource.count && self.preListCount > 0) {
        // 最后一次刷新到数据
    } else if (offset != 0 && self.preListCount != 0) {
        // 加载更多的时候
        self.scrollView.contentOffset = CGPointMake((dataSource.count - self.preListCount) * (self.candleWidth + self.space), 0);
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
    self.generator.redVolumeLayer.path = nil;
    self.generator.greyVolumeLayer.path = nil;
    
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
    self.titleGenerator.timeLineCrossingPriceLabel.hidden = YES;
    
    self.generator.longPressCirclePriceLayer.path = nil;
    self.generator.longPressCircleAveragePriceLayer.path = nil;
}

- (UIView *)creatTypeViewWithTitle: (NSString *)title andColor: (UIColor *)color andIsSquare:(BOOL)isSquare {
    
    UIView *view = [[UIView alloc] init];
    UIView *leftTypeView = [[UIView alloc] init];
    leftTypeView.backgroundColor = color;
    
    UILabel *label = [UILabel labelWithText:title textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:10]];
    label.numberOfLines = 2;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.3;
    [view addSubview:leftTypeView];
    [view addSubview:label];
    
    [leftTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view).offset(5);
        make.width.mas_equalTo(isSquare ? 8 : 12);
        make.centerY.equalTo(view);
        make.height.mas_equalTo(isSquare ? 8 : 2);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view);
        make.leading.equalTo(leftTypeView.mas_trailing).offset(3);
        make.trailing.equalTo(view).offset(-5);
        make.top.bottom.equalTo(view);
        make.height.mas_equalTo(30);
        make.width.mas_greaterThanOrEqualTo(40);
    }];
    
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 2;
    
    return view;
}

// 点击图例
- (void)graphicSymbolView:(UITapGestureRecognizer *)tap {
    
    if (self.type == YXA_HKKLineDirectionSouth) {
        if (tap.view.tag == YXA_HKChartTypeFundHK || tap.view.tag == YXA_HKChartTypeFundHKSH || tap.view.tag == YXA_HKChartTypeFundHKSZ) {
            int count = 0;
            for (UIView *view in self.fundGraphicViews) {
                if (view.alpha == 1) {
                    count++;
                }
            }
            if (tap.view.alpha == 1) {
                // 至少有一个必须点亮
                if (count > 1) {
                    tap.view.alpha = 0.5;
                    tap.view.layer.borderColor = [UIColor clearColor].CGColor;
                }
            }else {
                tap.view.alpha = 1;
                tap.view.layer.borderColor = [QMUITheme themeTextColor].CGColor;
            }
        }
    }else {
        if (tap.view.tag == YXA_HKChartTypeFundAstock || tap.view.tag == YXA_HKChartTypeFundSH || tap.view.tag == YXA_HKChartTypeFundSZ) {
            int count = 0;
            for (UIView *view in self.fundGraphicViews) {
                if (view.alpha == 1) {
                    count++;
                }
            }
            if (tap.view.alpha == 1) {
                // 至少有一个必须点亮
                if (count > 1) {
                    tap.view.alpha = 0.5;
                    tap.view.layer.borderColor = [UIColor clearColor].CGColor;
                }
            }else {
                tap.view.alpha = 1;
                tap.view.layer.borderColor = [QMUITheme themeTextColor].CGColor;
            }
        }else {
            // 二选一
            if (tap.view.alpha == 0.5) {
                tap.view.alpha = 1;
                tap.view.layer.borderColor = [QMUITheme themeTextColor].CGColor;
                if (tap.view.tag == YXA_HKChartTypeIndexSH) {
                    UIView *indexSZView = self.indexGraphicViews[1];
                    indexSZView.alpha = 0.5;
                    indexSZView.layer.borderColor = [UIColor clearColor].CGColor;
                }else {
                    UIView *indexSHView = self.indexGraphicViews[0];
                    indexSHView.alpha = 0.5;
                    indexSHView.layer.borderColor = [UIColor clearColor].CGColor;
                }
            }
        }
    }
    
    NSMutableArray *allViews = [NSMutableArray arrayWithArray:self.fundGraphicViews];
    [allViews addObjectsFromArray:self.indexGraphicViews];
    for (UIView *view in allViews) {
        if (view.tag == YXA_HKChartTypeFundAstock || view.tag == YXA_HKChartTypeFundHK) {
            self.isShowTotalFundTrend = (view.alpha == 1);
        }else if (view.tag == YXA_HKChartTypeFundSH || view.tag == YXA_HKChartTypeFundHKSH) {
            self.isShowSHFundTrend = (view.alpha == 1);
        }else if (view.tag == YXA_HKChartTypeFundSZ || view.tag == YXA_HKChartTypeFundHKSZ) {
            self.isShowSZFundTrend = (view.alpha == 1);
        }else if (view.tag == YXA_HKChartTypeIndexSH || view.tag == YXA_HKChartTypeIndexHSI) {
            self.isShowSHIndexLine = (view.alpha == 1);
        }else if (view.tag == YXA_HKChartTypeIndexSZ) {
            self.isShowSZIndexLine = (view.alpha == 1);
        }
    }
    
    [[MMKV defaultMMKV] setBool:self.isShowTotalFundTrend forKey:kIsShowTotalFundTrend];
    [[MMKV defaultMMKV] setBool:self.isShowSHFundTrend forKey:kIsShowSHFundTrend];
    [[MMKV defaultMMKV] setBool:self.isShowSZFundTrend forKey:kIsShowSZFundTrend];
    [[MMKV defaultMMKV] setBool:self.isShowSHIndexLine forKey:kIsShowSHIndexLine];
    [[MMKV defaultMMKV] setBool:self.isShowSZIndexLine forKey:kIsShowSZIndexLine];
    
    [self drawMainLayer];
    
}
#pragma mark - 懒加载
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor]; _scrollView.showsHorizontalScrollIndicator = NO;
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

- (YXA_HKKLineLongPressView *)pressView {
    if (_pressView == nil) {
        _pressView = [[YXA_HKKLineLongPressView alloc] initWithFrame:CGRectZero andType:self.type];
        _pressView.hidden = YES;
    }
    return _pressView;
}

//- (YXNoDataView *)noDataView {
//    if (!_noDataView) {
//        _noDataView = [[YXNoDataView alloc] init];
//        [_noDataView showText:@"暂无数据" textColor:[QMUITheme textColorLevel3] showImageName:@"empty3_black"];
//        _noDataView.hidden = YES;
//    }
//    return _noDataView;
//}

- (NSArray *)fundLabels {
    if (!_fundLabels) {
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i < 5; i++) {
            UILabel *label = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightMedium] textAlignment:NSTextAlignmentLeft];
            [arr addObject:label];
        }
        
        _fundLabels = [arr copy];
    }
    
    return _fundLabels;
}

- (NSArray *)indexValueLabels {
    if (!_indexValueLabels) {
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            UILabel *label = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightMedium] textAlignment:NSTextAlignmentRight];
            [arr addObject:label];
        }
        
        _indexValueLabels = [arr copy];
    }
    
    return _indexValueLabels;
}

- (UIStackView *)fundLabelsStackView {
    if (!_fundLabelsStackView) {
        _fundLabelsStackView = [[UIStackView alloc] initWithArrangedSubviews:self.fundLabels];
        _fundLabelsStackView.alignment = UIStackViewAlignmentLeading;
        _fundLabelsStackView.distribution = UIStackViewDistributionEqualSpacing;
        _fundLabelsStackView.axis = UILayoutConstraintAxisVertical;
//        _fundLabelsStackView.spacing = 30;
    }
    
    return _fundLabelsStackView;
}

- (UIStackView *)indexValueLabelsStackView {
    if (!_indexValueLabelsStackView) {
        _indexValueLabelsStackView = [[UIStackView alloc] initWithArrangedSubviews:self.indexValueLabels];
        _indexValueLabelsStackView.alignment = UIStackViewAlignmentTrailing;
        _indexValueLabelsStackView.distribution = UIStackViewDistributionEqualSpacing;
        _indexValueLabelsStackView.axis = UILayoutConstraintAxisVertical;
//        _indexValueLabelsStackView.spacing = 50;
    }
    
    return _indexValueLabelsStackView;
}

- (UIStackView *)graphicSymbolStackView {
    if (!_graphicSymbolStackView) {
        _graphicSymbolStackView = [[UIStackView alloc] init];
        _graphicSymbolStackView.alignment = UIStackViewAlignmentCenter;
        _graphicSymbolStackView.distribution = UIStackViewDistributionEqualSpacing;
        if ([YXUserManager isENMode] && self.type == YXA_HKKLineDirectionNorth) {
            _graphicSymbolStackView.distribution = UIStackViewDistributionFillEqually;
        }
        _graphicSymbolStackView.axis = UILayoutConstraintAxisHorizontal;
        
        NSArray *titles;
        NSArray *shouldSelecteds;
        if (self.type == YXA_HKKLineDirectionSouth) {
            titles = @[@{@"title": [YXLanguageUtility kLangWithKey:@"bubear_hk_connect_wrap"], @"color": ktotalFundColor, @"tag": @(YXA_HKChartTypeFundHK), @"isSquare": @(YES)},
                              @{@"title": [YXLanguageUtility kLangWithKey:@"bubear_shhk_connect_wrap"], @"color": kshFundColor, @"tag": @(YXA_HKChartTypeFundHKSH), @"isSquare": @(YES)},
                              @{@"title": [YXLanguageUtility kLangWithKey:@"bubear_szhk_connect_wrap"], @"color": kszFundColor, @"tag": @(YXA_HKChartTypeFundHKSZ), @"isSquare": @(YES)},
                              @{@"title": [YXLanguageUtility kLangWithKey:@"common_hkHSI"], @"color": kshIndexLineColor, @"tag": @(YXA_HKChartTypeIndexHSI), @"isSquare": @(NO)}];
            
            shouldSelecteds = @[@(self.isShowTotalFundTrend), @(self.isShowSHFundTrend), @(self.isShowSZFundTrend), @(self.isShowSHIndexLine)];
            
        } else {
            titles = @[@{@"title": [YXLanguageUtility kLangWithKey:@"bubear_cn_connect_wrap"], @"color": ktotalFundColor, @"tag": @(YXA_HKChartTypeFundAstock), @"isSquare": @(YES)},
                              @{@"title": [YXLanguageUtility kLangWithKey:@"markets_news_sh_connect"], @"color": kshFundColor, @"tag": @(YXA_HKChartTypeFundSH), @"isSquare": @(YES)},
                              @{@"title": [YXLanguageUtility kLangWithKey:@"markets_news_sz_connect"], @"color": kszFundColor, @"tag": @(YXA_HKChartTypeFundSZ), @"isSquare": @(YES)},
                              @{@"title": [YXLanguageUtility kLangWithKey:@"bubear_sse_composite"], @"color": kshIndexLineColor, @"tag": @(YXA_HKChartTypeIndexSH), @"isSquare": @(NO)},
                              @{@"title": [YXLanguageUtility kLangWithKey:@"bubear_szse_composite"], @"color": kszIndexLineColor, @"tag": @(YXA_HKChartTypeIndexSZ), @"isSquare": @(NO)}];
            
            shouldSelecteds = @[@(self.isShowTotalFundTrend), @(self.isShowSHFundTrend), @(self.isShowSZFundTrend), @(self.isShowSHIndexLine), @(self.isShowSZIndexLine)];
        }
        
        NSMutableArray *fundViews = [NSMutableArray array];
        NSMutableArray *indexViews = [NSMutableArray array];
        
        for (int i = 0; i < titles.count; i++) {
            NSDictionary *dic = titles[i];
            NSString *title = dic[@"title"];
            UIColor *color = dic[@"color"];
            NSInteger tag = [dic[@"tag"] integerValue];
            BOOL isSquare = [dic[@"isSquare"] boolValue];
            UIView *sqView = [self creatTypeViewWithTitle:title andColor:color andIsSquare:isSquare];
            sqView.tag = tag;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(graphicSymbolView:)];
            [sqView addGestureRecognizer:tap];
            
            [self.graphicSymbolStackView addArrangedSubview:sqView];
            
            BOOL isSelected = [shouldSelecteds[i] boolValue];
            
            if (isSelected) {
                sqView.alpha = 1;
                sqView.layer.borderColor = [QMUITheme themeTextColor].CGColor;
            }else {
                sqView.alpha = 0.5;
                sqView.layer.borderColor = [UIColor clearColor].CGColor;
            }
            
            if (i < 3) {
                [fundViews addObject:sqView];
            }else {
                [indexViews addObject:sqView];
            }
        }
        
        self.fundGraphicViews = [fundViews copy];
        self.indexGraphicViews = [indexViews copy];
    }
    
    return _graphicSymbolStackView;
}

- (UILabel *)updateTimeLabel {
    if (!_updateTimeLabel) {
        _updateTimeLabel = [[UILabel alloc] init];
        _updateTimeLabel.font = [UIFont systemFontOfSize:10];
        _updateTimeLabel.textColor = [QMUITheme textColorLevel4];
        _updateTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return  _updateTimeLabel;
}

- (UILabel *)unitLabel {
    if (!_unitLabel) {
        _unitLabel = [[UILabel alloc] init];
        _unitLabel.font = [UIFont systemFontOfSize:10];
        _unitLabel.textColor = [QMUITheme textColorLevel4];
        _unitLabel.text = [NSString stringWithFormat:@"%@：%@", [YXLanguageUtility kLangWithKey:@"newStock_detail_stock_unit"], [YXLanguageUtility kLangWithKey:@"common_billion"]];
    }
    
    return  _unitLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        _titleLabel.textColor = [QMUITheme textColorLevel1];
        _titleLabel.text = [YXLanguageUtility kLangWithKey:@"bubear_captial_flow"];
    }
    
    return  _titleLabel;
}

- (UILabel *)dateLabel1 {
    if (!_dateLabel1) {
        _dateLabel1 = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightMedium]];
    }
    
    return _dateLabel1;
}

- (UILabel *)dateLabel2 {
    if (!_dateLabel2) {
        _dateLabel2 = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightMedium]];
    }
    
    return _dateLabel2;
}

- (UILabel *)dateLabel3 {
    if (!_dateLabel3) {
        _dateLabel3 = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightMedium]];
    }
    
    return _dateLabel3;
}

@end
