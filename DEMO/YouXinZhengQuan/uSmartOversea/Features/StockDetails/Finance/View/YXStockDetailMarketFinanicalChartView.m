//
//  YXStockDetailMarketFinanicalChartView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockDetailMarketFinanicalChartView.h"
#import "YXLayerGenerator.h"
#import "YXStockDetailUtility.h"
#import "uSmartOversea-Swift.h"
#import <YYCategories/YYCategories.h>
#import "UILabel+create.h"
#import <Masonry/Masonry.h>

#define kFinancialChartViewHeight 148
#define kFinancialChartViewPaddingX 66
#define kFinancialChartViewCandleWidth 13

#define kFinancialChartFirstColor   [QMUITheme themeTextColor]

@interface YXStockDetailMarketFinanicalChartView ()


@property (nonatomic, assign) YXStockFinancialMarketType type;

@property (nonatomic, strong) UILabel *unitLabel;

@property (nonatomic, strong) UILabel *highestValueLabel;
@property (nonatomic, strong) UILabel *halfValueLabel;
@property (nonatomic, strong) UILabel *lowestValueLabel;

@property (nonatomic, strong) UILabel *highestRatioLabel;
@property (nonatomic, strong) UILabel *halfRatioLabel;
@property (nonatomic, strong) UILabel *lowestRatioLabel;

@property (nonatomic, strong) CAShapeLayer *blackLayer;
@property (nonatomic, strong) CAShapeLayer *redLayer;

@property (nonatomic, strong) CAShapeLayer *redCircleLayer;

@property (nonatomic, strong) UIView *lineContentLineView;

@property (nonatomic, strong) NSMutableArray <UILabel *> *dateListView;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;  //长按手势

@property (nonatomic, strong) UIView *pressBlockView;

@property (nonatomic, assign) CGFloat margin;

@property (nonatomic, strong) YXFinancialLongPressView *pressView;

@property (nonatomic, strong) UILabel *bottomLabel;

@property (nonatomic, strong) NSArray *titleArr;

@property (nonatomic, strong) UIButton *selectTypeBtn;

@property (nonatomic, strong) YXStockEmptyDataView *noDataView;

@property (nonatomic, strong) NSString *market;

@property (nonatomic, strong) YXStockFinancialPopoverButton *popoverButton;

@property (nonatomic, strong) UIColor *kFinancialChartThirdColor;

@end

@implementation YXStockDetailMarketFinanicalChartView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andMarket:(NSString *)market {
    if (self = [super initWithFrame:frame]) {
        self.market = market;
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {

    self.selectIndex = 0;
    UILabel *titleLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"main_indicators"] textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:20 weight:UIFontWeightMedium]];
    [self addSubview:titleLabel];

    NSString *str = [YXLanguageUtility kLangWithKey:@"per_share_cash_flow"];
    if ([self.market hasPrefix:@"sh"] || [self.market hasPrefix:@"sz"]) {
        str = [YXLanguageUtility kLangWithKey:@"per_share_operating_cash_flow"];
    }

    self.titleArr = @[@"ROE", @"ROA", @"PE", @"PB", @"EPS", [YXLanguageUtility kLangWithKey:@"per_share_net_assets"], str, [YXLanguageUtility kLangWithKey:@"per_share_revenue"]];

    NSString *unitString = [NSString stringWithFormat:@"%@: --", [YXLanguageUtility kLangWithKey:@"newStock_detail_stock_unit"]];
    self.unitLabel = [UILabel labelWithText: unitString textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    
    self.highestValueLabel = [UILabel labelWithText:@"0.00" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    self.halfValueLabel = [UILabel labelWithText:@"0.00" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    self.lowestValueLabel = [UILabel labelWithText:@"0.00" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    
    self.highestRatioLabel = [UILabel labelWithText:@"0.00" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    self.halfRatioLabel = [UILabel labelWithText:@"0.00" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    self.lowestRatioLabel = [UILabel labelWithText:@"0.00" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];

    self.kFinancialChartThirdColor = [UIColor qmui_colorWithHexString:@"#F9A800"];
    self.blackLayer = [[CAShapeLayer alloc] init];
    self.blackLayer.lineWidth = 0;
    self.blackLayer.fillColor = kFinancialChartFirstColor.CGColor;
    self.blackLayer.strokeColor = kFinancialChartFirstColor.CGColor;

    self.redLayer = [[CAShapeLayer alloc] init];
    self.redLayer.lineWidth = 0.8;
    self.redLayer.fillColor = UIColor.clearColor.CGColor;
    self.redLayer.strokeColor = self.kFinancialChartThirdColor.CGColor;

    self.redCircleLayer = [[CAShapeLayer alloc] init];
    self.redCircleLayer.lineWidth = 0;
    self.redCircleLayer.fillColor = self.kFinancialChartThirdColor.CGColor;
    self.redCircleLayer.strokeColor = self.kFinancialChartThirdColor.CGColor;
    
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.top.equalTo(self).offset(28);
        make.height.mas_equalTo(24);
    }];
    [self addSubview:self.unitLabel];
    [self.lineContentLineView.layer addSublayer:self.blackLayer];
    [self.lineContentLineView.layer addSublayer:self.redLayer];
    [self.lineContentLineView.layer addSublayer:self.redCircleLayer];
    
    [self addSubview:self.lineContentLineView];

    NSInteger count = 4;
    CGFloat buttonHeight = 30;
    CGFloat lineMargin = 18;
    CGFloat columnMargin = 10;

    CGFloat buttonWidth = (YXConstant.screenWidth - 32 - columnMargin * (count - 1)) * 1.0 / count;

    // 顶部的按钮
    for (int i = 0; i < self.titleArr.count; ++i) {
        QMUIButton *btn = [[QMUIButton alloc] init];
        [btn setTitle:self.titleArr[i] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 4;
        btn.clipsToBounds = YES;
        btn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.titleLabel.minimumScaleFactor = 0.6;
        btn.layer.cornerRadius = 4;
        btn.layer.borderColor = [QMUITheme.pointColor CGColor];
        btn.layer.borderWidth = 1.0;
        [btn setTitleColor:QMUITheme.mainThemeColor forState:UIControlStateSelected];
        [btn setTitleColor:[QMUITheme textColorLevel3] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage tabItemNoramalDynamicImage] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage tabItemSelectedDynamicImage] forState:UIControlStateSelected];
        btn.frame = CGRectMake(16 + (columnMargin + buttonWidth) * (i % count), 70 + (lineMargin + buttonHeight) * (i / count), buttonWidth, buttonHeight);
        [btn addTarget:self action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        if (i == 0) {
            self.selectTypeBtn = btn;
            btn.layer.borderColor = [[QMUITheme.themeTextColor colorWithAlphaComponent:0.1] CGColor];
            btn.selected = YES;
        }
        btn.tag = i;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.contentEdgeInsets = UIEdgeInsetsMake(3, 4, 3, 4);
    }
    
    [self addSubview:self.highestValueLabel];
    [self addSubview:self.halfValueLabel];
    [self addSubview:self.lowestValueLabel];
    [self addSubview:self.highestRatioLabel];
    [self addSubview:self.halfRatioLabel];
    [self addSubview:self.lowestRatioLabel];
    
    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.top.equalTo(self).offset(160);
        make.height.mas_equalTo(20);
    }];
    _unitLabel.hidden = YES;

    [self addSubview:self.popoverButton];
    [self.popoverButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-15);
        make.centerY.equalTo(self.unitLabel);
    }];

    [self.lineContentLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(kFinancialChartViewPaddingX);
        make.trailing.equalTo(self).offset(-kFinancialChartViewPaddingX);
        make.height.mas_equalTo(kFinancialChartViewHeight);
        make.top.equalTo(self).offset(193);
    }];

    [self.highestValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.top.equalTo(self.lineContentLineView.mas_top);
    }];
    
    [self.halfValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.centerY.equalTo(self.lineContentLineView.mas_centerY);
    }];
    
    [self.lowestValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.centerY.equalTo(self.lineContentLineView.mas_bottom);
    }];
    
    [self.highestRatioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-16);
        make.top.equalTo(self.lineContentLineView.mas_top);
    }];
    
    [self.halfRatioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-16);
        make.centerY.equalTo(self.halfValueLabel);
    }];
    
    [self.lowestRatioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-16);
        make.centerY.equalTo(self.lineContentLineView.mas_bottom);
    }];
    
    UIView *bottomView = [[UIView alloc] init];
    [self addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.lineContentLineView.mas_bottom).offset(38);
        make.height.mas_equalTo(20);
    }];
    
    
    // 创建底部的标识
    CGFloat width = 130;
    CGFloat padding = 22;
    CGFloat x = (YXConstant.screenWidth - width * 2 - padding) * 0.5 + 20;
    UIView *view1 = nil;
    UIView *view2 = nil;
    view1 = [self creatTypeViewWithTitle:@"ROE(%)" andColor:kFinancialChartFirstColor andIsSquare:YES];
    view2 = [self creatTypeViewWithTitle:[YXLanguageUtility kLangWithKey:@"yoy_growth_rate"] andColor:self.kFinancialChartThirdColor andIsSquare:NO];
    
    view1.frame = CGRectMake(x, 0, width, 20);
    view2.frame = CGRectMake(x + width + padding, 0, width, 20);
    [bottomView addSubview:view1];
    [bottomView addSubview:view2];
    
    CGFloat padding_x = kFinancialChartViewPaddingX;
    CGFloat dateWidth = (YXConstant.screenWidth - padding_x * 2) / 5.0;
    for (int i = 0; i < self.dateListView.count; ++i) {
        UILabel *label = self.dateListView[i];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(padding_x + dateWidth * i);
            make.top.equalTo(self.lineContentLineView.mas_bottom).offset(6);
            make.height.mas_equalTo(12);
            make.width.mas_equalTo(dateWidth);
        }];
    }
    
    [self addSubview:self.noDataView];
    
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.unitLabel.mas_bottom).offset(5);
        make.leading.trailing.bottom.equalTo(self);
    }];
    
    [self addSubview:self.pressView];
}

- (UIView *)creatTypeViewWithTitle: (NSString *)title andColor: (UIColor *)color andIsSquare:(BOOL)isSquare {
    
    UIView *view = [[UIView alloc] init];
    UIView *leftTypeView = [[UIView alloc] init];
    leftTypeView.backgroundColor = color;
    
    UILabel *label = [UILabel labelWithText:title textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular]];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.3;
    [view addSubview:leftTypeView];
    [view addSubview:label];
    
    [leftTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view);
        make.width.mas_equalTo(isSquare ? 8 : 12);
        make.centerY.equalTo(view);
        make.height.mas_equalTo(isSquare ? 8 : 2);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view);
        make.leading.equalTo(leftTypeView.mas_trailing).offset(5);
        make.trailing.equalTo(view);
    }];
    
    if (isSquare) {
        self.bottomLabel = label;
        leftTypeView.layer.cornerRadius = 2.0;
    }
    
    return view;
}

- (void)typeBtnClick:(UIButton *)sender {
    if (sender.isSelected) {
        return;
    }
    sender.selected = YES;
    sender.layer.borderColor = [[QMUITheme.themeTextColor colorWithAlphaComponent:0.1] CGColor];
    self.selectTypeBtn.selected = NO;
    self.selectTypeBtn.layer.borderColor = [QMUITheme.pointColor CGColor];
    self.selectTypeBtn = sender;
    
    self.type = sender.tag;
    [self reloadChart];
    [self hideKlineLongPressView];
    
    if (self.type > 3) {
        _unitLabel.hidden = NO;
    } else {
        _unitLabel.hidden = YES;
    }
    
    if (self.clickTypeBtnCallBack) {
        self.clickTypeBtnCallBack(self.type);
    }
}

- (void)setList:(NSArray<YXFinancialMarketDetaiModel *> *)list {
    _list = [[list reverseObjectEnumerator] allObjects];
    if (_list.count == 0) {
        self.noDataView.hidden = NO;
        return;
    }
    self.noDataView.hidden = YES;
    [self reloadChart];
}

- (void)reloadChart {
    
    self.blackLayer.path = nil;
    self.redLayer.path = nil;
    self.redCircleLayer.path = nil;
    NSString *str = self.titleArr[self.type];
    NSString *title = str;
    if (self.type == YXStockFinancialMarketTypeROE || self.type == YXStockFinancialMarketTypeROA) {
        title = [NSString stringWithFormat:@"%@(%%)", str];
    }

    // 日期
    for (int i = 0; i < self.dateListView.count; i ++) {
        UILabel *dateLabel = self.dateListView[i];
        dateLabel.text = @"";
    }
    
    self.bottomLabel.text = title;
    [self drawProfit];
}

- (void)drawProfit {
    CGFloat padding_x = kFinancialChartViewPaddingX;
    CGFloat margin = (YXConstant.screenWidth - padding_x * 2 - kFinancialChartViewCandleWidth * 5.0) / 5.0;
    self.margin = margin;
    UIBezierPath *blackPath = [[UIBezierPath alloc] init];
    UIBezierPath *redPath = [[UIBezierPath alloc] init];
    
    UIBezierPath *redCirclePath = [[UIBezierPath alloc] init];
    
    float maxRato = 0.0;
    float minRato = 0.0;
    
    float maxValue = 0.0;
    float midValue = 0.0;
    float minValue = 0.0;
    if (self.type == YXStockFinancialMarketTypeROE) {
        maxValue = [[_list valueForKeyPath:@"@max.roe_annual"] doubleValue];
        minValue = [[_list valueForKeyPath:@"@min.roe_annual"] doubleValue];
        maxRato = [[_list valueForKeyPath:@"@max.roe_annual_yoy"] doubleValue];
        minRato = [[_list valueForKeyPath:@"@min.roe_annual_yoy"] doubleValue];
        self.unitLabel.hidden = YES;
    } else if (self.type == YXStockFinancialMarketTypeROA) {
        maxValue = [[_list valueForKeyPath:@"@max.roa_annual"] doubleValue];
        minValue = [[_list valueForKeyPath:@"@min.roa_annual"] doubleValue];
        maxRato = [[_list valueForKeyPath:@"@max.roa_annual_yoy"] doubleValue];
        minRato = [[_list valueForKeyPath:@"@min.roa_annual_yoy"] doubleValue];
        self.unitLabel.hidden = YES;
    } else if (self.type == YXStockFinancialMarketTypePE) {
        maxValue = [[_list valueForKeyPath:@"@max.pe_annual"] doubleValue];
        minValue = [[_list valueForKeyPath:@"@min.pe_annual"] doubleValue];
        maxRato = [[_list valueForKeyPath:@"@max.pe_annual_yoy"] doubleValue];
        minRato = [[_list valueForKeyPath:@"@min.pe_annual_yoy"] doubleValue];
        self.unitLabel.hidden = YES;
    } else if (self.type == YXStockFinancialMarketTypePB) {
        maxValue = [[_list valueForKeyPath:@"@max.pb_annual"] doubleValue];
        minValue = [[_list valueForKeyPath:@"@min.pb_annual"] doubleValue];
        maxRato = [[_list valueForKeyPath:@"@max.pb_annual_yoy"] doubleValue];
        minRato = [[_list valueForKeyPath:@"@min.pb_annual_yoy"] doubleValue];
        self.unitLabel.hidden = YES;
    } else if (self.type == YXStockFinancialMarketTypeEPS) {
        maxValue = [[_list valueForKeyPath:@"@max.eps_annual"] doubleValue];
        minValue = [[_list valueForKeyPath:@"@min.eps_annual"] doubleValue];
        maxRato = [[_list valueForKeyPath:@"@max.eps_annual_yoy"] doubleValue];
        minRato = [[_list valueForKeyPath:@"@min.eps_annual_yoy"] doubleValue];
        self.unitLabel.hidden = NO;
    } else if (self.type == YXStockFinancialMarketTypeBPS) {
        maxValue = [[_list valueForKeyPath:@"@max.bps_annual"] doubleValue];
        minValue = [[_list valueForKeyPath:@"@min.bps_annual"] doubleValue];
        maxRato = [[_list valueForKeyPath:@"@max.bps_annual_yoy"] doubleValue];
        minRato = [[_list valueForKeyPath:@"@min.bps_annual_yoy"] doubleValue];
        self.unitLabel.hidden = NO;
    } else if (self.type == YXStockFinancialMarketTypeOCFPS) {
        maxValue = [[_list valueForKeyPath:@"@max.ocfps_annual"] doubleValue];
        minValue = [[_list valueForKeyPath:@"@min.ocfps_annual"] doubleValue];
        maxRato = [[_list valueForKeyPath:@"@max.ocfps_annual_yoy"] doubleValue];
        minRato = [[_list valueForKeyPath:@"@min.ocfps_annual_yoy"] doubleValue];
        self.unitLabel.hidden = NO;
    } else if (self.type == YXStockFinancialMarketTypeGRPS) {
        maxValue = [[_list valueForKeyPath:@"@max.grps_annual"] doubleValue];
        minValue = [[_list valueForKeyPath:@"@min.grps_annual"] doubleValue];
        maxRato = [[_list valueForKeyPath:@"@max.grps_annual_yoy"] doubleValue];
        minRato = [[_list valueForKeyPath:@"@min.grps_annual_yoy"] doubleValue];
        self.unitLabel.hidden = NO;
    }
    
    CGFloat zeroY = kFinancialChartViewHeight;
    if (maxValue >=0 && minValue >= 0) {
        minValue = 0;
        midValue = maxValue * 0.5;
    } else if (maxValue >= 0 && minValue < 0) {
        midValue = 0;
        midValue = maxValue + (minValue - maxValue) * 0.5;
        zeroY = [YXKLineUtility getYCoordinateWithMaxPrice:maxValue minPrice:minValue price:0 distance:kFinancialChartViewHeight zeroY:kFinancialChartViewHeight];
    } else if (maxValue < 0 && minValue < 0) {
        maxValue = 0;
        midValue = minValue * 0.5;
        zeroY = 0;
    }
    
    if (maxRato > 0 && minRato > 0) {
        minRato = 0.0;
    }
    
    // 最大值等于最小值, 不画
    if (minValue == maxValue) {
        return;
    }
    
    for (int i = 0; i < _list.count; ++i) {
        YXFinancialMarketDetaiModel *model = _list[i];
        CGFloat firstPointY = 0;
        CGFloat firstHeight = 0;
        
        float firstValue = 0;
        float firstRatoValue = 0;
        
        if (self.type == YXStockFinancialMarketTypeROE) {
            firstValue = model.roe_annual;
            firstRatoValue = model.roe_annual_yoy;
        } else if (self.type == YXStockFinancialMarketTypeROA) {
            firstValue = model.roa_annual;
            firstRatoValue = model.roa_annual_yoy;
        } else if (self.type == YXStockFinancialMarketTypePE) {
            firstValue = model.pe_annual;
            firstRatoValue = model.pe_annual_yoy;
        } else if (self.type == YXStockFinancialMarketTypePB) {
            firstValue = model.pb_annual;
            firstRatoValue = model.pb_annual_yoy;
        } else if (self.type == YXStockFinancialMarketTypeEPS) {
            firstValue = model.eps_annual;
            firstRatoValue = model.eps_annual_yoy;
        } else if (self.type == YXStockFinancialMarketTypeBPS) {
            firstValue = model.bps_annual;
            firstRatoValue = model.bps_annual_yoy;
        } else if (self.type == YXStockFinancialMarketTypeOCFPS) {
            firstValue = model.ocfps_annual;
            firstRatoValue = model.ocfps_annual_yoy;
        } else if (self.type == YXStockFinancialMarketTypeGRPS) {
            firstValue = model.grps_annual;
            firstRatoValue = model.grps_annual_yoy;
        }
        
        if (maxValue == 0) {
            firstPointY = 0;
            firstHeight = [YXKLineUtility getYCoordinateWithMaxPrice:maxValue minPrice:minValue price:firstValue distance:kFinancialChartViewHeight zeroY:kFinancialChartViewHeight];
        } else if (maxValue >= 0 && minValue < 0) {
            if (firstValue >= 0) {
                firstPointY = [YXKLineUtility getYCoordinateWithMaxPrice:maxValue minPrice:0 price:firstValue distance: zeroY zeroY:zeroY];
                firstHeight = zeroY - firstPointY;
            } else {
                firstHeight = [YXKLineUtility getYCoordinateWithMaxPrice:0 minPrice:minValue price:firstValue distance: kFinancialChartViewHeight - zeroY zeroY: kFinancialChartViewHeight - zeroY];
                firstPointY = zeroY;
            }
        } else {
            firstPointY = [YXKLineUtility getYCoordinateWithMaxPrice:maxValue minPrice:minValue price:firstValue distance: kFinancialChartViewHeight zeroY:kFinancialChartViewHeight];
            firstHeight = kFinancialChartViewHeight - firstPointY;
        }
        
        // 折线
        CGFloat ratoPointY = 0;
        ratoPointY = [YXKLineUtility getYCoordinateWithMaxPrice:maxRato minPrice:minRato price:firstRatoValue distance:kFinancialChartViewHeight zeroY:kFinancialChartViewHeight];

        CGFloat x = margin / 2.0 + (kFinancialChartViewCandleWidth + margin) * i;
        UIBezierPath *firstPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, firstPointY, kFinancialChartViewCandleWidth, firstHeight) cornerRadius:2];
        
        if (i == 0) {
            [redPath moveToPoint:CGPointMake(x + kFinancialChartViewCandleWidth / 2.0, ratoPointY)];
        } else {
            [redPath addLineToPoint:CGPointMake(x + kFinancialChartViewCandleWidth / 2.0, ratoPointY)];
        }
        
        // 添加圆点
//        UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(padding_x + margin * i - kFinancialChartViewCandleWidth * 0.5 - 2, ratoPointY - 2, 4, 4) cornerRadius:2];
//        [redCirclePath appendPath:circlePath];
        
        [blackPath appendPath:firstPath];
        
        // 日期
        if (i < self.dateListView.count) {
            UILabel *dateLabel = self.dateListView[i];
            dateLabel.text = [NSString stringWithFormat:@"%zd", model.year];
        }
        
    }
    
    float unit = 1.0;
    
    float max = maxValue / unit;
    self.highestValueLabel.text = [NSString stringWithFormat:@"%.2f", max];
    
    float mid = midValue / unit;
    self.halfValueLabel.text = [NSString stringWithFormat:@"%.2f", mid];
    
    float min = minValue / unit;
    self.lowestValueLabel.text = [NSString stringWithFormat:@"%.2f", (min)];
    
    float midRato = (maxRato + minRato) * 0.5;
    self.highestRatioLabel.text = [NSString stringWithFormat:@"%.2f%@", maxRato * 100, @"%"];
    self.lowestRatioLabel.text = [NSString stringWithFormat:@"%.2f%@", minRato * 100, @"%"];
    self.halfRatioLabel.text = [NSString stringWithFormat:@"%.2f%@", midRato * 100, @"%"];
    
    // 单位相同, 隐藏
    if (maxRato == minRato) {
        self.highestRatioLabel.hidden = YES;
    } else {
        self.highestRatioLabel.hidden = NO;
    }
    if (minRato == midRato) {
        self.halfRatioLabel.hidden = YES;
    } else {
        self.halfRatioLabel.hidden = NO;
    }
    // 单位名字
    NSString *unitStr;
    if (self.list.lastObject.crncy_code == 1) {
        unitStr = [YXLanguageUtility kLangWithKey:@"common_rmb2"];
    } else if (self.list.lastObject.crncy_code == 2) {
        unitStr = [YXLanguageUtility kLangWithKey:@"common_us_dollar"];
    } else {
        unitStr = [YXLanguageUtility kLangWithKey:@"common_hk_dollar"];
    }
    NSString *unitString = [NSString stringWithFormat:@"%@: %@", [YXLanguageUtility kLangWithKey:@"newStock_detail_stock_unit"], unitStr];
    self.unitLabel.text = unitString;
    
    self.blackLayer.path = blackPath.CGPath;
    self.redLayer.path = redPath.CGPath;
    self.redCircleLayer.path = redCirclePath.CGPath;
}


#pragma mark - action
- (void)longPressGestureRecognizerAction:(UILongPressGestureRecognizer *)gesture {
    
    if (self.list.count == 0) {
        return;
    }
    CGPoint point = [gesture locationInView:self.lineContentLineView];
    CGFloat calculateWidth = self.margin + kFinancialChartViewCandleWidth;
    NSInteger index = point.x / calculateWidth;
    if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateBegan) {
        
        if (index > self.list.count - 1) {
            index = self.list.count - 1;
        }
        CGFloat centerX = calculateWidth * index + calculateWidth / 2.0;
        self.pressBlockView.mj_x = centerX - self.pressBlockView.mj_w * 0.5;
        self.pressBlockView.hidden = NO;
        
        CGFloat pressViewX;
        if (index < 2) {
            pressViewX = centerX + kFinancialChartViewCandleWidth + 10;
        } else {
            pressViewX = centerX - kFinancialChartViewCandleWidth - self.pressView.mj_w - 10;
        }
        
        YXFinancialMarketDetaiModel *model = self.list[index];
        [self.lineContentLineView bringSubviewToFront:self.pressView];
        self.pressView.mj_x = pressViewX + self.lineContentLineView.frame.origin.x;
        self.pressView.mj_y = self.lineContentLineView.frame.origin.y;
        self.pressView.hidden = NO;
        self.pressView.marketType = self.type;
        self.pressView.marketModel = model;
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self performSelector:@selector(hideKlineLongPressView) withObject:nil afterDelay:3.0];
    }
}

//隐藏长按线
- (void)hideKlineLongPressView {
    self.pressBlockView.hidden = YES;
    self.pressView.hidden = YES;
}


#pragma mark - 懒加载
- (UIView *)lineContentLineView {
    if (_lineContentLineView == nil) {
        _lineContentLineView = [[UIView alloc] initWithFrame:CGRectMake(16, 123, YXConstant.screenWidth - 32, kFinancialChartViewHeight)];
        UIView *bottomLineView = [[UIView alloc] init];
        bottomLineView.backgroundColor = QMUITheme.pointColor;
        [_lineContentLineView addSubview:bottomLineView];

        [_lineContentLineView addSubview:self.pressBlockView];

        [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_lineContentLineView);
            make.leading.equalTo(_lineContentLineView);
            make.trailing.equalTo(_lineContentLineView);
            make.height.mas_equalTo(1);
        }];

        //手势事件
        [_lineContentLineView addGestureRecognizer:self.longPressGestureRecognizer];
    }
    return _lineContentLineView;
}

- (NSMutableArray<UILabel *> *)dateListView {
    if (_dateListView == nil) {
        _dateListView = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 5; ++i) {
            UILabel *label = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
            label.textAlignment = NSTextAlignmentCenter;
            [_dateListView addObject:label];
        }
    }
    return _dateListView;
}

- (UIView *)pressBlockView {
    if (_pressBlockView == nil) {
        _pressBlockView = [[UIView alloc] initWithFrame:CGRectMake(0, -10, kFinancialChartViewCandleWidth * 2, kFinancialChartViewHeight + 10)];
        _pressBlockView.backgroundColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.04];
        _pressBlockView.hidden = YES;
    }
    return _pressBlockView;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
    }
    return _longPressGestureRecognizer;
}

- (YXFinancialLongPressView *)pressView {
    if (_pressView == nil) {
        
        CGFloat width = 137;
        if (YXUserManager.curLanguage == YXLanguageTypeTH) {
            width = 180;
        }
        
        _pressView = [[YXFinancialLongPressView alloc] initWithFrame:CGRectMake(0, 0, 137, 70)];
        _pressView.backgroundColor = QMUITheme.foregroundColor;
        _pressView.hidden = YES;
        _pressView.market = self.market;
        _pressView.marketType = self.type;
    }
    return _pressView;
}


- (YXStockEmptyDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[YXStockEmptyDataView alloc] init];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

- (YXStockFinancialPopoverButton *)popoverButton {
    if (!_popoverButton) {

        _popoverButton = [[YXStockFinancialPopoverButton alloc] init];
        @weakify(self)
        _popoverButton.clickItemBlock = ^(NSInteger selectIndex) {
            @strongify(self)
            self.selectIndex = selectIndex;
            if (self.clickItemBlock) {
                self.clickItemBlock(selectIndex);
            }

            self.pressView.currentTitle = self.popoverButton.titleLabel.text;
        };
    }
    return _popoverButton;
}



@end
