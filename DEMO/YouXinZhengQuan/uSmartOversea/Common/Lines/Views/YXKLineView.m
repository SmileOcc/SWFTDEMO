//
//  YXKLineView.m
//  YXKlineDemo
//
//  Created by rrd on 2018/8/30.
//  Copyright © 2018年 RRD. All rights reserved.
//

#import "YXKLineView.h"
#import "YXKLineUtility.h"
#import "YXStockConfig.h"
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
#import "YXKlineAccessoryShadeView.h"

#ifdef IsHKApp

#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "YXKLineConfigManager.h"
#import "UILabel+create.h"
#import "YYCategoriesMacro.h"

#else

#import "YXRTLineModel.h"
#endif

//副参数行高
#define K_SubAccessoryHeight 40.0
//副参数组之间的距离
#define K_SubAccessorySpace 20.0

@interface YXKLineView () <UIScrollViewDelegate>

//绘制k线图在scrollView上
@property (nonatomic, strong) UIScrollView *scrollView;
//layer生成器
@property (nonatomic, strong) YXLayerGenerator *generator;
//title生成器
@property (nonatomic, strong) YXAccessoryTitleGenerator *titleGenerator;

@property (nonatomic, assign) BOOL firstLoad;                               //是否第一次加载数据
@property (nonatomic, assign) double candleWidth;                          //蜡烛宽度 (单个蜡烛的宽度)
@property (nonatomic, assign) CGRect candleRect;                            //整体蜡烛图显示区域 (width + height * 0.65)
@property (nonatomic, assign) CGRect volumeRect;                            //整体成交量显示区域 (width + HEIGHT - height * 0.65 - 20)
@property (nonatomic, assign) double currentScale;                         //当前缩放级别
@property (nonatomic, assign) double touchCenterX;                         //缩放触摸俩点中间x坐标(方便计算偏移量的)
@property (nonatomic, assign) double centerXdistanceFromLeft;              //缩放触摸点距离可见区域距离
@property (nonatomic, assign) NSInteger touchCenterIndex;                   //缩放触摸点最近的索引
@property (nonatomic, assign) NSInteger totoalCount;                        //总数据个数
@property (nonatomic, assign) BOOL isLoadMore;

@property (nonatomic, assign) NSInteger location; //起点位置

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;  //长按手势
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;  //缩放手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer; //轻击手势
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer; //双击手势

@property (nonatomic, assign) double lastDrawRectY; //参数绘图区域

@property (nonatomic, strong) NSMutableArray *monthArr; //月份数组(重复的标记的是"")
@property (nonatomic, strong) NSMutableArray *dateLabelArr; //日期数组

@property (nonatomic, assign) double priceBaseFullValue; //底除数

@property (nonatomic, assign) double maxHigh;
@property (nonatomic, assign) double minLow;

// 副指标的最大最小值
@property (nonatomic, assign) double subMaxHigh;
@property (nonatomic, assign) double subMinLow;

@property (nonatomic, assign) NSInteger longPressLocationIndex; //长按所在位置

@property (nonatomic, assign) BOOL isDraging;
@property (nonatomic, assign) BOOL isLoadingData;
@property (nonatomic, assign) BOOL needLoadMore;
@property (nonatomic, assign) NSInteger preListCount;

@property (nonatomic, assign) BOOL isReset;

@property (nonatomic, assign) NSTimeInterval firstKLineTime;

@property (nonatomic, strong, nonnull) YXStockLineMenuView *menuView;

@property (nonatomic, strong, nonnull) YXStockLineMenuView *subMenuView;

@property (nonatomic, strong) YXStockPopover *popover;

@property (nonatomic, assign) BOOL isLandscape;

@property (nonatomic, strong) CALayer *mainLayer;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, assign) BOOL isLongPressLatest;

@property (nonatomic, strong) YXKLineSecondaryView *secondaryARBRView;
@property (nonatomic, strong) YXKLineSecondaryView *secondaryDMAView;
@property (nonatomic, strong) YXKLineSecondaryView *secondaryMACDView;
@property (nonatomic, strong) YXKLineSecondaryView *secondaryKDJView;
@property (nonatomic, strong) YXKLineSecondaryView *secondaryMAVOLView;
@property (nonatomic, strong) YXKLineSecondaryView *secondaryRSIView;
@property (nonatomic, strong) YXKLineSecondaryView *secondaryEMVView;
@property (nonatomic, strong) YXKLineSecondaryView *secondaryWRView;
@property (nonatomic, strong) YXKLineSecondaryView *secondaryCRView;

@property (nonatomic, strong) NSArray<YXKLineSecondaryView *> *secondaryViews;

@property (nonatomic, assign, readwrite) CGFloat defaultHeight;

@property (nonatomic, assign, readwrite) CGFloat secondaryViewHeight;

@property (nonatomic, strong) NSArray<YXKLineOrderLayer *> *orderLayerArray;

//产看分时按钮
@property (nonatomic, strong) YXExpandAreaButton *queryQuoteButton;
@property (nonatomic, assign) BOOL showQuoteDetail;
@property (nonatomic, assign) CGPoint lastLongPressPoint;
@property (nonatomic, assign) CGFloat longPressXOffsetToScreen;
@property (nonatomic, assign) NSTimeInterval refreshTime;

@property (nonatomic, assign) CGFloat externWidth; //图标最右边空出的间距，方便蜡烛图 及 买卖点显示
@property (nonatomic, assign) CGFloat topFixMargin;

@property (nonatomic, strong) NSMutableArray <UILabel *>*buyLabels;
@property (nonatomic, strong) NSMutableArray <UILabel *>*sellLabels;
@property (nonatomic, strong) YXKlineAccessoryShadeView *shadeView;
@property (nonatomic, strong) QMUIButton *usmartDetailBtn;

@end

@implementation YXKLineView

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

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
    self.currentScale = 0.01;

    self.externWidth = 7.0;
    self.topFixMargin = 22;
    //添加scrollView, 设置绘图区域 & 参数绘图区域
    [self addSubview:self.scrollView];
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.candleRect = CGRectMake(0, self.topFixMargin, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * 0.60);

    //记录高度
    self.defaultHeight = self.frame.size.height;
    self.secondaryViewHeight = CGRectGetHeight(self.frame) - CGRectGetMaxY(self.candleRect);
    CGFloat defaultCandleMaxY = CGRectGetMaxY(self.candleRect);
    if (YXKLineConfigManager.shareInstance.subAccessoryArray.count == 0) {
        self.candleRect = CGRectMake(0, self.topFixMargin, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - kSecondaryTopFixMargin);
    }

    self.orderLayerArray = @[];

    //蜡烛宽度
    self.candleWidth = 4.1;
    self.space = self.candleWidth * 0.5;

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
    [self.mainLayer addSublayer:self.generator.greenLineLayer];
    [self.mainLayer addSublayer:self.generator.redLineLayer];
    [self.mainLayer addSublayer:self.generator.timePriceLineLayer];

    //ma线
    [self.mainLayer addSublayer:self.generator.ma5Layer];
    [self.mainLayer addSublayer:self.generator.ma20Layer];
    [self.mainLayer addSublayer:self.generator.ma60Layer];
    [self.mainLayer addSublayer:self.generator.ma120Layer];
    [self.mainLayer addSublayer:self.generator.ma250Layer];
    
    //usmart线
    [self.mainLayer addSublayer:self.generator.usmartUp_layer];
    [self.mainLayer addSublayer:self.generator.usmartDown_layer];
    [self.mainLayer addSublayer:self.generator.usmartBuy_layer];
    [self.mainLayer addSublayer:self.generator.usmartSell_layer];
    
    //ema线
    [self.mainLayer addSublayer:self.generator.ema5Layer];
    [self.mainLayer addSublayer:self.generator.ema20Layer];
    [self.mainLayer addSublayer:self.generator.ema60Layer];

    //boll
    [self.mainLayer addSublayer:self.generator.boll_MBLayer];
    [self.mainLayer addSublayer:self.generator.boll_DNLayer];
    [self.mainLayer addSublayer:self.generator.boll_UPLayer];

    //sar圆线
    [self.mainLayer addSublayer:self.generator.sar_redLayer];
    [self.mainLayer addSublayer:self.generator.sar_greenLayer];
    [self.mainLayer addSublayer:self.generator.sar_grayLayer];


    //最高点和最低点
    [self.mainLayer addSublayer:self.generator.maxPriceLayer];
    [self.mainLayer addSublayer:self.generator.minPriceLayer];
    [self.mainLayer addSublayer:self.generator.upArrowLayer];
    [self.mainLayer addSublayer:self.generator.downArrowLayer];
    // 现价线
    [self.layer addSublayer:self.generator.nowPrice_Layer];
    //持仓持本线
    [self.layer addSublayer:self.generator.holdPrice_Layer];

    [self.layer addSublayer:self.generator.crossLineLayer];
    self.generator.crossLineLayer.hidden = YES;

    //手势事件
    [self addGestureRecognizer:self.longPressGestureRecognizer];
    [self addGestureRecognizer:self.pinchGestureRecognizer];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    if (self.isLandscape) {
        [self addGestureRecognizer:self.doubleTapGestureRecognizer];
        [self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
    }

    //网格线
    [self.layer addSublayer:self.generator.horizonLayer];
    [self.layer addSublayer:self.generator.verticalLayer];

    // 副指标
    UIView *preview = nil;
    for (NSNumber *subTypeNumber in YXKLineConfigManager.shareInstance.subArr) {
        YXKLineSecondaryView *secondaryView = [[YXKLineSecondaryView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.candleRect), self.frame.size.width, self.secondaryViewHeight) subStatus:subTypeNumber.intValue titleGenerator:self.titleGenerator layerGenerator:self.generator];
        [self addSubview:secondaryView];
        secondaryView.hidden = YES;
        [secondaryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(0);
            if (preview == nil) {
                make.top.equalTo(self).offset(defaultCandleMaxY);
            } else {
                make.top.equalTo(preview.mas_bottom);
            }
        }];
        preview = secondaryView;

        switch (subTypeNumber.intValue) {
            case YXStockSubAccessoryStatus_MAVOL:
                self.secondaryMAVOLView = secondaryView;
                break;

            case YXStockSubAccessoryStatus_MACD:
                self.secondaryMACDView = secondaryView;
                break;
            case YXStockSubAccessoryStatus_KDJ:
                self.secondaryKDJView = secondaryView;
                break;

            case YXStockSubAccessoryStatus_RSI:
                self.secondaryRSIView = secondaryView;
                break;
            case YXStockSubAccessoryStatus_DMA:
                self.secondaryDMAView = secondaryView;
                break;
            case YXStockSubAccessoryStatus_ARBR:
                self.secondaryARBRView = secondaryView;
                break;
            case YXStockSubAccessoryStatus_WR:
                self.secondaryWRView = secondaryView;
                break;
            case YXStockSubAccessoryStatus_EMV:
                self.secondaryEMVView = secondaryView;
                break;
            case YXStockSubAccessoryStatus_CR:
                self.secondaryCRView = secondaryView;
                break;
            default:
                break;
        }

    }
    self.secondaryViews =  @[self.secondaryARBRView,
                             self.secondaryDMAView,
                             self.secondaryMACDView,
                             self.secondaryKDJView,
                             self.secondaryMAVOLView,
                             self.secondaryRSIView,
                             self.secondaryEMVView,
                             self.secondaryWRView,
                             self.secondaryCRView];
    self.volumeRect = CGRectMake(0, 0, CGRectGetWidth(self.frame), self.secondaryViewHeight - kSecondaryTopFixMargin);


    //最高/最低价格title
    [self addSubview:self.titleGenerator.kLineMaxPriceLabel];
    [self addSubview:self.titleGenerator.kLineMinPriceLabel];
    [self addSubview:self.titleGenerator.pclosePriceLabel];
    [self addSubview:self.titleGenerator.kLineSecondMaxPriceLabel];
    [self addSubview:self.titleGenerator.kLineSecondMinPriceLabel];

    [self adjustPirceLabelFrame];
    
    [self addSubview:self.usmartDetailBtn];
    [self.usmartDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.height.mas_equalTo(self.topFixMargin);
        make.right.equalTo(self).offset(0);
        make.width.mas_equalTo(35);
    }];

    //添加主参数(MA, EMA, SAR, BOLL, SAR) title
    [self addSubview:self.titleGenerator.MALabel];
    [self addSubview:self.titleGenerator.EMALabel];
    [self addSubview:self.titleGenerator.SARLabel];
    [self addSubview:self.titleGenerator.BOLLLabel];
    [self addSubview:self.titleGenerator.usmartLabel];

    self.titleGenerator.MALabel.hidden = YES;
    self.titleGenerator.EMALabel.hidden = YES;
    self.titleGenerator.SARLabel.hidden = YES;
    self.titleGenerator.BOLLLabel.hidden = YES;
    self.titleGenerator.usmartLabel.hidden = YES;
    
    NSArray<UILabel *> *labelArray = @[self.titleGenerator.MALabel,
                                       self.titleGenerator.EMALabel,
                                       self.titleGenerator.SARLabel,
                                       self.titleGenerator.BOLLLabel,
                                        self.titleGenerator.usmartLabel];
    NSArray *mainTypeArray = @[@(YXStockMainAcessoryStatusMA),
                               @(YXStockMainAcessoryStatusEMA),
                               @(YXStockMainAcessoryStatusSAR),
                               @(YXStockMainAcessoryStatusBOLL),
                               @(YXStockMainAcessoryStatusUsmart),];
    NSInteger index = 0;
    for (UIView *label in labelArray) {
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.height.mas_equalTo(self.topFixMargin);
            if (label == self.titleGenerator.usmartLabel) {
                make.right.equalTo(self.usmartDetailBtn.mas_left).offset(-2);
            } else {
                make.right.equalTo(self);
            }
        }];

        if (!self.isLandscape) {
            [[YXKLineConfigManager shareInstance] addExplainInfo:label type:[mainTypeArray[index] integerValue]];
        }
        index ++;
    }

    //起始和结束月份, 当前日期, 横线对应价格
    [self addSubview:self.titleGenerator.startDateLabel];
    [self addSubview:self.titleGenerator.endDateLabel];
    [self addSubview:self.titleGenerator.currentDateLabel];
    [self addSubview:self.titleGenerator.crossingLinePriceLabel];
    self.titleGenerator.currentDateLabel.hidden = YES;
    self.titleGenerator.crossingLinePriceLabel.hidden = YES;
    
    self.titleGenerator.currentDateLabel.backgroundColor = QMUITheme.longPressBgColor;
    self.titleGenerator.currentDateLabel.textColor = QMUITheme.longPressTextColor;
    
    self.titleGenerator.crossingLinePriceLabel.backgroundColor = QMUITheme.longPressBgColor;
    self.titleGenerator.crossingLinePriceLabel.textColor =QMUITheme.longPressTextColor;

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

    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];

    [self drawCrossingLayer];
    
    [self addSubview:self.shadeView];
    self.shadeView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.candleRect) + self.topFixMargin);
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


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if (object == self.scrollView) {
        if (self.scrollView.contentSize.width < self.frame.size.width) {
            self.mainLayer.frame = CGRectMake(0, self.topFixMargin, self.frame.size.width, CGRectGetHeight(self.candleRect));
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width, CGRectGetHeight(self.candleRect))];
            self.maskLayer.path = maskPath.CGPath;
        } else {
            self.mainLayer.frame = CGRectMake(0, self.topFixMargin, self.scrollView.contentSize.width, CGRectGetHeight(self.candleRect));
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.scrollView.contentSize.width, CGRectGetHeight(self.candleRect))];
            self.maskLayer.path = maskPath.CGPath;
        }
        [self resetSecondaryViewFrame];
    }
}

- (void)resetSecondaryViewFrame {

    for (YXKLineSecondaryView *view in self.secondaryViews) {
        if (view.hidden == NO) {
            view.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.secondaryViewHeight - kSecondaryTopFixMargin);
        }
    }

}

//初始化基础数据
- (void)configureBaseDatas {

    double contentWidth = self.klineModel.list.count >= 1 ?  (self.candleWidth + self.space) * (self.klineModel.list.count - 1) + self.candleWidth : 0;
    self.scrollView.contentSize = CGSizeMake(contentWidth + self.externWidth, self.scrollView.frame.size.height);
    //月份
    NSArray *visibleArr = [self getVisibleArr];
    if (visibleArr.count > 0) {
        YXKLine *startModel = visibleArr.firstObject;
        YXKLine *endModel = visibleArr.lastObject;
        self.titleGenerator.startDateLabel.text = [YXDateHelper commonDateStringWithNumber:startModel.latestTime.value format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:NO];
        self.titleGenerator.endDateLabel.text = [YXDateHelper commonDateStringWithNumber:endModel.latestTime.value format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:NO];
    }
}

- (void)reload{

    //初始化参数
    [self configureBaseDatas];
    //画线
    [self drawAllLayers];

}

- (void)resetSetting {
    self.isReset = YES;
}


- (void)setFrame:(CGRect)frame {
    CGFloat originWidth = self.frame.size.width;
    [super setFrame:frame];
    CGFloat currentWidth = frame.size.width;
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.candleRect = CGRectMake(0, self.topFixMargin, CGRectGetWidth(self.frame), self.defaultHeight * 0.60);
    self.volumeRect = CGRectMake(0, 0, CGRectGetWidth(self.frame), self.secondaryViewHeight - kSecondaryTopFixMargin);
    if (self.isLandscape && YXKLineConfigManager.shareInstance.subAccessoryArray.count == 0) {
        self.candleRect = CGRectMake(0, self.topFixMargin, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - kSecondaryTopFixMargin);
    }
    self.mainLayer.frame = CGRectMake(0, self.topFixMargin, CGRectGetWidth(self.frame), CGRectGetHeight(self.candleRect));
    self.maskLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.candleRect));
    if (currentWidth < originWidth) { //改变frame时要同步 scrollView的contentOffset, 否则不对应
        CGFloat offset = originWidth - currentWidth;
        if (self.scrollView.contentOffset.x < offset) {
            offset = self.scrollView.contentOffset.x;
        }
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + offset, self.scrollView.contentOffset.y)];
        for (YXKLineSecondaryView *view in self.secondaryViews) {
            if (view.hidden == NO) {
                [view.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + offset, 0)];
            }
        }
    }

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


// 重置k线图表选择的顺序
- (void)resetKLineSettingSore {
    _menuView = nil;
    _subMenuView = nil;
}

#pragma mark - 绘制图形
/**
 绘制所有layer
 */
- (void)drawAllLayers{

    //获取当前区域的最大最小值
    //绘制主参数图
    self.mainAccessoryStatus = _mainAccessoryStatus;

    //绘制副参数图
    [self drawAllSecondaryView];
}

/**
 绘制蜡烛图
 */
- (void)drawKLineLayer {

    NSArray<YXKLine *> *visibleArray = [self getVisibleArr];
    if (visibleArray.count <= 0) {
        return;
    }
    
    if (self.lastDayChangeCallBack) {
        self.lastDayChangeCallBack(visibleArray.lastObject.latestTime.value);
    }
    
    //当前区域的最高值
    //最右边的那个点在区域内的时候, 算入最高/最低, 但是不算第0个; 不在的话, 不算入最右边的那个点, 但是算入第一个点....

//    double maxHigh = [[visibleArray valueForKeyPath:@"@max.high.doubleValue"] doubleValue] / self.priceBaseFullValue;
//    //当前区域的最低值
//    double minLow = [[visibleArray valueForKeyPath:@"@min.low.doubleValue"] doubleValue] / self.priceBaseFullValue;
      
    //价格的最大值
    double maxHigh = visibleArray.firstObject.high.value;
    //价格的最低值
    double minLow = visibleArray.firstObject.low.value;
    
    for (YXKLine *model in visibleArray) {
        if (maxHigh < model.high.value) {
            maxHigh = model.high.value;
        }
        
        if (minLow > model.low.value) {
            minLow = model.low.value;
        }
    }
    maxHigh = maxHigh / self.priceBaseFullValue;
    minLow = minLow / self.priceBaseFullValue;

    if (self.mainAccessoryStatus == YXStockMainAcessoryStatusNone) {
        self.maxHigh = maxHigh;
        self.minLow = minLow;
        self.maxHigh = self.maxHigh + (self.maxHigh - self.minLow) * 0.05;
        self.minLow = self.minLow - (self.maxHigh - self.minLow) * 0.05;
    }

    double candleDistance = CGRectGetHeight(self.candleRect) * 1;
    double zeroY = CGRectGetMaxY(self.candleRect) - CGRectGetHeight(self.candleRect) * 0;
    zeroY = CGRectGetHeight(self.candleRect);
    UIBezierPath *greenLinePath = [UIBezierPath bezierPath];
    UIBezierPath *redLinePath = [UIBezierPath bezierPath];
    UIBezierPath *closePath = [UIBezierPath bezierPath];
    BOOL isSimpleLine = (self.candleWidth <= 1);

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;

        double open = obj.open.value / self.priceBaseFullValue;
        if (open > self.maxHigh) {
            open = self.maxHigh;
        } else if (open < self.minLow) {
            open = self.minLow;
        }

        double close = obj.close.value / self.priceBaseFullValue;
        if (close > self.maxHigh) {
            close = self.maxHigh;
        } else if (close < self.minLow) {
            close = self.minLow;
        }

        double openY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:open distance:candleDistance zeroY:zeroY];
        double closeY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:close distance:candleDistance zeroY:zeroY];

        double high = obj.high.value / self.priceBaseFullValue;
        if (high < open || high < close) {
            high = MAX(open, close);
        }

        double low = obj.low.value / self.priceBaseFullValue;
        if (low > open || low > close) {
            low = MIN(open, close);
        }
        double highY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:high distance:candleDistance zeroY:zeroY];
        double lowY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:low distance:candleDistance zeroY:zeroY];


        //存位置坐标
        obj.closePoint = [[NumberDouble alloc] init:x];

        if (isSimpleLine) {
            if (idx == 0) {
                [closePath moveToPoint:CGPointMake(x, closeY)];
            } else {
                [closePath addLineToPoint:CGPointMake(x, closeY)];
            }
            return ;
        }

        if (maxHigh == obj.high.value / self.priceBaseFullValue) {  //当前区域最高价的指示标

            CGRect frame = CGRectZero;
            NSString *text;
            if (_klineModel.priceBase.value == 3) {
                text = [NSString stringWithFormat:@"%.3f",obj.high.value / self.priceBaseFullValue];
            } else {
                text = [NSString stringWithFormat:@"%.2f",obj.high.value / self.priceBaseFullValue];
            }

            double textWidth = [text widthForFont:[UIFont systemFontOfSize:8]];
            UIBezierPath *highArrowPath;

            if (x - self.scrollView.contentOffset.x >= CGRectGetWidth(self.scrollView.frame) / 2) {
                frame = CGRectMake(x-30-textWidth, highY-5, textWidth, 10);
                highArrowPath = [YXKLineUtility getArrowPathWithOriginPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame)) targetPoint:CGPointMake(x, CGRectGetMidY(frame)) upPoint:CGPointMake(x-2, CGRectGetMidY(frame)+2) downPoint:CGPointMake(x-2, CGRectGetMidY(frame)-2)];

            } else {
                frame = CGRectMake(x+30, highY-5, textWidth, 10);
                CGRect temp = [self.scrollView convertRect:frame toView:self];
                CGFloat maxPriceY = CGRectGetMinY(self.titleGenerator.kLineMaxPriceLabel.frame);
                if (temp.origin.x < 45) {
                    if (frame.origin.y <= maxPriceY + 8 && frame.origin.y > maxPriceY) {
                        frame.origin.y = maxPriceY;
                    } else if (frame.origin.y < (maxPriceY + 16) && frame.origin.y >= (maxPriceY + 8)) {
                        frame.origin.y = (maxPriceY + 16);
                    }
                }
                highArrowPath = [YXKLineUtility getArrowPathWithOriginPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame)) targetPoint:CGPointMake(x, CGRectGetMidY(frame)) upPoint:CGPointMake(x+2, CGRectGetMidY(frame)+2) downPoint:CGPointMake(x+2, CGRectGetMidY(frame)-2)];
            }

            //关闭隐士动画
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.generator.maxPriceLayer.frame = frame;
            [CATransaction commit];

            self.generator.maxPriceLayer.string = text;
            self.generator.upArrowLayer.path = highArrowPath.CGPath;
        }


        if (minLow == obj.low.value / self.priceBaseFullValue) { //当前区域最低价指示标

            CGRect frame = CGRectZero;
            NSString *text;
            if (_klineModel.priceBase.value == 3) {
                text = [NSString stringWithFormat:@"%.3f",obj.low.value / self.priceBaseFullValue];
            } else {
                text = [NSString stringWithFormat:@"%.2f",obj.low.value / self.priceBaseFullValue];
            }
            double textWidth = [text widthForFont:[UIFont systemFontOfSize:8]];
            UIBezierPath *lowArrowPath;

            if (x - self.scrollView.contentOffset.x >= CGRectGetWidth(self.scrollView.frame) / 2) {
                frame = CGRectMake(x- 30 -textWidth, lowY - 3, textWidth, 10);
                lowArrowPath = [YXKLineUtility getArrowPathWithOriginPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame) - CGRectGetHeight(self.candleRect) * 0) targetPoint:CGPointMake(x, CGRectGetMidY(frame) - CGRectGetHeight(self.candleRect) * 0) upPoint:CGPointMake(x - 2, CGRectGetMidY(frame) - CGRectGetHeight(self.candleRect) * 0 + 2) downPoint:CGPointMake(x - 2, CGRectGetMidY(frame)- CGRectGetHeight(self.candleRect) * 0 - 2)];

            } else {
                frame = CGRectMake(x + 30, lowY - 3, textWidth, 10);
                CGRect temp = [self.scrollView convertRect:frame toView:self];
                CGFloat minPriceY = CGRectGetMinY(self.titleGenerator.kLineMinPriceLabel.frame) + 7;

                if (temp.origin.x < 45) {
                    if (frame.origin.y <= (minPriceY + 8) && frame.origin.y > minPriceY) {
                        frame.origin.y = minPriceY;
                    } else if (frame.origin.y < (minPriceY + 16) && frame.origin.y >= (minPriceY + 8)) {
                        frame.origin.y = minPriceY + 16;
                    }
                }

                lowArrowPath = [YXKLineUtility getArrowPathWithOriginPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame)- CGRectGetHeight(self.candleRect) * 0) targetPoint:CGPointMake(x, CGRectGetMidY(frame) - CGRectGetHeight(self.candleRect) * 0) upPoint:CGPointMake(x + 2, CGRectGetMidY(frame) - CGRectGetHeight(self.candleRect) * 0 + 2) downPoint:CGPointMake(x + 2, CGRectGetMidY(frame)- CGRectGetHeight(self.candleRect) * 0 - 2)];
            }

            [lowArrowPath closePath];
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.generator.minPriceLayer.frame = CGRectMake(frame.origin.x, frame.origin.y - CGRectGetHeight(self.candleRect) * 0, frame.size.width, frame.size.height);
            [CATransaction commit];

            self.generator.minPriceLayer.string = text;
            self.generator.downArrowLayer.path = lowArrowPath.CGPath;
        }

        if ([self.generator.minPriceLayer.string isEqualToString:self.generator.maxPriceLayer.string]) {
            self.generator.minPriceLayer.hidden = YES;
            self.generator.downArrowLayer.hidden = YES;
        } else {
            self.generator.minPriceLayer.hidden = NO;
            self.generator.downArrowLayer.hidden = NO;
        }

        if (obj.open.value / self.priceBaseFullValue > obj.close.value / self.priceBaseFullValue) {  //阴线(开盘 > 收盘) -- 绿色

            //蜡烛的path
            //path里面包含了蜡烛以及上下的线
            UIBezierPath *path = [YXKLineUtility getCandlePathWithCandleWidth:self.candleWidth xCooordinate:x openY:openY closeY:closeY highY:highY lowY:lowY];
            [greenLinePath appendPath:path];
        } else if (obj.open.value / self.priceBaseFullValue < obj.close.value / self.priceBaseFullValue) {   //阳线(开盘 < 收盘) - 阳线
            UIBezierPath *path = [YXKLineUtility getCandlePathWithCandleWidth:self.candleWidth xCooordinate:x openY:openY closeY:closeY highY:highY lowY:lowY];
            [redLinePath appendPath:path];
        } else {
            //开盘 == 收盘
            if (idx == 0) {
                UIBezierPath *path = [YXKLineUtility getCandlePathWithCandleWidth:self.candleWidth xCooordinate:x openY:openY closeY:closeY highY:highY lowY:lowY];
                [redLinePath appendPath:path];

            } else {
                YXKLine * preObj = visibleArray[idx - 1];
                if (obj.close.value >= preObj.close.value) {
                    UIBezierPath *path = [YXKLineUtility getCandlePathWithCandleWidth:self.candleWidth xCooordinate:x openY:openY closeY:closeY highY:highY lowY:lowY];
                    [redLinePath appendPath:path];
                } else {
                    UIBezierPath *path = [YXKLineUtility getCandlePathWithCandleWidth:self.candleWidth xCooordinate:x openY:openY closeY:closeY highY:highY lowY:lowY];
                    [greenLinePath appendPath:path];
                }
            }

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
                [self.mainLayer addSublayer:orderlayer];
                if (orderEvent.bought.count > 0 && orderEvent.sold.count > 0) {
                    orderlayer.orderDirection = YXKLineOrderDirectionBoth;
                } else if (orderEvent.bought.count > 0) {
                    orderlayer.orderDirection = YXKLineOrderDirectionBuy;
                } else {
                    orderlayer.orderDirection = YXKLineOrderDirectionSell;
                }

                orderlayer.position = CGPointMake(x, highY - 8);
            }
        }
        
        //添加买卖点，公司财报， 分红
        [self addEventPoint:obj centerX:x highY:highY zeroY:zeroY];

    }];

    // 现价线
    YXKLine *model = self.klineModel.list.lastObject;
    double nowPrice = model.close.value / self.priceBaseFullValue;
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

    if (isSimpleLine) {
        self.generator.downArrowLayer.path = nil;
        self.generator.upArrowLayer.path = nil;
        self.generator.downArrowLayer.hidden = YES;
        self.generator.upArrowLayer.hidden = YES;
        self.generator.minPriceLayer.string = @"";
        self.generator.maxPriceLayer.string = @"";

        self.generator.greenLineLayer.path = nil;
        self.generator.redLineLayer.path = nil;
        self.generator.greenLineLayer.hidden = YES;
        self.generator.redLineLayer.hidden = YES;

        self.generator.timePriceLineLayer.hidden = NO;
        self.generator.timePriceLineLayer.path = closePath.CGPath;
    } else {
        self.generator.downArrowLayer.hidden = NO;
        self.generator.upArrowLayer.hidden = NO;
        self.generator.greenLineLayer.hidden = NO;
        self.generator.redLineLayer.hidden = NO;

        if (YXKLineConfigManager.shareInstance.styleType == YXKlineStyleTypeHollow) {
            self.generator.redLineLayer.fillColor = UIColor.clearColor.CGColor;
        } else {
            self.generator.redLineLayer.fillColor = YX_RED_COLOR.CGColor;
        }
        self.generator.greenLineLayer.path = greenLinePath.CGPath;
        self.generator.redLineLayer.path = redLinePath.CGPath;

        self.generator.timePriceLineLayer.hidden = YES;
        self.generator.timePriceLineLayer.path = nil;
    }

    double pClose = (self.maxHigh + self.minLow) * 0.5;
    if ([self.klineModel.ID.market isEqualToString:kYXMarketCryptos]) {
        if (self.decimalCount == 0) {
            self.decimalCount = 2;
        }
        NSString *deciPointFormat = [NSString stringWithFormat:@"%%.%ldf", (long)self.decimalCount];
        self.titleGenerator.kLineMaxPriceLabel.text = [NSString stringWithFormat:deciPointFormat, self.maxHigh];
        self.titleGenerator.kLineMinPriceLabel.text = [NSString stringWithFormat:deciPointFormat, self.minLow];
        self.titleGenerator.pclosePriceLabel.text = [NSString stringWithFormat:deciPointFormat, pClose];
        self.titleGenerator.kLineSecondMaxPriceLabel.text = [NSString stringWithFormat:deciPointFormat, self.minLow + (self.maxHigh - self.minLow) * 0.75];
        self.titleGenerator.kLineSecondMinPriceLabel.text = [NSString stringWithFormat:deciPointFormat, self.minLow + (self.maxHigh - self.minLow) * 0.25];
    } else if (_klineModel.priceBase.value == 3) {
        self.titleGenerator.kLineMaxPriceLabel.text = [NSString stringWithFormat:@"%.3lf", self.maxHigh];
        self.titleGenerator.kLineMinPriceLabel.text = [NSString stringWithFormat:@"%.3lf", self.minLow];
        self.titleGenerator.pclosePriceLabel.text = [NSString stringWithFormat:@"%.3f", pClose];
        self.titleGenerator.kLineSecondMaxPriceLabel.text = [NSString stringWithFormat:@"%.3f", self.minLow + (self.maxHigh - self.minLow) * 0.75];
        self.titleGenerator.kLineSecondMinPriceLabel.text = [NSString stringWithFormat:@"%.3f", self.minLow + (self.maxHigh - self.minLow) * 0.25];
    } else {
        self.titleGenerator.kLineMaxPriceLabel.text = [NSString stringWithFormat:@"%.2lf", self.maxHigh];
        self.titleGenerator.kLineMinPriceLabel.text = [NSString stringWithFormat:@"%.2lf", self.minLow];
        self.titleGenerator.pclosePriceLabel.text = [NSString stringWithFormat:@"%.2f", pClose];
        self.titleGenerator.kLineSecondMaxPriceLabel.text = [NSString stringWithFormat:@"%.2f", self.minLow + (self.maxHigh - self.minLow) * 0.75];
        self.titleGenerator.kLineSecondMinPriceLabel.text = [NSString stringWithFormat:@"%.2f", self.minLow + (self.maxHigh - self.minLow) * 0.25];
    }

    //日期
    YXKLine *startModel = visibleArray.firstObject;
    YXKLine *endModel = visibleArray.lastObject;
    self.titleGenerator.startDateLabel.text = [YXDateHelper commonDateStringWithNumber:startModel.latestTime.value format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:NO];
    self.titleGenerator.endDateLabel.text = [YXDateHelper commonDateStringWithNumber:endModel.latestTime.value format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:NO];
}


- (void)addEventPoint:(YXKLine *)obj centerX:(CGFloat)x highY:(CGFloat)highY zeroY:(CGFloat)zeroY {
    if ([YXKLineConfigManager shareInstance].showBuySellPoint || [YXKLineConfigManager shareInstance].showCompanyActionPoint) {
        YXKLineInsideEvent *orderEvent = nil;
        YXKLineInsideEvent *dividendsEvent = nil;
        YXKLineInsideEvent *financialEvent = nil;
        if (obj.klineEvents.count > 0) {
            for (YXKLineInsideEvent *event in obj.klineEvents) {
                if ([YXKLineConfigManager shareInstance].showBuySellPoint && event.type.value == 0 && (event.bought.count > 0 || event.sold.count > 0)) {
                    orderEvent = event;
                } else if ([YXKLineConfigManager shareInstance].showCompanyActionPoint && event.type.value == 1 && event.context.length > 0) {
                    financialEvent = event;
                } else if ([YXKLineConfigManager shareInstance].showCompanyActionPoint && event.type.value == 2 && event.context.length > 0) {
                    dividendsEvent = event;
                }
            }
        }

        if (orderEvent) { //买卖点
            YXKLineOrderLayer *orderlayer = [self createOrderLayer];
            [self.mainLayer addSublayer:orderlayer];
            if (orderEvent.bought.count > 0 && orderEvent.sold.count > 0) {
                orderlayer.orderDirection = YXKLineOrderDirectionBoth;
            } else if (orderEvent.bought.count > 0) {
                orderlayer.orderDirection = YXKLineOrderDirectionBuy;
            } else {
                orderlayer.orderDirection = YXKLineOrderDirectionSell;
            }

            orderlayer.position = CGPointMake(x, highY - 8);
        }

        if (dividendsEvent || financialEvent) {
            YXKLineCompanyActionStyle style = YXKLineCompanyActionStyleFinancial;
            if (dividendsEvent && financialEvent) { //同时存在财报 和 分红信息
                style = YXKLineCompanyActionStyleBoth;
            } else if (financialEvent) { //财报
                style = YXKLineCompanyActionStyleFinancial;
            } else { //分红
                style = YXKLineCompanyActionStyleDividend;
            }

            YXKLineCompanyActionLayer *layer = [self createCompanyActionLayer:style];
            [self.mainLayer addSublayer:layer];
            layer.position = CGPointMake(x, zeroY - 5);
        }
    }
}



#pragma mark - 指标参数图: 主指标图(MA, BOLL, EMA, SAR)
/**
 MA
 */
- (void)drawMALayer{

    NSArray *visibleArray =  [self getVisibleArr];

    //获取当前区域的最大最小值
    [self getMaxAndMinHigh];

    //当前区域的高度
    double candleDistance = CGRectGetHeight(self.candleRect) * 1;
    double zeroY = CGRectGetMaxY(self.candleRect) - CGRectGetHeight(self.candleRect) * 0;
    zeroY = CGRectGetHeight(self.candleRect);
    UIBezierPath *ma5Path = [UIBezierPath bezierPath];
    UIBezierPath *ma20Path = [UIBezierPath bezierPath];
    UIBezierPath *ma60Path = [UIBezierPath bezierPath];
    UIBezierPath *ma120Path = [UIBezierPath bezierPath];
    UIBezierPath *ma250Path = [UIBezierPath bezierPath];

    __block BOOL ma5First = YES;
    __block BOOL ma20First = YES;
    __block BOOL ma60First = YES;
    __block BOOL ma120First = YES;
    __block BOOL ma250First = YES;

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //计算蜡烛各个指标 的 x，y
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;
        if (obj.ma5.value != 0 && ![YXKLineConfigManager shareInstance].ma.ma_5_isHidden) {

            double ma5Y = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.ma5.value distance:candleDistance zeroY:zeroY];
            if (ma5First == YES) {
                [ma5Path moveToPoint:CGPointMake(x, ma5Y)];
                ma5First = NO;
            } else {
                [ma5Path addLineToPoint:CGPointMake(x, ma5Y)];
            }

        }

        if (obj.ma20.value != 0 && ![YXKLineConfigManager shareInstance].ma.ma_20_isHidden) {

            double ma20Y = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.ma20.value distance:candleDistance zeroY:zeroY];
            if (ma20First == YES) {
                [ma20Path moveToPoint:CGPointMake(x, ma20Y)];
                ma20First = NO;
            } else {
                [ma20Path addLineToPoint:CGPointMake(x, ma20Y)];
            }
        }

        if (obj.ma60.value != 0 && ![YXKLineConfigManager shareInstance].ma.ma_60_isHidden) {

            double ma60Y = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.ma60.value distance:candleDistance zeroY:zeroY];
            if (ma60First == YES) {
                [ma60Path moveToPoint:CGPointMake(x, ma60Y)];
                ma60First = NO;
            } else {
                [ma60Path addLineToPoint:CGPointMake(x, ma60Y)];
            }
        }

        if (obj.ma120.value != 0 && ![YXKLineConfigManager shareInstance].ma.ma_120_isHidden) {

            double ma120Y = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.ma120.value distance:candleDistance zeroY:zeroY];
            if (ma120First == YES) {
                [ma120Path moveToPoint:CGPointMake(x, ma120Y)];
                ma120First = NO;
            } else {
                [ma120Path addLineToPoint:CGPointMake(x, ma120Y)];
            }
        }

        if (obj.ma250.value != 0 && ![YXKLineConfigManager shareInstance].ma.ma_250_isHidden) {

            double ma250Y = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.ma250.value distance:candleDistance zeroY:zeroY];
            if (ma250First == YES) {
                [ma250Path moveToPoint:CGPointMake(x, ma250Y)];
                ma250First = NO;
            } else {
                [ma250Path addLineToPoint:CGPointMake(x, ma250Y)];
            }
        }
    }];
    self.generator.ma5Layer.path = ma5Path.CGPath;
    self.generator.ma20Layer.path = ma20Path.CGPath;
    self.generator.ma60Layer.path = ma60Path.CGPath;
    self.generator.ma120Layer.path = ma120Path.CGPath;
    self.generator.ma250Layer.path = ma250Path.CGPath;


    if (![YXKLineConfigManager shareInstance].ma.ma_5_isHidden) {
        self.generator.ma5Layer.path = ma5Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].ma.ma_20_isHidden) {
        self.generator.ma20Layer.path = ma20Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].ma.ma_60_isHidden) {
        self.generator.ma60Layer.path = ma60Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].ma.ma_120_isHidden) {
        self.generator.ma120Layer.path = ma120Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].ma.ma_250_isHidden) {
        self.generator.ma250Layer.path = ma250Path.CGPath;
    }
    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

/**
 BOLL
 */
- (void)drawBOLLLayer{

    NSArray *visibleArray =  [self getVisibleArr];

    //获取当前区域的最大最小值
    [self getMaxAndMinHigh];

    //当前区域的高度
    double candleDistance = CGRectGetHeight(self.candleRect) * 1;
    double zeroY = CGRectGetMaxY(self.candleRect) - CGRectGetHeight(self.candleRect) * 0;
    zeroY = CGRectGetHeight(self.candleRect);
    UIBezierPath *boll_MBPath = [UIBezierPath bezierPath];
    UIBezierPath *boll_UPPath = [UIBezierPath bezierPath];
    UIBezierPath *boll_DNPath = [UIBezierPath bezierPath];

    __block BOOL boll_MBFirst = YES;
    __block BOOL boll_UPFirst = YES;
    __block BOOL boll_DNFirst = YES;

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //计算蜡烛各个指标 的 x，y
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;

        if (obj.bollMB.value != 0 && ![YXKLineConfigManager shareInstance].boll.midIsHidden) {

            double bollMBY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.bollMB.value  distance:candleDistance zeroY:zeroY];
            if (boll_MBFirst == YES) {
                [boll_MBPath moveToPoint:CGPointMake(x, bollMBY)];
                boll_MBFirst = NO;
            } else {
                [boll_MBPath addLineToPoint:CGPointMake(x, bollMBY)];
            }

        }

        if (obj.bollUP.value != 0 && ![YXKLineConfigManager shareInstance].boll.upperIsHidden) {

            double bollUPY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.bollUP.value distance:candleDistance zeroY:zeroY];
            if (boll_UPFirst == YES) {
                [boll_UPPath moveToPoint:CGPointMake(x, bollUPY)];
                boll_UPFirst = NO;
            } else {
                [boll_UPPath addLineToPoint:CGPointMake(x, bollUPY)];
            }

        }


        if (obj.bollDN.value != 0 && ![YXKLineConfigManager shareInstance].boll.lowerIsHidden) {

            double bollDNY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.bollDN.value distance:candleDistance zeroY:zeroY];
            if (boll_DNFirst == YES) {
                [boll_DNPath moveToPoint:CGPointMake(x, bollDNY)];
                boll_DNFirst = NO;
            } else {
                [boll_DNPath addLineToPoint:CGPointMake(x, bollDNY)];
            }
        }

    }];

    if (![YXKLineConfigManager shareInstance].boll.midIsHidden) {
        self.generator.boll_MBLayer.path = boll_MBPath.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].boll.lowerIsHidden) {
        self.generator.boll_DNLayer.path = boll_DNPath.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].boll.upperIsHidden) {
        self.generator.boll_UPLayer.path = boll_UPPath.CGPath;
    }

    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

/**
 EMA
 */
- (void)drawEMALayer{

    NSArray *visibleArray =  [self getVisibleArr];

    //获取当前区域的最大最小值
    [self getMaxAndMinHigh];

    //当前区域的高度
    double candleDistance = CGRectGetHeight(self.candleRect) * 1;
    double zeroY = CGRectGetMaxY(self.candleRect) - CGRectGetHeight(self.candleRect) * 0;
    zeroY = CGRectGetHeight(self.candleRect);
    UIBezierPath *ema5Path = [UIBezierPath bezierPath];
    UIBezierPath *ema20Path = [UIBezierPath bezierPath];
    UIBezierPath *ema60Path = [UIBezierPath bezierPath];

    __block BOOL ema5First = YES;
    __block BOOL ema20First = YES;
    __block BOOL ema60First = YES;

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //计算蜡烛各个指标 的 x，y
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;
        if (obj.ema5.value != 0 && ![YXKLineConfigManager shareInstance].ema.ema_5_isHidden) {

            double ema5Y = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.ema5.value distance:candleDistance zeroY:zeroY];
            if (ema5First == YES) {
                [ema5Path moveToPoint:CGPointMake(x, ema5Y)];
                ema5First = NO;
            } else {
                [ema5Path addLineToPoint:CGPointMake(x, ema5Y)];
            }

        }
        if (obj.ema20.value != 0 && ![YXKLineConfigManager shareInstance].ema.ema_20_isHidden) {

            double ema20Y = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.ema20.value distance:candleDistance zeroY:zeroY];
            if (ema20First == YES) {
                [ema20Path moveToPoint:CGPointMake(x, ema20Y)];
                ema20First = NO;
            } else {
                [ema20Path addLineToPoint:CGPointMake(x, ema20Y)];
            }
        }

        if (obj.ema60.value != 0 && ![YXKLineConfigManager shareInstance].ema.ema_60_isHidden) {

            double ema60Y = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.ema60.value distance: candleDistance zeroY: zeroY];
            if (ema60First == YES) {
                [ema60Path moveToPoint:CGPointMake(x, ema60Y)];
                ema60First = NO;
            } else {
                [ema60Path addLineToPoint:CGPointMake(x, ema60Y)];
            }
        }

    }];

    if (![YXKLineConfigManager shareInstance].ema.ema_5_isHidden) {
        self.generator.ema5Layer.path = ema5Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].ema.ema_20_isHidden) {
        self.generator.ema20Layer.path = ema20Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].ema.ema_60_isHidden) {
        self.generator.ema60Layer.path = ema60Path.CGPath;
    }

    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

/**
 SAR
 */
- (void)drawSARLayer{

    NSArray *visibleArray =  [self getVisibleArr];
    //获取当前区域的最大最小值
    [self getMaxAndMinHigh];

    //当前区域的高度
    double candleDistance = CGRectGetHeight(self.candleRect) * 1;
    double zeroY = CGRectGetMaxY(self.candleRect) - CGRectGetHeight(self.candleRect) * 0;
    zeroY = CGRectGetHeight(self.candleRect);
    UIBezierPath *sar_redPath = [UIBezierPath bezierPath];
    UIBezierPath *sar_greenPath = [UIBezierPath bezierPath];

    if (![YXKLineConfigManager shareInstance].sar.bbIsHidden) {
        [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.sar.value > 0) {
                double radius = self.candleWidth * 0.35;
                if (radius > 3.2) {
                    radius = 3.2;
                }
                //计算蜡烛各个指标 的 x，y
                double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;
                if (obj.sar.value < obj.close.value) {
                    double sar_y = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.sar.value / self.priceBaseFullValue distance:candleDistance zeroY:zeroY];
                    UIBezierPath *redPath = [UIBezierPath bezierPath];
                    [redPath addArcWithCenter:CGPointMake(x, sar_y) radius:radius startAngle:0.0 endAngle:180.0 clockwise:YES];
                    [sar_redPath appendPath:redPath];
                } else {
                    double sar_y = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.sar.value / self.priceBaseFullValue distance:candleDistance zeroY:zeroY];
                    UIBezierPath *greenPath = [UIBezierPath bezierPath];
                    [greenPath addArcWithCenter:CGPointMake(x, sar_y) radius:radius startAngle:0.0 endAngle:180.0 clockwise:YES];
                    [sar_greenPath appendPath:greenPath];
                }
            }

        }];
        self.generator.sar_redLayer.path = sar_redPath.CGPath;
        self.generator.sar_greenLayer.path = sar_greenPath.CGPath;
    }
    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

// 获取蜡烛区域最大和最小值
- (void)getMaxAndMinHigh{

    //NSMutableArray *dataArr = [NSMutableArray array];

//    NSArray *visibleArray = [self getVisibleArr];
//    //价格的最大值
//    double maxHigh = [[visibleArray valueForKeyPath:@"@max.high.doubleValue"] doubleValue] / self.priceBaseFullValue;
//    //价格的最低值
//    double minLow = [[visibleArray valueForKeyPath:@"@min.low.value"] doubleValue] / self.priceBaseFullValue;
    
    
    NSArray<YXKLine *> *visibleArray = [self getVisibleArr];
        
    //价格的最大值
    double maxHigh = visibleArray.firstObject.high.value;
    //价格的最低值
    double minLow = visibleArray.firstObject.low.value;
    
    for (YXKLine *model in visibleArray) {
        if (maxHigh < model.high.value) {
            maxHigh = model.high.value;
        }
        
        if (minLow > model.low.value) {
            minLow = model.low.value;
        }
    }
    maxHigh = maxHigh / self.priceBaseFullValue;
    minLow = minLow / self.priceBaseFullValue;

    //    [dataArr addObject:@(maxHigh)];
    //    [dataArr addObject:@(minLow)];

    self.maxHigh = maxHigh;
    self.minLow = minLow;

    //    switch (_mainAccessoryStatus) {
    //        case YXStockMainAcessoryStatusMA:  //计算ma区域最大最小值
    //        {
    //        for (int x = 0; x < visibleArray.count; x ++) {
    //            YXKLine *kLineSingleModel = visibleArray[x];
    //            if (![YXKLineConfigManager shareInstance].ma.ma_5_isHidden && kLineSingleModel.ma5.value > 0) {
    //                [dataArr addObject:@(kLineSingleModel.ma5.value)];
    //            }
    //
    //            if (![YXKLineConfigManager shareInstance].ma.ma_20_isHidden && kLineSingleModel.ma20.value > 0) {
    //                [dataArr addObject:@(kLineSingleModel.ma20.value)];
    //            }
    //            if (![YXKLineConfigManager shareInstance].ma.ma_60_isHidden && kLineSingleModel.ma60.value > 0) {
    //                [dataArr addObject:@(kLineSingleModel.ma60.value)];
    //            }
    //            if (![YXKLineConfigManager shareInstance].ma.ma_120_isHidden && kLineSingleModel.ma120.value > 0) {
    //                [dataArr addObject:@(kLineSingleModel.ma120.value)];
    //            }
    //            if (![YXKLineConfigManager shareInstance].ma.ma_250_isHidden && kLineSingleModel.ma250.value > 0) {
    //                [dataArr addObject:@(kLineSingleModel.ma250.value)];
    //            }
    //        }
    //        self.maxHigh = [[dataArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
    //        self.minLow = [[dataArr valueForKeyPath:@"@min.doubleValue"] doubleValue];
    //
    //        }
    //            break;
    //        case YXStockMainAcessoryStatusEMA:  //计算ema区域最大最小值
    //        {
    //        for (int x = 0; x < visibleArray.count; x ++) {
    //
    //            YXKLine *kLineSingleModel = visibleArray[x];
    //            if (kLineSingleModel.ema5.value > 0 && ![YXKLineConfigManager shareInstance].ema.ema_5_isHidden) {
    //                [dataArr addObject:@(kLineSingleModel.ema5.value)];
    //            }
    //            if (kLineSingleModel.ema20.value > 0 && ![YXKLineConfigManager shareInstance].ema.ema_20_isHidden) {
    //                [dataArr addObject:@(kLineSingleModel.ema20.value)];
    //            }
    //            if (kLineSingleModel.ema60.value > 0 && ![YXKLineConfigManager shareInstance].ema.ema_60_isHidden) {
    //                [dataArr addObject:@(kLineSingleModel.ema60.value)];
    //            }
    //        }
    //        self.maxHigh = [[dataArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
    //        self.minLow = [[dataArr valueForKeyPath:@"@min.doubleValue"] doubleValue];
    //        }
    //
    //            break;
    //        case YXStockMainAcessoryStatusBOLL:  //计算boll区域最大最小值
    //        {
    //        for (int x = 0; x < visibleArray.count; x ++) {
    //
    //            YXKLine *kLineSingleModel = visibleArray[x];
    //            if (kLineSingleModel.bollMB.value > 0 && ![YXKLineConfigManager shareInstance].boll.midIsHidden) {
    //                [dataArr addObject:@(kLineSingleModel.bollMB.value)];
    //            }
    //            if (kLineSingleModel.bollUP.value > 0 && ![YXKLineConfigManager shareInstance].boll.upperIsHidden) {
    //                [dataArr addObject:@(kLineSingleModel.bollUP.value)];
    //            }
    //            if (kLineSingleModel.bollDN.value > 0 && ![YXKLineConfigManager shareInstance].boll.lowerIsHidden) {
    //                [dataArr addObject:@(kLineSingleModel.bollDN.value)];
    //            }
    //        }
    //        self.maxHigh = [[dataArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
    //        self.minLow = [[dataArr valueForKeyPath:@"@min.doubleValue"] doubleValue];
    //        }
    //
    //            break;
    //        case YXStockMainAcessoryStatusSAR:  //计算sar区域最大最小值
    //        {
    //        for (int x = 0; x < visibleArray.count; x ++) {
    //            YXKLine *kLineSingleModel = visibleArray[x];
    //            if (kLineSingleModel.sar.value > 0  && ![YXKLineConfigManager shareInstance].sar.bbIsHidden) {
    //                [dataArr addObject:@(kLineSingleModel.sar.value / self.priceBaseFullValue)];
    //            }
    //        }
    //        self.maxHigh = [[dataArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
    //        self.minLow = [[dataArr valueForKeyPath:@"@min.doubleValue"] doubleValue];
    //        }
    //            break;
    //
    //        default:
    //            break;
    //    }

    self.maxHigh = self.maxHigh + (self.maxHigh - self.minLow) * 0.1;
    self.minLow = self.minLow - (self.maxHigh - self.minLow) * 0.1;
}

- (void)drawUsmartLayer {
    
    NSArray *visibleArray = [self getVisibleArr];
        
    //获取当前区域的最大最小值
    [self getMaxAndMinHigh];

    //当前区域的高度
    double candleDistance = CGRectGetHeight(self.candleRect) * 1;
    double zeroY = CGRectGetMaxY(self.candleRect) - CGRectGetHeight(self.candleRect) * 0;
    zeroY = CGRectGetHeight(self.candleRect);
    
    UIBezierPath *usmart_UPPath = [UIBezierPath bezierPath];
    UIBezierPath *usmart_DownPath = [UIBezierPath bezierPath];
    UIBezierPath *usmart_BuyPath = [UIBezierPath bezierPath];
    UIBezierPath *usmart_SellPath = [UIBezierPath bezierPath];


    __block BOOL usmart_UPFirst = YES;
    __block BOOL usmart_DownFirst = YES;

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        double open = obj.open.value / self.priceBaseFullValue;
        if (open > self.maxHigh) {
            open = self.maxHigh;
        } else if (open < self.minLow) {
            open = self.minLow;
        }

        double close = obj.close.value / self.priceBaseFullValue;
        if (close > self.maxHigh) {
            close = self.maxHigh;
        } else if (close < self.minLow) {
            close = self.minLow;
        }
        
        double low = obj.low.value / self.priceBaseFullValue;
        if (low > open || low > close) {
            low = MIN(open, close);
        }
        double lowY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:low distance:candleDistance zeroY:zeroY];
        
        //计算蜡烛各个指标 的 x，y
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;

        if (obj.usmartUp.value != 0) {

            double bollUPY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.usmartUp.value distance:candleDistance zeroY:zeroY];
            if (usmart_UPFirst == YES) {
                [usmart_UPPath moveToPoint:CGPointMake(x, bollUPY)];
                usmart_UPFirst = NO;
            } else {
                [usmart_UPPath addLineToPoint:CGPointMake(x, bollUPY)];
            }
        }


        if (obj.usmartDown.value != 0 ) {

            double bollDNY = [YXKLineUtility getYCoordinateWithMaxPrice:self.maxHigh minPrice:self.minLow price:obj.usmartDown.value distance:candleDistance zeroY:zeroY];
            if (usmart_DownFirst == YES) {
                [usmart_DownPath moveToPoint:CGPointMake(x, bollDNY)];
                usmart_DownFirst = NO;
            } else {
                [usmart_DownPath addLineToPoint:CGPointMake(x, bollDNY)];
            }
        }
        
        if (obj.usmartSignalChg) {
            
            double radius = self.candleWidth * 0.4;
            if (radius > 6) {
                radius = 6;
            }
            CGFloat circleY = lowY + radius + 3;
            CGFloat lineYBegin = circleY + radius * 0.5 + 3;
            CGFloat lineYEnd = circleY + radius * 0.5 + 15;
            CGFloat lableY = lineYEnd + 3;
            if (obj.usmartSignalChg.value == 1 || obj.usmartSignalChg.value == 2 || obj.usmartSignalChg.value == 3) {
                UIBezierPath *redPath = [UIBezierPath bezierPath];
                [redPath addArcWithCenter:CGPointMake(x, circleY) radius:radius startAngle:0.0 endAngle:180.0 clockwise:YES];
                [usmart_BuyPath appendPath:redPath];
                
                UIBezierPath *linePath = [UIBezierPath bezierPath];
                [linePath moveToPoint:CGPointMake(x, lineYBegin)];
                [linePath addLineToPoint:CGPointMake(x, lineYEnd)];
                [usmart_BuyPath appendPath:linePath];
                UILabel *label = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"trend_signal_buy"] textColor:QMUITheme.stockRedColor textFont:[UIFont systemFontOfSize:10]];
                [label sizeToFit];
                label.frame = CGRectMake(x - label.mj_w * 0.5, lableY, label.mj_w, 14);
                label.textAlignment = NSTextAlignmentCenter;
                [self.buyLabels addObject:label];
                [self.mainLayer addSublayer:label.layer];
                
            } else if (obj.usmartSignalChg.value == 4 || obj.usmartSignalChg.value == 5 || obj.usmartSignalChg.value == 6) {
                UIBezierPath *greenPath = [UIBezierPath bezierPath];
                [greenPath addArcWithCenter:CGPointMake(x, circleY) radius:radius startAngle:0.0 endAngle:180.0 clockwise:YES];
                [usmart_SellPath appendPath:greenPath];
                
                UIBezierPath *linePath = [UIBezierPath bezierPath];
                [linePath moveToPoint:CGPointMake(x, lineYBegin)];
                [linePath addLineToPoint:CGPointMake(x, lineYEnd)];
                [usmart_SellPath appendPath:linePath];
                
                UILabel *label = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"trend_signal_sell"] textColor:QMUITheme.stockGreenColor textFont:[UIFont systemFontOfSize:10]];
                [label sizeToFit];
                label.frame = CGRectMake(x - label.mj_w * 0.5, lableY, label.mj_w, 14);
                label.textAlignment = NSTextAlignmentCenter;
                [self.sellLabels addObject:label];
                [self.mainLayer addSublayer:label.layer];
            }
        }
        
    }];

    self.generator.usmartUp_layer.path = usmart_DownPath.CGPath;
    self.generator.usmartDown_layer.path = usmart_UPPath.CGPath;
    self.generator.usmartBuy_layer.path = usmart_BuyPath.CGPath;
    self.generator.usmartSell_layer.path = usmart_SellPath.CGPath;
    
    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

/**
 删除主指标参数
 */
- (void)cleanMainAcessoryLayer{

    self.generator.ma5Layer.path = nil;
    self.generator.ma20Layer.path = nil;
    self.generator.ma60Layer.path = nil;
    self.generator.ma120Layer.path = nil;
    self.generator.ma250Layer.path = nil;

    self.generator.ema5Layer.path = nil;
    self.generator.ema20Layer.path = nil;
    self.generator.ema60Layer.path = nil;

    self.generator.boll_MBLayer.path = nil;
    self.generator.boll_DNLayer.path = nil;
    self.generator.boll_UPLayer.path = nil;

    self.generator.sar_redLayer.path = nil;
    self.generator.sar_greenLayer.path = nil;
    self.generator.sar_grayLayer.path = nil;
    
    self.generator.usmartUp_layer.path = nil;
    self.generator.usmartDown_layer.path = nil;
    self.generator.usmartBuy_layer.path = nil;
    self.generator.usmartSell_layer.path = nil;

    self.titleGenerator.MALabel.hidden = YES;
    self.titleGenerator.EMALabel.hidden = YES;
    self.titleGenerator.BOLLLabel.hidden = YES;
    self.titleGenerator.SARLabel.hidden = YES;
    self.titleGenerator.usmartLabel.hidden = YES;

    for (CALayer *layer in self.orderLayerArray) {
        [layer removeFromSuperlayer];
    }
    self.orderLayerArray = @[];
    
    
    for (UILabel *label in self.buyLabels) {
        [label.layer removeFromSuperlayer];
    }
    for (UILabel *label in self.sellLabels) {
        [label.layer removeFromSuperlayer];
    }
    [self.buyLabels removeAllObjects];
    [self.sellLabels removeAllObjects];
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
    self.secondaryMAVOLView.hidden = YES;

    //macd
    self.generator.redMACDLayer.path = nil;
    self.generator.greenMACDLayer.path = nil;
    self.generator.difLayer.path = nil;
    self.generator.deaLayer.path = nil;
    self.secondaryMACDView.hidden = YES;

    //rsi
    self.generator.RSI_6_layer.path = nil;
    self.generator.RSI_12_layer.path = nil;
    self.generator.RSI_24_layer.path = nil;
    self.secondaryRSIView.hidden = YES;

    //kdj
    self.generator.kdj_d_layer.path = nil;
    self.generator.kdj_j_layer.path = nil;
    self.generator.kdj_k_layer.path = nil;
    self.secondaryKDJView.hidden = YES;

    //dma
    self.generator.D_DIF_layer.path = nil;
    self.generator.D_AMA_layer.path = nil;
    self.secondaryDMAView.hidden = YES;

    //arbr
    self.generator.AR_layer.path = nil;
    self.generator.BR_layer.path = nil;
    self.secondaryARBRView.hidden = YES;

    //wr
    self.generator.WR1_layer.path = nil;
    self.generator.WR2_layer.path = nil;
    self.secondaryWRView.hidden = YES;

    //emv
    self.generator.EMV_layer.path = nil;
    self.generator.AEMV_layer.path = nil;
    self.secondaryEMVView.hidden = YES;

    //cr
    self.generator.CR_layer.path = nil;
    self.generator.CR1_layer.path = nil;
    self.generator.CR2_layer.path = nil;
    self.generator.CR3_layer.path = nil;
    self.generator.CR4_layer.path = nil;
    self.secondaryCRView.hidden = YES;
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

- (YXKLineCompanyActionLayer *)createCompanyActionLayer:(YXKLineCompanyActionStyle)style {
    YXKLineCompanyActionLayer *layer = [[YXKLineCompanyActionLayer alloc] init];
    layer.bounds = CGRectMake(0, 0, 6, 6);
    layer.actionStyle = style;
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

    NSArray *visibleArray =  [self getVisibleArr];

    //当前区域的最大成交量/成交额
    double maxVolume = 0;
    BOOL isIndex;
    if (self.isIndexStock) {
        isIndex = YES;
    } else {
        isIndex = NO;
    }
    if (isIndex) {
        maxVolume = [[visibleArray valueForKeyPath:@"@max.amount.value"] doubleValue];
    } else {
        maxVolume = [[visibleArray valueForKeyPath:@"@max.volume.value"] doubleValue];
    }
    double max5Volumn = 0;
    double max10Volumn = 0;
    double max20Volumn = 0;

    if (![YXKLineConfigManager shareInstance].mavol.mavol_5_isHidden) {
        max5Volumn = [[visibleArray valueForKeyPath:@"@max.MVOL5.value"] doubleValue];
    }
    if (![YXKLineConfigManager shareInstance].mavol.mavol_10_isHidden) {
        max10Volumn = [[visibleArray valueForKeyPath:@"@max.MVOL10.value"] doubleValue];
    }
    if (![YXKLineConfigManager shareInstance].mavol.mavol_20_isHidden) {
        max20Volumn = [[visibleArray valueForKeyPath:@"@max.MVOL20.value"] doubleValue];
    }
    maxVolume = MAX(MAX(MAX(maxVolume, max5Volumn), max10Volumn), max20Volumn);

    self.subMaxHigh = maxVolume;
    self.subMinLow = 0;

    //当前区域的最小成交量/成交额
    NSInteger minVolume = 0;
    UIBezierPath *greenVolumePath = [UIBezierPath bezierPath];
    UIBezierPath *redVolumePath = [UIBezierPath bezierPath];

    UIBezierPath *volume5Path = [UIBezierPath bezierPath];
    UIBezierPath *volume10Path = [UIBezierPath bezierPath];
    UIBezierPath *volume20Path = [UIBezierPath bezierPath];

    __block BOOL volumn_5_First = YES;
    __block BOOL volumn_10_First = YES;
    __block BOOL volumn_20_First = YES;

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //计算蜡烛各个指标 的 x，y
        //        double x = (self.location + idx + 0.5) * (self.candleWidth + self.space);
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;
        double volume = 0;
        if (isIndex) {
            volume = obj.amount.value;
        } else {
            volume = obj.volume.value;
        }
        double volumeY = [YXKLineUtility getYCoordinateWithMaxVolumn:maxVolume minVolumn:minVolume volume:volume distance:CGRectGetHeight(self.volumeRect) zeroY: CGRectGetMaxY(self.volumeRect)];
        if (CGRectGetMaxY(self.volumeRect) - volumeY <= 0.3) {
            volumeY = CGRectGetMaxY(self.volumeRect) - 0.3;
        }
        if (obj.open.value > obj.close.value) { //阴线(开盘 > 收盘) -- 绿色

            //交易量的path
            UIBezierPath *volumePath = [YXKLineUtility getVolumePathWithVoumeWidth:self.candleWidth xCooordinate:x volumeY:volumeY zeroY:CGRectGetMaxY(self.volumeRect)];
            [greenVolumePath appendPath:volumePath];

        } else if (obj.open.value < obj.close.value) { //阳线(开盘 < 收盘) - 阳线

            //交易量的path
            UIBezierPath *volumePath = [YXKLineUtility getVolumePathWithVoumeWidth:self.candleWidth xCooordinate:x volumeY:volumeY zeroY:CGRectGetMaxY(self.volumeRect)];
            [redVolumePath appendPath:volumePath];
        } else {
            if (idx == 0) {
                //交易量的path
                UIBezierPath *volumePath = [YXKLineUtility getVolumePathWithVoumeWidth:self.candleWidth xCooordinate:x volumeY:volumeY zeroY:CGRectGetMaxY(self.volumeRect)];
                [redVolumePath appendPath:volumePath];

            } else {

                YXKLine * preObj = visibleArray[idx - 1];
                UIBezierPath *volumePath = [YXKLineUtility getVolumePathWithVoumeWidth:self.candleWidth xCooordinate:x volumeY:volumeY zeroY:CGRectGetMaxY(self.volumeRect)];
                if (obj.close.value > preObj.close.value) {
                    [redVolumePath appendPath:volumePath];
                } else if (obj.close.value < preObj.close.value) {
                    [greenVolumePath appendPath:volumePath];
                } else {
                    [redVolumePath appendPath:volumePath];
                }
            }

        }

        if (obj.MVOL5.value != 0 && ![YXKLineConfigManager shareInstance].mavol.mavol_5_isHidden) {
            double kdj_k = [YXKLineUtility getYCoordinateWithMaxPrice:maxVolume minPrice:0 price:obj.MVOL5.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (volumn_5_First == YES) {
                [volume5Path moveToPoint:CGPointMake(x, kdj_k)];
                volumn_5_First = NO;
            } else {
                [volume5Path addLineToPoint:CGPointMake(x, kdj_k)];
            }
        }

        if (obj.MVOL10.value != 0 && ![YXKLineConfigManager shareInstance].mavol.mavol_10_isHidden) {
            double kdj_D = [YXKLineUtility getYCoordinateWithMaxPrice:maxVolume minPrice:0 price:obj.MVOL10.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (volumn_10_First == YES) {
                [volume10Path moveToPoint:CGPointMake(x, kdj_D)];
                volumn_10_First = NO;
            } else {
                [volume10Path addLineToPoint:CGPointMake(x, kdj_D)];
            }
        }

        if (obj.MVOL20.value != 0 && ![YXKLineConfigManager shareInstance].mavol.mavol_20_isHidden) {
            double kdj_j = [YXKLineUtility getYCoordinateWithMaxPrice:maxVolume minPrice:0 price:obj.MVOL20.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (volumn_20_First == YES) {
                [volume20Path moveToPoint:CGPointMake(x, kdj_j)];
                volumn_20_First = NO;
            } else {
                [volume20Path addLineToPoint:CGPointMake(x, kdj_j)];
            }
        }
    }];
    self.generator.redVolumeLayer.path = redVolumePath.CGPath;
    self.generator.greenVolumeLayer.path = greenVolumePath.CGPath;

    if (![YXKLineConfigManager shareInstance].mavol.mavol_5_isHidden) {
        self.generator.volumn5_Layer.path = volume5Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].mavol.mavol_10_isHidden) {
        self.generator.volumn10_Layer.path = volume10Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].mavol.mavol_20_isHidden) {
        self.generator.volumn20_Layer.path = volume20Path.CGPath;
    }

    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

/**
 MACD线
 */
- (void)drawMACDLayer{

    NSArray *visibleArray =  [self getVisibleArr];

    UIBezierPath *redMACDPath = [UIBezierPath bezierPath];
    UIBezierPath *greenMACDPath = [UIBezierPath bezierPath];
    UIBezierPath *difMACDPath = [UIBezierPath bezierPath];
    UIBezierPath *deaMACDPath = [UIBezierPath bezierPath];

    //当前区域的最大值和最小值
    NSMutableArray *highMACDArr = [NSMutableArray array];
    NSMutableArray *lowMACDArr = [NSMutableArray array];
    if (![YXKLineConfigManager shareInstance].macd.macdIsHidden) {
        double maxMACD = [[visibleArray valueForKeyPath:@"@max.MACD.value"] doubleValue];
        double minMACD = [[visibleArray valueForKeyPath:@"@min.MACD.value"] doubleValue];
        [highMACDArr addObject:@(maxMACD)];
        [lowMACDArr addObject:@(minMACD)];
    }
    if (![YXKLineConfigManager shareInstance].macd.deaIsHidden) {
        double maxDea = [[visibleArray valueForKeyPath:@"@max.DEA.value"] doubleValue];
        double minDea = [[visibleArray valueForKeyPath:@"@min.DEA.value"] doubleValue];
        [highMACDArr addObject:@(maxDea)];
        [lowMACDArr addObject:@(minDea)];
    }
    if (![YXKLineConfigManager shareInstance].macd.difIsHidden) {
        double maxDif = [[visibleArray valueForKeyPath:@"@max.DIF.value"] doubleValue];
        double minDif = [[visibleArray valueForKeyPath:@"@min.DIF.value"] doubleValue];
        [highMACDArr addObject:@(maxDif)];
        [lowMACDArr addObject:@(minDif)];
    }
    //当前区域的最小值
    double highMACD = [[highMACDArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double lowMACD = [[lowMACDArr valueForKeyPath:@"@min.doubleValue"] doubleValue];

    //    if (highMACD >= 0 && lowMACD >= 0) {
    //        //都为正
    //        highMACD = highMACD;
    //        lowMACD = -highMACD;
    //    } else if (highMACD <= 0 && lowMACD <= 0) {
    //        //都为负
    //        highMACD = -lowMACD;
    //        lowMACD = lowMACD;
    //    } else {
    //        //一正一负
    //        highMACD = MAX(fabs(highMACD), fabs(lowMACD));
    //        lowMACD = -highMACD;
    //    }

    self.subMaxHigh = highMACD;
    self.subMinLow = lowMACD;

    //初次划线
    __block BOOL dif_k_First = YES;
    __block BOOL dea_k_First = YES;

    CGFloat distance = CGRectGetHeight(self.volumeRect);

    CGFloat offsetValue = (self.subMaxHigh - self.subMinLow);

    if (offsetValue == 0) {
        return;
    }

    CGFloat zeroY = [YXKLineUtility getYCoordinateWithMaxPrice:self.subMaxHigh minPrice:self.subMinLow price:0 distance:distance zeroY:CGRectGetMaxY(self.volumeRect)];

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine *  obj, NSUInteger idx, BOOL * _Nonnull stop) {

        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;

        if (![YXKLineConfigManager shareInstance].macd.macdIsHidden) {
            if (obj.MACD.value > 0) { //红色向上
                CGFloat height = distance * obj.MACD.value / offsetValue;
                UIBezierPath *redPath = [UIBezierPath bezierPathWithRect:CGRectMake(x - self.candleWidth * 0.5, zeroY - height, self.candleWidth, height)];
                [redMACDPath appendPath:redPath];

            } else {  //绿色向下
                CGFloat height = distance * fabs(obj.MACD.value) / offsetValue;
                UIBezierPath *greenPath = [UIBezierPath bezierPathWithRect:CGRectMake(x - self.candleWidth * 0.5, zeroY, self.candleWidth, height)];
                [greenMACDPath appendPath:greenPath];

            }
        }

        //DIF
        if (obj.DIF.value != 0 && ![YXKLineConfigManager shareInstance].macd.difIsHidden) {
            double dif_MACD = [YXKLineUtility getYCoordinateWithMaxPrice:highMACD minPrice:lowMACD price:obj.DIF.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (dif_k_First == YES) {
                [difMACDPath moveToPoint:CGPointMake(x, dif_MACD)];
                dif_k_First = NO;
            } else {
                [difMACDPath addLineToPoint:CGPointMake(x, dif_MACD)];
            }
        }
        //DEA
        if (obj.DEA.value != 0 && ![YXKLineConfigManager shareInstance].macd.deaIsHidden) {
            double dea_MACD = [YXKLineUtility getYCoordinateWithMaxPrice:highMACD minPrice:lowMACD price:obj.DEA.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (dea_k_First == YES) {
                [deaMACDPath moveToPoint:CGPointMake(x, dea_MACD)];
                dea_k_First = NO;
            } else {
                [deaMACDPath addLineToPoint:CGPointMake(x, dea_MACD)];
            }
        }
    }];
    if (![YXKLineConfigManager shareInstance].macd.macdIsHidden) {
        self.generator.redMACDLayer.path = redMACDPath.CGPath;
        self.generator.greenMACDLayer.path = greenMACDPath.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].macd.difIsHidden) {
        self.generator.difLayer.path = difMACDPath.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].macd.deaIsHidden) {
        self.generator.deaLayer.path = deaMACDPath.CGPath;
    }
    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

/**
 KDJ线
 */
- (void)drawKDJLayer{

    NSArray *visibleArray =  [self getVisibleArr];
    double maxKDJ = 0.0;
    double minKDJ = 0.0;

    //当前区域的最大值和最小值
    NSMutableArray *highArr = [NSMutableArray array];
    NSMutableArray *lowMArr = [NSMutableArray array];
    if (![YXKLineConfigManager shareInstance].kdj.K_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.KDJ_K.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.KDJ_K.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    if (![YXKLineConfigManager shareInstance].kdj.D_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.KDJ_D.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.KDJ_D.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    if (![YXKLineConfigManager shareInstance].kdj.J_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.KDJ_J.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.KDJ_J.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    maxKDJ = [[highArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
    minKDJ = [[lowMArr valueForKeyPath:@"@min.doubleValue"] doubleValue];

    UIBezierPath *kdj_k_Path = [UIBezierPath bezierPath];
    UIBezierPath *kdj_d_Path = [UIBezierPath bezierPath];
    UIBezierPath *kdj_j_Path = [UIBezierPath bezierPath];

    self.subMaxHigh = maxKDJ;
    self.subMinLow = minKDJ;

    __block BOOL kdj_k_First = YES;
    __block BOOL kdj_d_First = YES;
    __block BOOL kdj_j_First = YES;

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //计算蜡烛各个指标 的 x，y
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;

        if (obj.KDJ_K.value != 0 && ![YXKLineConfigManager shareInstance].kdj.K_IsHidden) {
            double kdj_k = [YXKLineUtility getYCoordinateWithMaxPrice:maxKDJ minPrice:minKDJ price:obj.KDJ_K.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (kdj_k_First == YES) {
                [kdj_k_Path moveToPoint:CGPointMake(x, kdj_k)];
                kdj_k_First = NO;
            } else {
                [kdj_k_Path addLineToPoint:CGPointMake(x, kdj_k)];
            }
        }

        if (obj.KDJ_D.value != 0 && ![YXKLineConfigManager shareInstance].kdj.D_IsHidden) {
            double kdj_D = [YXKLineUtility getYCoordinateWithMaxPrice:maxKDJ minPrice:minKDJ price:obj.KDJ_D.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (kdj_d_First == YES) {
                [kdj_d_Path moveToPoint:CGPointMake(x, kdj_D)];
                kdj_d_First = NO;
            } else {
                [kdj_d_Path addLineToPoint:CGPointMake(x, kdj_D)];
            }
        }

        if (obj.KDJ_J.value != 0 && ![YXKLineConfigManager shareInstance].kdj.J_IsHidden) {
            double kdj_j = [YXKLineUtility getYCoordinateWithMaxPrice:maxKDJ minPrice:minKDJ price:obj.KDJ_J.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (kdj_j_First == YES) {
                [kdj_j_Path moveToPoint:CGPointMake(x, kdj_j)];
                kdj_j_First = NO;
            } else {
                [kdj_j_Path addLineToPoint:CGPointMake(x, kdj_j)];
            }
        }

    }];

    if (![YXKLineConfigManager shareInstance].kdj.K_IsHidden) {
        self.generator.kdj_k_layer.path = kdj_k_Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].kdj.D_IsHidden) {
        self.generator.kdj_d_layer.path = kdj_d_Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].kdj.J_IsHidden) {
        self.generator.kdj_j_layer.path = kdj_j_Path.CGPath;
    }
    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

/**
 RSI线
 */
- (void)drawRSILayer{

    NSArray *visibleArray =  [self getVisibleArr];

    //当前区域的最大值和最小值
    NSMutableArray *highArr = [NSMutableArray array];
    NSMutableArray *lowMArr = [NSMutableArray array];
    if (![YXKLineConfigManager shareInstance].rsi.rsi_1_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.RSI_6.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.RSI_6.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    if (![YXKLineConfigManager shareInstance].rsi.rsi_2_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.RSI_12.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.RSI_12.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    if (![YXKLineConfigManager shareInstance].rsi.rsi_3_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.RSI_24.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.RSI_24.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    double rsiHigh = [[highArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double rsiLow = [[lowMArr valueForKeyPath:@"@min.doubleValue"] doubleValue];

    self.subMaxHigh = rsiHigh;
    self.subMinLow = rsiLow;
    if (self.scrollView.contentOffset.x == 0) {
        self.subMinLow = 0;
    }

    UIBezierPath *RSI_6_Path = [UIBezierPath bezierPath];
    UIBezierPath *RSI_12_Path = [UIBezierPath bezierPath];
    UIBezierPath *RSI_24_Path = [UIBezierPath bezierPath];


    __block BOOL RSI_6_First = YES;
    __block BOOL RSI_12_First = YES;
    __block BOOL RSI_24_First = YES;

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //计算蜡烛各个指标 的 x，y
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;

        if (![YXKLineConfigManager shareInstance].rsi.rsi_1_IsHidden) {
            double RSI_6_Y = [YXKLineUtility getYCoordinateWithMaxPrice:rsiHigh minPrice:rsiLow price:obj.RSI_6.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (RSI_6_First == YES) {
                [RSI_6_Path moveToPoint:CGPointMake(x, RSI_6_Y)];
                RSI_6_First = NO;
            } else {
                [RSI_6_Path addLineToPoint:CGPointMake(x, RSI_6_Y)];
            }
        }

        if (![YXKLineConfigManager shareInstance].rsi.rsi_2_IsHidden) {
            double RSI_12_Y = [YXKLineUtility getYCoordinateWithMaxPrice:rsiHigh minPrice:rsiLow price:obj.RSI_12.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (RSI_12_First == YES) {
                [RSI_12_Path moveToPoint:CGPointMake(x, RSI_12_Y)];
                RSI_12_First = NO;
            } else {
                [RSI_12_Path addLineToPoint:CGPointMake(x, RSI_12_Y)];
            }
        }

        if (![YXKLineConfigManager shareInstance].rsi.rsi_3_IsHidden) {
            double RSI_24_Y = [YXKLineUtility getYCoordinateWithMaxPrice:rsiHigh minPrice:rsiLow price:obj.RSI_24.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (RSI_24_First == YES) {
                [RSI_24_Path moveToPoint:CGPointMake(x, RSI_24_Y)];
                RSI_24_First = NO;
            } else {
                [RSI_24_Path addLineToPoint:CGPointMake(x, RSI_24_Y)];
            }
        }

    }];

    if (![YXKLineConfigManager shareInstance].rsi.rsi_1_IsHidden) {
        self.generator.RSI_6_layer.path = RSI_6_Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].rsi.rsi_2_IsHidden) {
        self.generator.RSI_12_layer.path = RSI_12_Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].rsi.rsi_3_IsHidden) {
        self.generator.RSI_24_layer.path = RSI_24_Path.CGPath;
    }

    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

/**
 DMA线
 */
- (void)drawDMALayer{

    NSArray *visibleArray =  [self getVisibleArr];

    //当前区域的最大值和最小值
    NSMutableArray *highArr = [NSMutableArray array];
    NSMutableArray *lowMArr = [NSMutableArray array];
    if (![YXKLineConfigManager shareInstance].dma.ddd_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.mDIF.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.mDIF.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    if (![YXKLineConfigManager shareInstance].dma.dma_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.mAMA.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.mAMA.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    double dmaHigh = [[highArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double dmaLow = [[lowMArr valueForKeyPath:@"@min.doubleValue"] doubleValue];

    self.subMaxHigh = dmaHigh;
    self.subMinLow = dmaLow;

    UIBezierPath *DIF_Path = [UIBezierPath bezierPath];
    UIBezierPath *AMA_Path = [UIBezierPath bezierPath];


    __block BOOL DIF_First = YES;
    __block BOOL AMA_First = YES;

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //计算蜡烛各个指标 的 x，y
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;

        if (obj.mDIF.value != 0 && ![YXKLineConfigManager shareInstance].dma.ddd_IsHidden) {
            double RSI_6_Y = [YXKLineUtility getYCoordinateWithMaxPrice:dmaHigh minPrice:dmaLow price:obj.mDIF.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (DIF_First == YES) {
                [DIF_Path moveToPoint:CGPointMake(x, RSI_6_Y)];
                DIF_First = NO;
            } else {
                [DIF_Path addLineToPoint:CGPointMake(x, RSI_6_Y)];
            }
        }

        if (obj.mAMA.value != 0 && ![YXKLineConfigManager shareInstance].dma.dma_IsHidden) {
            double RSI_12_Y = [YXKLineUtility getYCoordinateWithMaxPrice:dmaHigh minPrice:dmaLow price:obj.mAMA.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (AMA_First == YES) {
                [AMA_Path moveToPoint:CGPointMake(x, RSI_12_Y)];
                AMA_First = NO;
            } else {
                [AMA_Path addLineToPoint:CGPointMake(x, RSI_12_Y)];
            }
        }
    }];

    if (![YXKLineConfigManager shareInstance].dma.ddd_IsHidden) {
        self.generator.D_DIF_layer.path = DIF_Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].dma.dma_IsHidden) {
        self.generator.D_AMA_layer.path = AMA_Path.CGPath;
    }
    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

/**
 ARBR线
 */
- (void)drawARBRLayer{

    NSArray *visibleArray =  [self getVisibleArr];

    //当前区域的最大值和最小值
    NSMutableArray *highArr = [NSMutableArray array];
    NSMutableArray *lowMArr = [NSMutableArray array];
    if (![YXKLineConfigManager shareInstance].arbr.ar_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.AR.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.AR.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    if (![YXKLineConfigManager shareInstance].arbr.br_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.BR.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.BR.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    double arbrHigh = [[highArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double arbrLow = [[lowMArr valueForKeyPath:@"@min.doubleValue"] doubleValue];

    self.subMaxHigh = arbrHigh;
    self.subMinLow = arbrLow;

    UIBezierPath *AR_Path = [UIBezierPath bezierPath];
    UIBezierPath *BR_Path = [UIBezierPath bezierPath];

    __block BOOL AR_First = YES;
    __block BOOL BR_First = YES;

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //计算蜡烛各个指标 的 x，y
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;

        if (obj.AR.value != 0 && ![YXKLineConfigManager shareInstance].arbr.ar_IsHidden) {
            double RSI_6_Y = [YXKLineUtility getYCoordinateWithMaxPrice:arbrHigh minPrice:arbrLow price:obj.AR.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (AR_First == YES) {
                [AR_Path moveToPoint:CGPointMake(x, RSI_6_Y)];
                AR_First = NO;
            } else {
                [AR_Path addLineToPoint:CGPointMake(x, RSI_6_Y)];
            }
        }

        if (obj.BR.value != 0 && ![YXKLineConfigManager shareInstance].arbr.br_IsHidden) {
            double RSI_12_Y = [YXKLineUtility getYCoordinateWithMaxPrice:arbrHigh minPrice:arbrLow price:obj.BR.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (BR_First == YES) {
                [BR_Path moveToPoint:CGPointMake(x, RSI_12_Y)];
                BR_First = NO;
            } else {
                [BR_Path addLineToPoint:CGPointMake(x, RSI_12_Y)];
            }
        }
    }];

    if (![YXKLineConfigManager shareInstance].arbr.ar_IsHidden) {
        self.generator.AR_layer.path = AR_Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].arbr.br_IsHidden) {
        self.generator.BR_layer.path = BR_Path.CGPath;
    }

    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

/**
 WR线
 */
- (void)drawWRLayer{

    NSArray *visibleArray =  [self getVisibleArr];

    //当前区域的最大值和最小值
    NSMutableArray *highArr = [NSMutableArray array];
    NSMutableArray *lowMArr = [NSMutableArray array];
    if (![YXKLineConfigManager shareInstance].wr.wr_1_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.WR1.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.WR1.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    if (![YXKLineConfigManager shareInstance].wr.wr_2_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.WR2.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.WR2.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    double dmaHigh = [[highArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double dmaLow = [[lowMArr valueForKeyPath:@"@min.doubleValue"] doubleValue];

    self.subMaxHigh = dmaHigh;
    self.subMinLow = dmaLow;

    UIBezierPath *DIF_Path = [UIBezierPath bezierPath];
    UIBezierPath *AMA_Path = [UIBezierPath bezierPath];


    __block BOOL DIF_First = YES;
    __block BOOL AMA_First = YES;

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //计算蜡烛各个指标 的 x，y
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;

        if (obj.WR1.value != 0 && ![YXKLineConfigManager shareInstance].wr.wr_1_IsHidden) {
            double RSI_6_Y = [YXKLineUtility getYCoordinateWithMaxPrice:dmaHigh minPrice:dmaLow price:obj.WR1.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (DIF_First == YES) {
                [DIF_Path moveToPoint:CGPointMake(x, RSI_6_Y)];
                DIF_First = NO;
            } else {
                [DIF_Path addLineToPoint:CGPointMake(x, RSI_6_Y)];
            }
        }

        if (obj.WR2.value != 0 && ![YXKLineConfigManager shareInstance].wr.wr_2_IsHidden) {
            double RSI_12_Y = [YXKLineUtility getYCoordinateWithMaxPrice:dmaHigh minPrice:dmaLow price:obj.WR2.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (AMA_First == YES) {
                [AMA_Path moveToPoint:CGPointMake(x, RSI_12_Y)];
                AMA_First = NO;
            } else {
                [AMA_Path addLineToPoint:CGPointMake(x, RSI_12_Y)];
            }
        }


    }];

    if (![YXKLineConfigManager shareInstance].wr.wr_1_IsHidden) {
        self.generator.WR1_layer.path = DIF_Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].wr.wr_2_IsHidden) {
        self.generator.WR2_layer.path = AMA_Path.CGPath;
    }

    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

/**
 EMV线
 */
- (void)drawEMVLayer{

    NSArray *visibleArray =  [self getVisibleArr];

    //当前区域的最大值和最小值
    NSMutableArray *highArr = [NSMutableArray array];
    NSMutableArray *lowMArr = [NSMutableArray array];
    if (![YXKLineConfigManager shareInstance].emv.em_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.EMV.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.EMV.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    if (![YXKLineConfigManager shareInstance].emv.emva_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.AEMV.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.AEMV.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    double dmaHigh = [[highArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double dmaLow = [[lowMArr valueForKeyPath:@"@min.doubleValue"] doubleValue];

    self.subMaxHigh = dmaHigh;
    self.subMinLow = dmaLow;

    UIBezierPath *DIF_Path = [UIBezierPath bezierPath];
    UIBezierPath *AMA_Path = [UIBezierPath bezierPath];


    __block BOOL DIF_First = YES;
    __block BOOL AMA_First = YES;

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //计算蜡烛各个指标 的 x，y
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;

        if (obj.EMV.value != 0 && ![YXKLineConfigManager shareInstance].emv.em_IsHidden) {
            double RSI_6_Y = [YXKLineUtility getYCoordinateWithMaxPrice:dmaHigh minPrice:dmaLow price:obj.EMV.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (DIF_First == YES) {
                [DIF_Path moveToPoint:CGPointMake(x, RSI_6_Y)];
                DIF_First = NO;
            } else {
                [DIF_Path addLineToPoint:CGPointMake(x, RSI_6_Y)];
            }
        }

        if (obj.AEMV.value != 0 && ![YXKLineConfigManager shareInstance].emv.emva_IsHidden) {
            double RSI_12_Y = [YXKLineUtility getYCoordinateWithMaxPrice:dmaHigh minPrice:dmaLow price:obj.AEMV.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (AMA_First == YES) {
                [AMA_Path moveToPoint:CGPointMake(x, RSI_12_Y)];
                AMA_First = NO;
            } else {
                [AMA_Path addLineToPoint:CGPointMake(x, RSI_12_Y)];
            }
        }


    }];
    if (![YXKLineConfigManager shareInstance].emv.em_IsHidden) {
        self.generator.EMV_layer.path = DIF_Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].emv.emva_IsHidden) {
        self.generator.AEMV_layer.path = AMA_Path.CGPath;
    }

    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}

/**
 CR线
 */
- (void)drawCRLayer{

    NSArray *visibleArray =  [self getVisibleArr];

    //当前区域的最大值和最小值
    NSMutableArray *highArr = [NSMutableArray array];
    NSMutableArray *lowMArr = [NSMutableArray array];
    if (![YXKLineConfigManager shareInstance].cr.cr_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.CR.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.CR.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    if (![YXKLineConfigManager shareInstance].cr.ma_1_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.CR1.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.CR1.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    if (![YXKLineConfigManager shareInstance].cr.ma_2_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.CR2.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.CR2.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    if (![YXKLineConfigManager shareInstance].cr.ma_3_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.CR3.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.CR3.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    if (![YXKLineConfigManager shareInstance].cr.ma_4_IsHidden) {
        double max = [[visibleArray valueForKeyPath:@"@max.CR4.value"] doubleValue];
        double min = [[visibleArray valueForKeyPath:@"@min.CR4.value"] doubleValue];
        [highArr addObject:@(max)];
        [lowMArr addObject:@(min)];
    }
    double maxValue = [[highArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double minValue = [[lowMArr valueForKeyPath:@"@min.doubleValue"] doubleValue];

    self.subMaxHigh = maxValue;
    self.subMinLow = minValue;

    UIBezierPath *A_Path = [UIBezierPath bezierPath];
    UIBezierPath *B_Path = [UIBezierPath bezierPath];
    UIBezierPath *C_Path = [UIBezierPath bezierPath];
    UIBezierPath *D_Path = [UIBezierPath bezierPath];
    UIBezierPath *E_Path = [UIBezierPath bezierPath];


    __block BOOL A_First = YES;
    __block BOOL B_First = YES;
    __block BOOL C_First = YES;
    __block BOOL D_First = YES;
    __block BOOL E_First = YES;

    [visibleArray enumerateObjectsUsingBlock:^(YXKLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //计算蜡烛各个指标 的 x，y
        double x = (self.candleWidth + self.space) * obj.index.value + self.candleWidth * 0.5;

        if (obj.CR.value != 0 && ![YXKLineConfigManager shareInstance].cr.cr_IsHidden) {
            double y = [YXKLineUtility getYCoordinateWithMaxPrice:maxValue minPrice:minValue price:obj.CR.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (A_First == YES) {
                [A_Path moveToPoint:CGPointMake(x, y)];
                A_First = NO;
            } else {
                [A_Path addLineToPoint:CGPointMake(x, y)];
            }
        }

        if (obj.CR1.value != 0 && ![YXKLineConfigManager shareInstance].cr.ma_1_IsHidden) {
            double y = [YXKLineUtility getYCoordinateWithMaxPrice:maxValue minPrice:minValue price:obj.CR1.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (B_First == YES) {
                [B_Path moveToPoint:CGPointMake(x, y)];
                B_First = NO;
            } else {
                [B_Path addLineToPoint:CGPointMake(x, y)];
            }
        }
        if (obj.CR2.value != 0 && ![YXKLineConfigManager shareInstance].cr.ma_2_IsHidden) {
            double y = [YXKLineUtility getYCoordinateWithMaxPrice:maxValue minPrice:minValue price:obj.CR2.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (C_First == YES) {
                [C_Path moveToPoint:CGPointMake(x, y)];
                C_First = NO;
            } else {
                [C_Path addLineToPoint:CGPointMake(x, y)];
            }
        }
        if (obj.CR3.value != 0 && ![YXKLineConfigManager shareInstance].cr.ma_3_IsHidden) {
            double y = [YXKLineUtility getYCoordinateWithMaxPrice:maxValue minPrice:minValue price:obj.CR3.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (D_First == YES) {
                [D_Path moveToPoint:CGPointMake(x, y)];
                D_First = NO;
            } else {
                [D_Path addLineToPoint:CGPointMake(x, y)];
            }
        }
        if (obj.CR4.value != 0 && ![YXKLineConfigManager shareInstance].cr.ma_4_IsHidden) {
            double y = [YXKLineUtility getYCoordinateWithMaxPrice:maxValue minPrice:minValue price:obj.CR4.value distance:CGRectGetHeight(self.volumeRect) zeroY:CGRectGetMaxY(self.volumeRect)];
            if (E_First == YES) {
                [E_Path moveToPoint:CGPointMake(x, y)];
                E_First = NO;
            } else {
                [E_Path addLineToPoint:CGPointMake(x, y)];
            }
        }

    }];

    if (![YXKLineConfigManager shareInstance].cr.cr_IsHidden) {
        self.generator.CR_layer.path = A_Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].cr.ma_1_IsHidden) {
        self.generator.CR1_layer.path = B_Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].cr.ma_2_IsHidden) {
        self.generator.CR2_layer.path = C_Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].cr.ma_3_IsHidden) {
        self.generator.CR3_layer.path = D_Path.CGPath;
    }
    if (![YXKLineConfigManager shareInstance].cr.ma_4_IsHidden) {
        self.generator.CR4_layer.path = E_Path.CGPath;
    }

    [self dynamicChangeAccessoryLabelWithIndex:[self.klineModel.list indexOfObject:visibleArray.lastObject]];
}


#pragma mark - set 方法

/**
 主参数指标
 */
- (void)setMainAccessoryStatus:(YXStockMainAcessoryStatus)mainAccessoryStatus{

    _mainAccessoryStatus = mainAccessoryStatus;

    // 无数据返回
    if (self.klineModel.list.count == 0) {
        return;
    }
    
    if (self.mainAccessoryStatus == YXStockMainAcessoryStatusUsmart) {
        self.shadeView.hidden = YES;
        if (self.klineModel.type.value != 7) {
            self.shadeView.status = YXKlineAccessoryShadeTypeUnsupport;
            self.shadeView.hidden = NO;
        } else {
            if (![YXUserManager isLogin]) {
                self.shadeView.status = YXKlineAccessoryShadeTypeLogin;
                self.shadeView.hidden = NO;
            } else {
                if (![YXKLineConfigManager shareInstance].hasUsmartLimit) {
                    self.shadeView.status = YXKlineAccessoryShadeTypeUpdate;
                    self.shadeView.hidden = NO;
                } else {
                    self.shadeView.hidden = YES;
                }
            }
        }
        self.usmartDetailBtn.hidden = !self.shadeView.hidden;
    } else {
        self.shadeView.hidden = YES;
        self.usmartDetailBtn.hidden = YES;
    }

    //删除主指标参数
    [self cleanMainAcessoryLayer];

    if (self.candleWidth > 1) {
        switch (mainAccessoryStatus) {
            case YXStockMainAcessoryStatusMA:
                self.titleGenerator.MALabel.hidden = NO;
                [self drawMALayer];

                break;
            case YXStockMainAcessoryStatusBOLL:
                self.titleGenerator.BOLLLabel.hidden = NO;
                [self drawBOLLLayer];

                break;
            case YXStockMainAcessoryStatusEMA:
                self.titleGenerator.EMALabel.hidden = NO;
                [self drawEMALayer];

                break;
            case YXStockMainAcessoryStatusSAR:
                self.titleGenerator.SARLabel.hidden = NO;
                [self drawSARLayer];

                break;
            case YXStockMainAcessoryStatusUsmart:
                if (self.klineModel.type.value == 7) {
                    self.titleGenerator.usmartLabel.hidden = NO;
                    [self drawUsmartLayer];
                } else {
                    [self getMaxAndMinHigh];
                }
                break;
            case YXStockMainAcessoryStatusNone:
                [self cleanMainAcessoryLayer];

                break;
            default:
                break;
        }
    } else {
        //获取当前区域的最大最小值
        [self getMaxAndMinHigh];
    }

    [self drawKLineLayer];

}

- (void)drawAllSecondaryView {
    // 无数据返回
    if (self.klineModel.list.count == 0) {
        return;
    }

    [self cleanSubAccessoryLayer];

    NSArray *subAccessoryArr = YXKLineConfigManager.shareInstance.subAccessoryArray;
    for (YXKLineSecondaryView *secondaryView in self.secondaryViews) {
        if ([subAccessoryArr containsObject:@(secondaryView.subStatus)]) {
            secondaryView.hidden = NO;
            [secondaryView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.secondaryViewHeight);
            }];
            [self drawSecondaryView:secondaryView.subStatus];
            secondaryView.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.secondaryViewHeight - kSecondaryTopFixMargin);
            secondaryView.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, 0);

            [self setSubMaxAndMinPrice:secondaryView.subStatus secondaryView:secondaryView];
        } else {
            secondaryView.hidden = YES;
            [secondaryView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }
    }


}

- (YXKLineSecondaryView *)currentSecondaryView:(YXStockSubAccessoryStatus)status {
    YXKLineSecondaryView *secondaryView = nil;
    switch (status) {
        case YXStockSubAccessoryStatus_MAVOL: //新添加了vol参数
            secondaryView = self.secondaryMAVOLView;
            break;
        case YXStockSubAccessoryStatus_MACD:
            secondaryView = self.secondaryMACDView;
            break;
        case YXStockSubAccessoryStatus_KDJ:
            secondaryView = self.secondaryKDJView;
            break;
        case YXStockSubAccessoryStatus_RSI:
            secondaryView = self.secondaryRSIView;
            break;
        case YXStockSubAccessoryStatus_DMA:
            secondaryView = self.secondaryDMAView;
            break;
        case YXStockSubAccessoryStatus_ARBR:
            secondaryView = self.secondaryARBRView;
            break;
        case YXStockSubAccessoryStatus_WR:
            secondaryView = self.secondaryWRView;
            break;
        case YXStockSubAccessoryStatus_EMV:
            secondaryView = self.secondaryEMVView;
            break;
        case YXStockSubAccessoryStatus_CR:
            secondaryView = self.secondaryCRView;
            break;
        default:
            break;
    }
    return secondaryView;
}

- (void)drawSecondaryView:(YXStockSubAccessoryStatus)status {
    switch (status) {
        case YXStockSubAccessoryStatus_MAVOL: //新添加了vol参数
            //绘制成交量
            [self drawMAVOLLayer];
            break;

        case YXStockSubAccessoryStatus_MACD:
            //绘制MACD
            [self drawMACDLayer];
            break;
        case YXStockSubAccessoryStatus_KDJ:
            //绘制KDJ
            [self drawKDJLayer];
            break;

        case YXStockSubAccessoryStatus_RSI:
            //绘制RSI
            [self drawRSILayer];
            break;
        case YXStockSubAccessoryStatus_DMA:
            //绘制DMA
            [self drawDMALayer];
            break;
        case YXStockSubAccessoryStatus_ARBR:
            //绘制ARBR
            [self drawARBRLayer];
            break;
        case YXStockSubAccessoryStatus_WR:
            //绘制WR
            [self drawWRLayer];
            break;
        case YXStockSubAccessoryStatus_EMV:
            //绘制EMV
            [self drawEMVLayer];
            break;
        case YXStockSubAccessoryStatus_CR:
            //绘制EMV
            [self drawCRLayer];
            break;
        default:
            break;
    }
}

- (void)setSubMaxAndMinPrice:(YXStockSubAccessoryStatus)status secondaryView:(YXKLineSecondaryView *)secondaryView {

    if (status == YXStockSubAccessoryStatus_MAVOL) {
#ifdef IsHKApp

        if ([self.klineModel.ID.market isEqualToString:kYXMarketCryptos]) {
            secondaryView.subMinPriceLabel.hidden = YES;
            NSString *unitStr = [YXLanguageUtility kLangWithKey:@"stock_unit_en"];
            NSInteger pointCount = [YXToolUtility btDecimalPoint:@(self.subMaxHigh).stringValue];
        
            secondaryView.subMaxPriceLabel.text = [[YXToolUtility btNumberString:@(self.subMaxHigh).stringValue decimalPoint:pointCount isVol:YES showPlus:NO] stringByAppendingString:unitStr];
          
            secondaryView.subMidPriceLabel.text = [YXToolUtility btNumberString:@((self.subMaxHigh + self.subMinLow) * 0.5).stringValue decimalPoint:pointCount isVol:YES showPlus:NO];

            secondaryView.subMinPriceLabel.text = [YXToolUtility btNumberString:@(self.subMinLow).stringValue decimalPoint:pointCount isVol:YES showPlus:NO];
            
            return ;
        }
        secondaryView.subMinPriceLabel.hidden = YES;
        double priceBase;
        NSString *unitStr;
        if (YXUserManager.curLanguage == YXLanguageTypeEN) {
            if (self.isIndexStock) {
                priceBase = self.klineModel.priceBase.value;
                unitStr = @"";
            } else {
                priceBase = 0;
                unitStr = [YXLanguageUtility kLangWithKey:@"stock_unit_en"];
            }

            if ([self.klineModel.market isEqualToString:kYXMarketUsOption]) {
                unitStr = [YXLanguageUtility kLangWithKey:@"options_page"];

                if (self.subMaxHigh > 1000) {
                    secondaryView.subMaxPriceLabel.text = [YXToolUtility stockData:self.subMaxHigh deciPoint:2 stockUnit: unitStr priceBase:priceBase];
                } else {
                    secondaryView.subMaxPriceLabel.text = [NSString stringWithFormat:@"%d%@",(int)self.subMaxHigh, unitStr];
                }
            } else {
                secondaryView.subMaxPriceLabel.text = [YXToolUtility stockData:self.subMaxHigh deciPoint:2 stockUnit: unitStr priceBase:priceBase];
            }

            secondaryView.subMidPriceLabel.text = [YXToolUtility stockData:(self.subMaxHigh + self.subMinLow) * 0.5 deciPoint:2 stockUnit: @"" priceBase:priceBase];

            secondaryView.subMinPriceLabel.text = [YXToolUtility stockData:self.subMinLow deciPoint:2 stockUnit: @"" priceBase:priceBase];
        } else {
            if (self.isIndexStock) {
                priceBase = 100000000 * self.priceBaseFullValue;
                unitStr = [YXLanguageUtility kLangWithKey:@"common_billion"];
            } else {
                priceBase = 10000;
                unitStr = [NSString stringWithFormat:@"%@%@", [YXLanguageUtility kLangWithKey:@"stock_detail_ten_thousand"], [YXLanguageUtility kLangWithKey:@"stock_unit_en"]];
            }

            if ([self.klineModel.market isEqualToString:kYXMarketUsOption]) {
                if (self.subMaxHigh > 10000) {
                    unitStr = [NSString stringWithFormat:@"%@%@", [YXLanguageUtility kLangWithKey:@"stock_detail_ten_thousand"], [YXLanguageUtility kLangWithKey:@"options_page"]];
                    secondaryView.subMaxPriceLabel.text = [NSString stringWithFormat:@"%.2f%@", self.subMaxHigh / priceBase, unitStr];
                } else {
                    unitStr = [YXLanguageUtility kLangWithKey:@"options_page"];
                    secondaryView.subMaxPriceLabel.text = [NSString stringWithFormat:@"%d%@",(int)self.subMaxHigh, unitStr];
                }
            } else {
                secondaryView.subMaxPriceLabel.text = [NSString stringWithFormat:@"%.2f%@", self.subMaxHigh / priceBase, unitStr];
            }
            secondaryView.subMidPriceLabel.text = [NSString stringWithFormat:@"%.2f", (self.subMaxHigh + self.subMinLow) * 0.5 / priceBase];
            secondaryView.subMinPriceLabel.text = [NSString stringWithFormat:@"%.2f", self.subMinLow / priceBase];
        }
#else

        secondaryView.subMinPriceLabel.hidden = YES;
        double priceBase;
        NSString *unitStr;
        if (self.isIndexStock) {
            priceBase = 100000000 * self.priceBaseFullValue;
            unitStr = @"亿";
        } else {
            priceBase = 10000;
            unitStr = @"万股";
        }
        secondaryView.subMaxPriceLabel.text = [NSString stringWithFormat:@"%.2f%@", self.subMaxHigh / priceBase, unitStr];
        secondaryView.subMidPriceLabel.text = [NSString stringWithFormat:@"%.2f", (self.subMaxHigh + self.subMinLow) * 0.5 / priceBase];
        secondaryView.subMinPriceLabel.text = [NSString stringWithFormat:@"%.2f", self.subMinLow / priceBase];
#endif
    } else {
        secondaryView.subMinPriceLabel.hidden = NO;
        secondaryView.subMaxPriceLabel.text = [NSString stringWithFormat:@"%.2f", self.subMaxHigh];
        secondaryView.subMidPriceLabel.text = [NSString stringWithFormat:@"%.2f", (self.subMaxHigh + self.subMinLow) * 0.5];
        secondaryView.subMinPriceLabel.text = [NSString stringWithFormat:@"%.2f", self.subMinLow];
    }
}

#pragma mark - 网格 & 日期图

//日期图
- (void)drawDateView{

    BOOL isFirstDraw = NO;
    if (self.dateLabelArr.count <= 0 ) {
        isFirstDraw = YES;
    }
    for (int x = 0; x < self.monthArr.count; x ++) {

        if (!isFirstDraw) {
            UILabel *label = self.dateLabelArr[x];
            label.frame = CGRectMake(x * (self.space + self.candleWidth), CGRectGetMaxY(self.candleRect), 100, 20);
        } else {
            UILabel *dateLabel = [UILabel labelWithText:self.monthArr[x] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:10]];
            dateLabel.frame = CGRectMake(x * (self.space + self.candleWidth), CGRectGetMaxY(self.candleRect), 100, 20);
            [self.scrollView addSubview:dateLabel];
            [self.dateLabelArr addObject:dateLabel];
        }
    }
}


/**
 获取当前可视图部分数据数组
 */
- (NSArray *)getVisibleArr{

    //算出取数组的位置(location这里已经进行了取整)
    NSMutableArray<YXKLine *> *visibleArray = [NSMutableArray<YXKLine *> array];
    for (int x = 0; x < self.klineModel.list.count; x ++) {
        if (x * (self.candleWidth + self.space) + self.candleWidth * 0.5 >= self.scrollView.contentOffset.x && x * (self.candleWidth + self.space) + self.candleWidth * 0.5 <= (self.scrollView.contentOffset.x + self.candleRect.size.width)) {
            YXKLine *kLineSingleModel = self.klineModel.list[x];
            kLineSingleModel.index = [[NumberInt64 alloc] init:x];

            [visibleArray addObject:kLineSingleModel];
        }
    }
    return visibleArray;
}


#pragma mark - lazy

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

- (NSMutableArray *)monthArr{
    if (!_monthArr) {
        _monthArr = [NSMutableArray array];
    }
    return _monthArr;
}

- (NSMutableArray *)dateLabelArr{
    if (!_dateLabelArr) {
        _dateLabelArr = [NSMutableArray array];
    }
    return _dateLabelArr;
}


- (YXStockPopover *)popover {
    if (_popover == nil) {
        _popover = [[YXStockPopover alloc] init];
    }
    return _popover;
}

#pragma mark - set

- (void)setIsIndexStock:(BOOL)isIndexStock {
    _isIndexStock = isIndexStock;
    self.titleGenerator.isHKIndex = isIndexStock;
}


- (void)setKlineModel:(YXKLineData *)klineModel{

    // 无数据返回
    if (klineModel == nil || klineModel.list.count == 0) {
        return;
    }
    // 两种情况下重置, 一个是切换类型, 一个是切换复权
    BOOL sameType = NO;
    if (_klineModel.type.value == klineModel.type.value && [_klineModel.direction isEqualToString:klineModel.direction]) {
        sameType = YES;
    }

    // 如果上个记录的点的index比总数量还大, 就重置
    if (self.preListCount > klineModel.list.count) {
        self.isReset = YES;
    }

    // k线不同类型,重置
    if (sameType) {
        if (self.isReset) {
            self.isReset = NO;
            self.firstLoad = YES;
            self.isLoadingData = NO;
            self.preListCount = 0;
            self.firstKLineTime = 0;
        } else {
            self.firstLoad = NO;
        }
    } else {
        self.firstLoad = YES;
        self.isLoadingData = NO;
        self.preListCount = 0;
        self.firstKLineTime = 0;
    }
    _klineModel = klineModel;

    //priceBase
    NSInteger square = klineModel.priceBase.value > 0 ? klineModel.priceBase.value : 0;
    double priceBasic = pow(10.0, square);
    self.priceBaseFullValue = priceBasic;

    //scrollView的起始方向
    if (self.firstLoad) { //初次加载
        if (klineModel.list.count * (self.candleWidth + self.space) > CGRectGetWidth(self.candleRect)) {
            //右边为起点
            [self.scrollView setContentOffset:CGPointMake((klineModel.list.count * (self.candleWidth + self.space) - CGRectGetWidth(self.candleRect)), 0)];
        } else {
            if (self.candleWidth == 1) {
                self.needLoadMore = YES;
                [self loadMoreData];
            }
            //左边为起点
            [self.scrollView setContentOffset:CGPointMake(0, 0)];
        }
    }

    NSInteger offset = klineModel.list.count - self.preListCount;
    if (offset != 0 && self.preListCount != 0) {
        BOOL noScroll = (self.scrollView.contentSize.width - self.space - self.candleWidth - self.scrollView.contentOffset.x <= CGRectGetWidth(self.candleRect));

        double contentWidth = self.klineModel.list.count >= 1 ?  (self.candleWidth + self.space) * (self.klineModel.list.count - 1) + self.candleWidth : 0;
        self.scrollView.contentSize = CGSizeMake(contentWidth + self.externWidth, self.scrollView.frame.size.height);

        if (contentWidth >= CGRectGetWidth(self.candleRect)) {
            if ((self.firstKLineTime == 0 || self.firstKLineTime == klineModel.list.firstObject.latestTime.value) && (contentWidth >= CGRectGetWidth(self.candleRect))) {
                // 往后插入数据
                if (noScroll) {
                    //右边为起点
                    [self.scrollView setContentOffset:CGPointMake(contentWidth + self.space - CGRectGetWidth(self.candleRect), 0) animated:YES];
                }
            } else {
                // 加载更多
                if (self.needLoadMore && contentWidth >= CGRectGetWidth(self.candleRect)) {
                    //右边为起点
                    [self.scrollView setContentOffset:CGPointMake(contentWidth + self.space - CGRectGetWidth(self.candleRect), 0)];
                } else {
                    // 左边为起点
                    self.scrollView.contentOffset = CGPointMake((self.klineModel.list.count - self.preListCount) * (self.candleWidth + self.space), 0);
                }
            }
        } else {
            //左边为起点
            [self.scrollView setContentOffset:CGPointMake(0, 0)];
        }

        if (self.showQuoteDetail) {
            [self adjustLongPressCrossLayer: self.scrollView];
            [self loadHistoryTimeLineData];
        }

        self.isLoadingData = NO;
        self.needLoadMore = NO;
    }

    //    [self.titleGenerator updateMALabels];
    // 更新数量
    self.preListCount = klineModel.list.count;
    // 记录第一个时间
    self.firstKLineTime = klineModel.list.firstObject.latestTime.value;
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

- (UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if (!_pinchGestureRecognizer) {
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizerAction:)];
    }
    return _pinchGestureRecognizer;
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    self.isDraging = YES;

}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {

    if (self.showQuoteDetail) {
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    self.isDraging = NO;

    [self adjustLongPressCrossLayer: scrollView];
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//
//    self.isDraging = NO;
//    //滑动时隐藏长按view
//    if (!decelerate) {
//        [self adjustLongPressCrossLayer: scrollView];
//    }
//
//}

- (void)adjustLongPressCrossLayer:(UIScrollView *)scrollView {

    if (self.generator.crossLineLayer.hidden == NO) {
        CGFloat xOffset = scrollView.contentOffset.x + self.longPressXOffsetToScreen;
        NSInteger location = round(xOffset / (self.candleWidth + self.space));
        xOffset = location * (self.candleWidth + self.space);
        CGPoint point = CGPointMake(xOffset, self.lastLongPressPoint.y);

        scrollView.contentOffset = CGPointMake(xOffset - self.longPressXOffsetToScreen, scrollView.contentOffset.y);
        self.lastLongPressPoint = CGPointMake(point.x, self.lastLongPressPoint.y);
        [self handleLongPressActionWithPoint:point isScroll:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView.contentOffset.x <= 0.0 && self.isDraging) {  //加载更多(分页)
        [self loadMoreData];
    }
    //重新绘制
    [self drawAllLayers];

    if (self.generator.crossLineLayer.hidden == NO && self.isDraging) {
        //只有拖动时才处理
        [self handleLongPressActionWithPoint:CGPointMake(scrollView.contentOffset.x + self.longPressXOffsetToScreen, self.lastLongPressPoint.y) isScroll:YES];
    }

    for (YXKLineSecondaryView *view in self.secondaryViews) {
        if (view.hidden == NO) {
            view.scrollView.contentOffset = scrollView.contentOffset;
        }
    }

}


- (void)loadMoreData {

    if (_isLoadingData) {
        return;
    }
    _isLoadingData = YES;

    //    [self.loadMoreDataommand execute: [RACTuple tupleWithObjects:@{@"type": self.klineModel.type, @"direction" : [NSString stringWithFormat:@"%ld", (long)[YXKLineConfigManager shareInstance].adjustType], @"isMore": @"1"}, @(3), nil]];
    if (self.loadMoreCallBack) {
        self.loadMoreCallBack();
    }
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

        // 超出边界处理
        CGPoint pointInView = [gesture locationInView:self];
        if (pointInView.x < (self.candleWidth * 0.5) || pointInView.x > (CGRectGetWidth(self.candleRect) - self.candleWidth * 0.5)) {
            self.scrollView.scrollEnabled = YES;
            if (!self.showQuoteDetail) {
                [self performSelector:@selector(hideKlineLongPressView) withObject:nil afterDelay:3.0];
            }
            return;
        }
        self.scrollView.scrollEnabled = NO;
        [self handleLongPressActionWithPoint:point isScroll:NO];

    } else if (gesture.state == UIGestureRecognizerStateEnded) {

        self.scrollView.scrollEnabled = YES;
        if (!self.showQuoteDetail) {
            [self performSelector:@selector(hideKlineLongPressView) withObject:nil afterDelay:3.0];
        }
    }
}

- (void)handleLongPressActionWithPoint:(CGPoint)point isScroll:(BOOL)isScroll {

    NSInteger location = round(point.x / (self.candleWidth + self.space));

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
    if (point.y <= self.candleRect.origin.y + CGRectGetHeight(self.candleRect) * 0) {
        current_y = self.candleRect.origin.y + CGRectGetHeight(self.candleRect) * 0;
    } else if(point.y >= CGRectGetMaxY(self.candleRect) - CGRectGetHeight(self.candleRect) * 0) {
        current_y = CGRectGetMaxY(self.candleRect) - CGRectGetHeight(self.candleRect) * 0;
    } else {
        current_y = point.y;
    }

    double current_x = location * (self.candleWidth + self.space) +  self.candleWidth * 0.5 - self.scrollView.contentOffset.x;

    if (current_x < self.candleWidth * 0.5) {
        current_x = self.candleWidth * 0.5;
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

        if ([self.klineModel.ID.market isEqualToString:kYXMarketCryptos]) {
            NSString *deciPointFormat = [NSString stringWithFormat:@"%%.%ldf", (long)self.decimalCount];
            self.titleGenerator.crossingLinePriceLabel.text = [NSString stringWithFormat:deciPointFormat, [YXKLineUtility getPriceWithMaxPrice:self.maxHigh minPrice:self.minLow currentY:current_y distance:CGRectGetHeight(self.candleRect) * 1 zeroY:self.candleRect.origin.y + CGRectGetHeight(self.candleRect) * 0]];
        } else if (_klineModel.priceBase.value == 3) {
            self.titleGenerator.crossingLinePriceLabel.text = [NSString stringWithFormat:@"%.3lf", [YXKLineUtility getPriceWithMaxPrice:self.maxHigh minPrice:self.minLow currentY:current_y distance:CGRectGetHeight(self.candleRect) * 1 zeroY:self.candleRect.origin.y + CGRectGetHeight(self.candleRect) * 0]];
        } else {
            self.titleGenerator.crossingLinePriceLabel.text = [NSString stringWithFormat:@"%.2lf", [YXKLineUtility getPriceWithMaxPrice:self.maxHigh minPrice:self.minLow currentY:current_y distance:CGRectGetHeight(self.candleRect) * 1 zeroY:self.candleRect.origin.y + CGRectGetHeight(self.candleRect) * 0]];
        }

    } else {
        self.titleGenerator.crossingLinePriceLabel.text = @"0.000";
    }

    //长按对应的日期
    self.titleGenerator.currentDateLabel.hidden = NO;
    if (self.klineModel.type.value < 7) {
        self.titleGenerator.currentDateLabel.text = [YXDateHelper commonDateStringWithNumber:model.latestTime.value format:YXCommonDateFormatDF_MDYHM scaleType:YXCommonDateScaleTypeScale showWeek:NO];
    } else {
        self.titleGenerator.currentDateLabel.text = [YXDateHelper commonDateStringWithNumber:model.latestTime.value format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:YES];
    }

    if (!isScroll) {
        self.titleGenerator.currentDateLabel.frame = CGRectMake(model.closePoint.value - self.scrollView.contentOffset.x - 55, CGRectGetMaxY(self.candleRect), 110, 20);
        if (CGRectGetMaxX(self.titleGenerator.currentDateLabel.frame) >= self.frame.size.width) {
            self.titleGenerator.currentDateLabel.frame = CGRectMake(self.frame.size.width - 110, CGRectGetMaxY(self.candleRect), 110, 20);
        }
        if (self.titleGenerator.currentDateLabel.frame.origin.x <= self.frame.origin.x) {
            self.titleGenerator.currentDateLabel.frame = CGRectMake(0, CGRectGetMaxY(self.candleRect), 110, 20);
        }
    }

    if (!isScroll) {

        if (!self.hideHistoryTimeLine && !self.isLandscape && [YXKLineConfigManager shareInstance].lineType == YXRtLineTypeDayKline) {

            [self showTimeLineQueryButton: current_x];

            //滑动停顿时加载新数据
            if (self.showQuoteDetail) {
                [self loadHistoryTimeLineData];
                self.titleGenerator.currentDateLabel.hidden = NO;
            } else {
                self.queryQuoteButton.hidden = NO;
                self.titleGenerator.currentDateLabel.hidden = YES;
            }
        }
        self.lastLongPressPoint = CGPointMake(self.scrollView.contentOffset.x + current_x - self.candleWidth * 0.5, current_y);
        self.longPressXOffsetToScreen = current_x - self.candleWidth * 0.5;
    }

    //动态改变参数数值
    [self dynamicChangeAccessoryLabelWithIndex:location];

    if (self.klineLongPressStartCallBack) {
        self.klineLongPressStartCallBack(model);
    }
}

- (void)pinchGestureRecognizerAction:(UIPinchGestureRecognizer *)gesture {

    self.scrollView.scrollEnabled = NO;
    if (gesture.state == UIGestureRecognizerStateBegan && self.currentScale != 0) {

        gesture.scale = self.currentScale;

        CGPoint point1 = [gesture locationOfTouch:0 inView:self.scrollView];
        CGPoint point2 = [gesture locationOfTouch:1 inView:self.scrollView];
        self.touchCenterX = (point1.x + point2.x) / 2;
        self.centerXdistanceFromLeft = self.touchCenterX - self.scrollView.contentOffset.x;
        //手指中间位置的蜡烛的index
        self.touchCenterIndex = self.touchCenterX / (self.space + self.candleWidth);
        self.touchCenterIndex = self.touchCenterIndex >= self.klineModel.list.count ? self.klineModel.list.count - 1 : self.touchCenterIndex;

    } else if (gesture.state == UIGestureRecognizerStateChanged) {

        //缩放比例
        double scale = 0;
        scale = gesture.scale / self.currentScale;
        self.currentScale = gesture.scale;
        //蜡烛新的宽度和偏移量
        if (self.candleWidth * scale >= 16) {
            return;
        }
        self.candleWidth = self.candleWidth * scale;
        if (self.candleWidth <= 1) {
            self.candleWidth = 1;
        }
        double contentWidth = self.klineModel.list.count >= 1 ?  (self.candleWidth + self.space) * (self.klineModel.list.count - 1) + self.candleWidth : 0;
        self.scrollView.contentSize = CGSizeMake(contentWidth + self.externWidth, self.scrollView.frame.size.height);
        double offsetX = self.scrollView.contentOffset.x;
        
        if (YXKLineConfigManager.shareInstance.styleType == YXKlineStyleTypeOHLC && self.candleWidth * scale >= 5) {
            self.generator.redLineLayer.lineWidth = YX_KLINE_CANDLE_LINE_WIDTH * 2;
            self.generator.greenLineLayer.lineWidth = YX_KLINE_CANDLE_LINE_WIDTH * 2;
        } else {
            self.generator.redLineLayer.lineWidth = YX_KLINE_CANDLE_LINE_WIDTH;
            self.generator.greenLineLayer.lineWidth = YX_KLINE_CANDLE_LINE_WIDTH;
        }

        if (offsetX <= 0) {
            offsetX = 0.01f;
            if (contentWidth < CGRectGetWidth(self.candleRect)) {
                self.needLoadMore = YES;
                [self loadMoreData];
            }
        }else{
            offsetX = self.touchCenterIndex * (self.candleWidth + self.space) - self.centerXdistanceFromLeft;
            if (offsetX > self.scrollView.contentSize.width - self.scrollView.frame.size.width) {
                offsetX = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
            }
        }
        self.scrollView.contentOffset = CGPointMake(offsetX, 0);
        [self drawAllLayers];

        if (self.generator.crossLineLayer.hidden == NO) {
            CGFloat moveOffset = 0;
            if (contentWidth > CGRectGetWidth(self.candleRect)) {
                moveOffset = CGRectGetWidth(self.candleRect) / 2.0;
            } else {
                moveOffset = contentWidth / 2.0;
            }

            self.lastLongPressPoint = CGPointMake(offsetX + moveOffset + (self.candleWidth + self.space), self.lastLongPressPoint.y);
            [self moveCrossLineLayer:YES];
        }

    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        self.scrollView.scrollEnabled = YES;
        gesture.scale = self.currentScale;
    }
}

//单击手势事件
- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)gesture{

    if (!self.generator.crossLineLayer.hidden) {
        [self hideKlineLongPressView];
        if (self.showQuoteDetail && self.cancelQueryQuoteCallBack) {
            self.cancelQueryQuoteCallBack();
        }
    } else {
        // 点击主图还是副图
        CGPoint pointInView = [gesture locationInView:self];
        CGFloat y = pointInView.y;
        if (y > CGRectGetMinY(self.candleRect) && y < CGRectGetMaxY(self.candleRect)) {
            // 点击主图
            if (self.shadeView.hidden) {
                if (self.canTapPush && self.pushToLandscapeRightCallBack) {
                    self.pushToLandscapeRightCallBack();
                }
            } else {
                if (self.shadeView.status == YXKlineAccessoryShadeTypeLogin) {
                    if (self.usmartLineCallBack) {
                        self.usmartLineCallBack(0);
                    }
                } else if (self.shadeView.status == YXKlineAccessoryShadeTypeUpdate) {
                    if (self.usmartLineCallBack) {
                        self.usmartLineCallBack(1);
                    }
                }
            }
        } else if (y > CGRectGetMaxY(self.candleRect) + 20 && YXKLineConfigManager.shareInstance.subAccessoryArray.count == 1) {
            // 点击副图
            if (!self.isLandscape && y < CGRectGetMaxY(self.candleRect) + 35) {
                [[YXKLineConfigManager shareInstance] showExplainInfo:[YXKLineConfigManager.shareInstance.subAccessoryArray.firstObject integerValue]];
            } else {
                // 点击副图
                if (self.clickSubAccessoryView) {
                    self.clickSubAccessoryView();
                }
            }
        }
    }
}

//单击手势事件
- (void)doubleTapGestureRecognizerAction:(UITapGestureRecognizer *)gesture {

    if (self.doubleTapCallBack) {
        self.doubleTapCallBack();
    }
}

- (void)showMainMenu:(UIButton *)sender {

    if ([[YXKLineConfigManager shareInstance].mainTitleArr containsObject:sender.currentTitle]) {
        NSInteger index = [[YXKLineConfigManager shareInstance].mainTitleArr indexOfObject:sender.currentTitle];
        if (index < [YXKLineConfigManager shareInstance].mainTitleArr.count) {
            self.menuView.selectIndex = index;
        }
    } else {
        [self.menuView cleanSelect];
    }

    [self.popover show:self.menuView fromView:sender];
}

- (void)showSubMenu:(UIButton *)sender {

    NSInteger index = [[YXKLineConfigManager shareInstance].subTitleArr indexOfObject:sender.currentTitle];
    if (index < [YXKLineConfigManager shareInstance].subTitleArr.count) {
        self.subMenuView.selectIndex = index;
    }
    [self.popover show:self.subMenuView fromView:sender];
}

- (void)resetSubAccessory:(YXStockSubAccessoryStatus)status {

    //[YXKLineConfigManager shareInstance].subAccessory = status;
    [[YXKlineCalculateTool shareInstance] calAccessoryValue:self.klineModel];
    [self drawAllSecondaryView];
}

- (void)resetMainAccessory:(YXStockMainAcessoryStatus)status {

    [YXKLineConfigManager shareInstance].mainAccessory = status;
    [[YXKlineCalculateTool shareInstance] calAccessoryValue:self.klineModel];
    self.mainAccessoryStatus = status;
}

- (void)usmartDetailBtnClick:(UIButton *)sender {
    if (self.usmartLineCallBack) {
        self.usmartLineCallBack(2);
    }
}

#pragma mark - 查看历史分时相关

- (YXExpandAreaButton *)queryQuoteButton {
    if (!_queryQuoteButton) {
#ifdef IsHKApp
        _queryQuoteButton = [YXExpandAreaButton buttonWithType:(UIButtonTypeCustom) title:[YXLanguageUtility kLangWithKey:@"see_history_timeline"] font:[UIFont systemFontOfSize:10] titleColor:[UIColor whiteColor] target:self action:@selector(queryQuoteAction:)];
#else
        _queryQuoteButton = [YXExpandAreaButton buttonWithType:(UIButtonTypeCustom) title:@"查看当日分时" font:[UIFont systemFontOfSize:10] titleColor:[UIColor whiteColor] target:self action:@selector(queryQuoteAction:)];
#endif

        _queryQuoteButton.expandX = 5;
        _queryQuoteButton.expandY = 5;
        _queryQuoteButton.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
        _queryQuoteButton.backgroundColor = QMUITheme.themeTextColor;
        _queryQuoteButton.layer.cornerRadius = 2.0;
        _queryQuoteButton.hidden = YES;
    }
    return _queryQuoteButton;
}

- (void)queryQuoteAction:(UIButton *)sender {

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.showQuoteDetail = YES;
    self.queryQuoteButton.hidden = YES;
    self.titleGenerator.currentDateLabel.hidden = NO;
    self.refreshTime = 0;
    [self loadHistoryTimeLineData];
}

- (void)loadHistoryTimeLineData {

    self.refreshTime = CFAbsoluteTimeGetCurrent();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSTimeInterval interval = CFAbsoluteTimeGetCurrent();
        if (interval - self.refreshTime >= 0.1 && self.queryQuoteCallBack && self.longPressLocationIndex < self.klineModel.list.count) {
            YXKLine *model = self.klineModel.list[self.longPressLocationIndex];
            self.queryQuoteCallBack(self.klineModel, model, self.longPressLocationIndex);
        }
    });
}

//重置长按状态
- (void)resetLongPressState {
    self.showQuoteDetail = NO;
    //self.queryQuoteButton.hidden = NO;

    [self hideKlineLongPressView];
}

//布局查看分时按钮位置
- (void)showTimeLineQueryButton:(CGFloat)current_x {

    if (_queryQuoteButton.superview == nil) {
        [self addSubview:self.queryQuoteButton];
        [self.queryQuoteButton mas_makeConstraints:^(MASConstraintMaker *make) {

            make.centerX.equalTo(self.mas_left).offset(current_x).priorityMedium();
            make.top.equalTo(self.mas_top).offset( CGRectGetMaxY(self.candleRect));
            make.left.greaterThanOrEqualTo(self).priorityHigh();
            make.right.lessThanOrEqualTo(self).priorityHigh();
        }];
    } else {

        [self.queryQuoteButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_left).offset(current_x).priorityMedium();
        }];
    }
}

//移动长按十字线位置
- (void)moveCrossLineLayer:(BOOL)isLeftDirection {

    CGFloat flag = isLeftDirection ? -1 : 1;
    CGFloat oneCandleDistance = (self.candleWidth + self.space);
    CGPoint point = CGPointMake(self.lastLongPressPoint.x + flag * oneCandleDistance, self.lastLongPressPoint.y);

    if (point.x < self.scrollView.contentOffset.x + self.candleWidth * 0.5) {
        //此时需要移动右移scrollView

        NSInteger location = round(point.x / (self.candleWidth + self.space));
        CGFloat offsetX = location * (self.candleWidth + self.space);
        if (offsetX < 0) {
            offsetX = 0;
        }
        self.scrollView.contentOffset = CGPointMake(offsetX, self.scrollView.contentOffset.y);
    } else if(point.x > self.scrollView.contentOffset.x + CGRectGetWidth(self.candleRect) - self.candleWidth * 0.5) {
        //此时需要移动左移scrollView
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x + oneCandleDistance, self.scrollView.contentOffset.y);
    }

    if (self.scrollView.contentOffset.x < oneCandleDistance) {  //加载更多(分页)
        [self loadMoreData];
    }

    [self handleLongPressActionWithPoint: point isScroll:NO];
}


#pragma mark - other

//动态变更参数label
- (void)dynamicChangeAccessoryLabelWithIndex:(NSInteger)index{

    self.titleGenerator.market = _klineModel.market;
    self.titleGenerator.symbol = _klineModel.symbol;
    if (self.generator.crossLineLayer.hidden) {
        if (index < self.klineModel.list.count) {
            self.titleGenerator.klineModel = self.klineModel.list[index];
        }
    } else {
        if (self.longPressLocationIndex < self.klineModel.list.count) {
            self.titleGenerator.klineModel = self.klineModel.list[self.longPressLocationIndex];
        }
    }
}

//隐藏长按线
- (void)hideKlineLongPressView {

    self.generator.crossLineLayer.hidden = YES;
    self.titleGenerator.crossingLinePriceLabel.hidden = YES;
    self.titleGenerator.currentDateLabel.hidden = YES;

    //动态改变参数数值
    self.titleGenerator.market = _klineModel.market;
    self.titleGenerator.symbol = _klineModel.symbol;
    self.titleGenerator.klineModel = [self getVisibleArr].lastObject;
    self.isLongPressLatest = NO;

    _queryQuoteButton.hidden = YES;
    //长按结束消失
    if (self.klineLongPressEndCallBack) {
        self.klineLongPressEndCallBack();
    }
}

- (int)getMaxPriceValue {
    
    return self.maxHigh * self.priceBaseFullValue;
}

- (int)getminPriceValue {
    
    return self.minLow * self.priceBaseFullValue;
}


- (NSMutableArray<UILabel *> *)buyLabels {
    if (_buyLabels == nil) {
        _buyLabels = [[NSMutableArray alloc] init];
    }
    return _buyLabels;
}

- (NSMutableArray<UILabel *> *)sellLabels {
    if (_sellLabels == nil) {
        _sellLabels = [[NSMutableArray alloc] init];
    }
    return _sellLabels;
}
- (YXKlineAccessoryShadeView *)shadeView {
    if (_shadeView == nil) {
        _shadeView = [[YXKlineAccessoryShadeView alloc] initWithFrame:CGRectZero andStatus:YXKlineAccessoryShadeTypeUpdate];
        _shadeView.hidden = YES;
    }
    return _shadeView;
}

- (QMUIButton *)usmartDetailBtn {
    if (_usmartDetailBtn == nil) {
        _usmartDetailBtn = [QMUIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"webview_detailTitle"] font:[UIFont systemFontOfSize:10] titleColor:QMUITheme.themeTextColor target:self action:@selector(usmartDetailBtnClick:)];
        UIImage *image = [UIImage imageNamed:@"icon_blue_more"];
        [_usmartDetailBtn setImage:[image qmui_imageResizedInLimitedSize:CGSizeMake(12, 12)] forState:UIControlStateNormal];
        _usmartDetailBtn.hidden = YES;
        _usmartDetailBtn.imagePosition = QMUIButtonImagePositionRight;
        _usmartDetailBtn.spacingBetweenImageAndTitle = 2;
        _usmartDetailBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        _usmartDetailBtn.titleLabel.minimumScaleFactor = 0.3;
    }
    return _usmartDetailBtn;
}


@end

