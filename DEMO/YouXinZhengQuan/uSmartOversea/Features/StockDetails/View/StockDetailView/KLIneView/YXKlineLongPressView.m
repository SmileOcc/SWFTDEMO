//
//  YXKlineLongPressView.m
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/11/26.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXKlineLongPressView.h"
#import "YXStockDetailLongPressSubLabel.h"
#import "YXDateToolUtility.h"
#import <Masonry/Masonry.h>
#import "UILabel+create.h"
#import "YXToolUtility.h"
#import "uSmartOversea-Swift.h"



#define yxPressSize(x) ((x)*([UIScreen mainScreen].bounds.size.width/375.0))

@interface YXKlineLongPressView ()

@property (nonatomic, strong) UILabel *klineDateLabel; //日期label
@property (nonatomic, strong) NSArray *parameterLabelArr; //参数标签数组

@property (nonatomic, assign) CGFloat padding_y;
@end

@implementation YXKlineLongPressView

- (instancetype)initWithFrame:(CGRect)frame andType:(YXKlineScreenOrientType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.oritentType = type;
        //[self initUI];
    }
    return self;
}

- (void)setUpUI {

    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    self.backgroundColor = QMUITheme.foregroundColor;
    //标签
    [self addSubview:self.klineDateLabel];

    [self.klineDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.oritentType == YXKlineScreenOrientTypeRight) {
            make.left.equalTo(self).offset(12);
            make.top.mas_equalTo(self.mas_top).offset(8);
        } else {
            make.left.equalTo(self).offset(16);
            make.top.mas_equalTo(self.mas_top).offset(12);
            make.height.mas_equalTo(20);
        }
    }];
    self.padding_y = 5;
    
    [self setParametersArr];
    //参数
    CGFloat height = 28;
    CGFloat margin = 15;
    NSInteger maxColumn = 2;
    CGFloat padding_x = 16;
    CGFloat width = 100;
    CGFloat topMargin = 40;
    if (_oritentType == YXKlineScreenOrientTypePortrait) {
        width = (YXConstant.screenWidth - padding_x * 2 - margin * (maxColumn - 1)) / maxColumn;
    } else {
        padding_x = 12;
        maxColumn = 4;
        margin = 40;
        if ([self.market isEqualToString:kYXMarketCryptos]) {
            margin = 20;
        }
        topMargin = 26;
        width = (YXConstant.screenHeight - YXConstant.navBarPadding - padding_x - 26 - margin * (maxColumn - 1)) / maxColumn;
    }
    for (int x = 0; x < self.parameterLabelArr.count; x ++) {
        YXStockDetailLongPressSubLabel *paraLabel = self.parameterLabelArr[x];
        paraLabel.margin = 8;
        NSInteger line = x / maxColumn;
        NSInteger column = x % maxColumn;
        [self addSubview:paraLabel];
        paraLabel.frame = CGRectMake(padding_x + (width + margin) * column, topMargin + height * line, width, height);
    }

    UIView *lastView = self.parameterLabelArr.lastObject;
    [self addSubview:self.orderDetailView];
    [self addSubview:self.companyActionView];
    [self.orderDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastView.mas_bottom).offset(10);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(0);
    }];

    [self.companyActionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.height.mas_equalTo(0);
        make.left.right.equalTo(self);
        make.top.equalTo(self.orderDetailView.mas_bottom);
    }];
}


- (void)updateGemUI {
    [self setUpUI];
}

#pragma mark - lazy load
- (UILabel *)klineDateLabel{
    
    if (!_klineDateLabel) {
        _klineDateLabel  = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium]];
    }
    return _klineDateLabel;
    
}

- (void)setParametersArr {
    
    _parameterLabelArr = nil;
    NSMutableArray *titleArr;
    if (self.oritentType == YXKlineScreenOrientTypePortrait) {
        titleArr = [@[[YXLanguageUtility kLangWithKey:@"stock_detail_monthly_opening"],
                      [YXLanguageUtility kLangWithKey:@"stock_detail_high"],
                      [YXLanguageUtility kLangWithKey:@"market_change"],
                      [YXLanguageUtility kLangWithKey:@"stock_detail_monthly_closing"],
                      [YXLanguageUtility kLangWithKey:@"stock_detail_low"],
                      [YXLanguageUtility kLangWithKey:@"market_roc"],
                      [YXLanguageUtility kLangWithKey:@"market_volume"],
                      [YXLanguageUtility kLangWithKey:@"market_amount"]] mutableCopy];
    } else {
        titleArr = [@[[YXLanguageUtility kLangWithKey:@"stock_detail_monthly_opening"],
                      [YXLanguageUtility kLangWithKey:@"stock_detail_high"],
                      [YXLanguageUtility kLangWithKey:@"market_change"],
                      [YXLanguageUtility kLangWithKey:@"market_volume"],
                      [YXLanguageUtility kLangWithKey:@"stock_detail_monthly_closing"],
                      [YXLanguageUtility kLangWithKey:@"stock_detail_low"],
                      [YXLanguageUtility kLangWithKey:@"market_roc"],
                      [YXLanguageUtility kLangWithKey:@"market_amount"]] mutableCopy];
    }
    
    if (_isGem) {
        [titleArr addObjectsFromArray:@[[YXLanguageUtility kLangWithKey:@"stockdetail_post_volume"],
                                        [YXLanguageUtility kLangWithKey:@"stockdetail_post_anount"]]];
    }
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int x = 0; x < titleArr.count; x ++) {
        YXStockDetailLongPressSubLabel *paraLabel = [[YXStockDetailLongPressSubLabel alloc] init];
        paraLabel.titleLabel.text = titleArr[x];
        paraLabel.paraLabel.text = @"";
        [tempArray addObject:paraLabel];
    }
    _parameterLabelArr = tempArray;
}

#pragma mark - set赋值
- (void)setKLineSingleModel:(YXKLine *)kLineSingleModel{
    
    _kLineSingleModel = kLineSingleModel;
    //时间
    if (self.showFullTime) {
        _klineDateLabel.text = kLineSingleModel.latestTime.value > 0 ? [YXDateHelper commonDateStringWithNumber:kLineSingleModel.latestTime.value format:YXCommonDateFormatDF_MDYHM scaleType:YXCommonDateScaleTypeScale showWeek:NO] : @"--";
    } else {
        _klineDateLabel.text = kLineSingleModel.latestTime.value > 0 ? [YXDateHelper commonDateStringWithNumber:kLineSingleModel.latestTime.value format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:YES] : @"--";
    }
    
    //红涨绿跌
    YXStockDetailLongPressSubLabel *openLabel;
    YXStockDetailLongPressSubLabel *closeLabel;
    YXStockDetailLongPressSubLabel *highLabel;
    YXStockDetailLongPressSubLabel *lowLabel;
    YXStockDetailLongPressSubLabel *rocLabel;
    YXStockDetailLongPressSubLabel *postChangeLabel;
    YXStockDetailLongPressSubLabel *postRocLabel;
    
    UIColor *changeColor = [YXToolUtility changeColor:kLineSingleModel.netchng.value];
    
    NSInteger priceBase = kLineSingleModel.priceBase.value;
    BOOL isCryptos = [self.market isEqualToString:kYXMarketCryptos];
    //指标赋值
    for (int x = 0; x < _parameterLabelArr.count; x ++) {
        YXStockDetailLongPressSubLabel *label = _parameterLabelArr[x];
        if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"stock_detail_monthly_opening"]]) {

            if (isCryptos) {
                label.paraLabel.text = [YXToolUtility btNumberString:kLineSingleModel.open.stringValue decimalPoint:self.decimalCount isVol:NO showPlus:NO];
            } else {
                label.paraLabel.text = [YXToolUtility stockPriceData:kLineSingleModel.open.value deciPoint:priceBase priceBase:priceBase];
            }

            if (kLineSingleModel.open.value <= 0.0) {
                label.paraLabel.text = @"--";
            }
            openLabel = label;
        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"stock_detail_monthly_closing"]]) {

            if (isCryptos) {
                label.paraLabel.text = [YXToolUtility btNumberString:kLineSingleModel.close.stringValue decimalPoint:self.decimalCount isVol:NO showPlus:NO];
            } else {
                label.paraLabel.text = [YXToolUtility stockPriceData:kLineSingleModel.close.value deciPoint:priceBase priceBase:priceBase];
                if (kLineSingleModel.close.value <= 0.0) {
                    label.paraLabel.text = @"--";
                }
            }

            closeLabel = label;
        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"stock_detail_high"]]) {

            if (isCryptos) {
                label.paraLabel.text = [YXToolUtility btNumberString:kLineSingleModel.high.stringValue decimalPoint:self.decimalCount isVol:NO showPlus:NO];
            } else {
                label.paraLabel.text = [YXToolUtility stockPriceData:kLineSingleModel.high.value deciPoint:priceBase priceBase:priceBase];
                if (kLineSingleModel.high.value <= 0.0) {
                    label.paraLabel.text = @"--";
                }
            }

            highLabel = label;
        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"stock_detail_low"]]) {

            if (isCryptos) {
                label.paraLabel.text = [YXToolUtility btNumberString:kLineSingleModel.low.stringValue decimalPoint:self.decimalCount isVol:NO showPlus:NO];
            } else {
                label.paraLabel.text = [YXToolUtility stockPriceData:kLineSingleModel.low.value deciPoint:priceBase priceBase:priceBase];
                if (kLineSingleModel.low.value <= 0.0) {
                    label.paraLabel.text = @"--";
                }
            }

            lowLabel = label;
        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"market_change"]]) {
            
            //涨跌额
            if (isCryptos) {
                label.paraLabel.text = [YXToolUtility btNumberString:kLineSingleModel.netchng.stringValue decimalPoint:self.decimalCount isVol:NO showPlus:NO];
            } else {
                NSString *change= [YXToolUtility stockPriceData:kLineSingleModel.netchng.value deciPoint:priceBase priceBase:priceBase];
                if (kLineSingleModel.netchng.value > 0) {
                    label.paraLabel.text = [NSString stringWithFormat:@"+%@", change];
                } else if (kLineSingleModel.netchng.value < 0) {
                    label.paraLabel.text = [NSString stringWithFormat:@"%@", change];
                } else{
                    label.paraLabel.text = change;
                }
                if (kLineSingleModel && kLineSingleModel.netchng.value == 0.00) {
                    label.paraLabel.text = @"0.000";
                }
            }

            label.paraLabel.textColor = changeColor;
        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"market_roc"]]) {
            
            //涨跌幅
            if (isCryptos) {
                double value = kLineSingleModel.pctchng.stringValue.doubleValue;
                NSString *plusString = value > 0 ? @"+" : @"";
                label.paraLabel.text = [NSString stringWithFormat:@"%@%@%%",plusString, kLineSingleModel.pctchng.stringValue];
            } else {
                NSString *roc= [YXToolUtility stockPercentData:kLineSingleModel.pctchng.value priceBasic:2 deciPoint:2];
                label.paraLabel.text = kLineSingleModel.pctchng != nil ? [NSString stringWithFormat:@"%@%@", roc, @""] : @"--";
                if (kLineSingleModel && kLineSingleModel.pctchng.value == 0.00) {
                    label.paraLabel.text = @"0.00%";
                }
            }

            rocLabel = label;
        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"market_volume"]]) {

            NSString *unitString = [YXLanguageUtility kLangWithKey:@"stock_unit_en"];
            if ([self.market isEqualToString:kYXMarketUsOption]) {
                unitString = [YXLanguageUtility kLangWithKey:@"options_page"];
            }
            if (isCryptos) {
                label.paraLabel.text = [NSString stringWithFormat:@"%@%@", [YXToolUtility btNumberString:kLineSingleModel.volume.stringValue decimalPoint:self.decimalCount isVol:YES showPlus:NO], unitString];
            } else {
                label.paraLabel.text = [YXToolUtility stockData:kLineSingleModel.volume.value deciPoint:2 stockUnit:unitString priceBase:0];
            }

        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"market_amount"]]) {

            if (isCryptos) {
                label.paraLabel.text = [YXToolUtility btNumberString:kLineSingleModel.amount.stringValue decimalPoint:self.decimalCount isVol:YES showPlus:NO];
            } else {
                label.paraLabel.text = [YXToolUtility stockData:kLineSingleModel.amount.value deciPoint:2 stockUnit:@"" priceBase:priceBase];
            }

        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"stockdetail_post_volume"]]) {

            label.paraLabel.text = [YXToolUtility stockData:kLineSingleModel.postVolume.value deciPoint:2 stockUnit:[YXLanguageUtility kLangWithKey:@"stock_unit_en"] priceBase:0];
            postChangeLabel = label;
        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"stockdetail_post_anount"]]) {

            label.paraLabel.text = [YXToolUtility stockData:kLineSingleModel.postAmount.value deciPoint:2 stockUnit:@"" priceBase:priceBase];
            postRocLabel = label;
        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"high_24"]]) {

            label.paraLabel.text = [YXToolUtility btNumberString:kLineSingleModel.high.stringValue decimalPoint:self.decimalCount isVol:NO showPlus:NO];
            highLabel = label;
        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"open_24"]]) {

            label.paraLabel.text = [YXToolUtility btNumberString:kLineSingleModel.open.stringValue decimalPoint:self.decimalCount isVol:NO showPlus:NO];
            openLabel = label;
        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"low_24"]]) {

            label.paraLabel.text = [YXToolUtility btNumberString:kLineSingleModel.low.stringValue decimalPoint:self.decimalCount isVol:NO showPlus:NO];
            lowLabel = label;
        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"volumn_24"]]) {

            label.paraLabel.text = [YXToolUtility btNumberString:kLineSingleModel.volume.stringValue decimalPoint:self.decimalCount isVol:YES showPlus:NO];
        } else if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"amount_24"]]) {

            label.paraLabel.text = [YXToolUtility btNumberString:kLineSingleModel.amount.stringValue decimalPoint:self.decimalCount isVol:YES showPlus:NO];
        }
    }
    
    

    
    rocLabel.paraLabel.textColor = changeColor;
    
    postChangeLabel.textColor = changeColor;
    postRocLabel.textColor = changeColor;
    
    highLabel.paraLabel.textColor = [YXToolUtility priceTextColor:kLineSingleModel.high.value comparedData:kLineSingleModel.preClose.value];;
    lowLabel.paraLabel.textColor = [YXToolUtility priceTextColor:kLineSingleModel.low.value comparedData:kLineSingleModel.preClose.value];
    openLabel.paraLabel.textColor = [YXToolUtility priceTextColor:kLineSingleModel.open.value comparedData:kLineSingleModel.preClose.value];
    closeLabel.paraLabel.textColor = [YXToolUtility priceTextColor:kLineSingleModel.close.value comparedData:kLineSingleModel.preClose.value];

    [self handleKlineEvent];
    
}

- (void)handleKlineEvent {
    YXKLineInsideEvent *orderEvent = nil;
    YXKLineInsideEvent *dividendsEvent = nil;
    YXKLineInsideEvent *financialEvent = nil;

    if ([YXKLineConfigManager shareInstance].showBuySellPoint || [YXKLineConfigManager shareInstance].showCompanyActionPoint) {

        if (_kLineSingleModel.klineEvents.count > 0) {
            for (YXKLineInsideEvent *event in _kLineSingleModel.klineEvents) {
                if ([YXKLineConfigManager shareInstance].showBuySellPoint && event.type.value == 0 && (event.bought.count > 0 || event.sold.count > 0)) {
                    orderEvent = event;
                } else if ([YXKLineConfigManager shareInstance].showCompanyActionPoint && event.type.value == 1 && event.context.length > 0) {
                    financialEvent = event;
                } else if ([YXKLineConfigManager shareInstance].showCompanyActionPoint && event.type.value == 2 && event.context.length > 0) {
                    dividendsEvent = event;
                }
            }
        }
    }

    if (orderEvent.bought.count > 0 || orderEvent.sold.count > 0) {
        self.orderDetailView.hidden = NO;
        if (self.oritentType == YXKlineScreenOrientTypePortrait) {
            [self.orderDetailView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(30);
            }];
        } else {
            [self.orderDetailView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(20);
            }];
        }
        self.orderDetailView.market = self.market;
        self.orderDetailView.kLineSingleModel = _kLineSingleModel;

    } else {
        self.orderDetailView.hidden = YES;
        [self.orderDetailView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }

    if (dividendsEvent || financialEvent) {
        self.companyActionView.hidden = NO;
        if (self.orderDetailView.hidden == NO) {
            self.companyActionView.lineView.hidden = NO;
        } else {
            self.companyActionView.lineView.hidden = YES;
        }
        [self.companyActionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(25);
        }];

        NSMutableArray *array = [NSMutableArray array];
        if (financialEvent) {
            [array addObject:financialEvent];
        }

        if (dividendsEvent) {
            [array addObject:dividendsEvent];
        }

        YXDateModel *model = [YXDateToolUtility dateTimeWithTimeValue:_kLineSingleModel.latestTime.value];
        self.companyActionView.dateString = [NSString stringWithFormat:@"%@-%@-%@", model.year, model.month, model.day];
        self.companyActionView.market = self.market;
        self.companyActionView.events = array;

    } else {
        self.companyActionView.hidden = YES;
        [self.companyActionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

// 隐藏成交量
- (void)hiddenVolume {

    for (int x = 0; x < _parameterLabelArr.count; x ++) {
        YXStockDetailLongPressSubLabel *label = self.parameterLabelArr[x];
        if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"market_volume"]]) {
            label.hidden = YES;
            if ((self.oritentType != YXKlineScreenOrientTypeRight) && (x + 1 < self.parameterLabelArr.count)) {
                UIView *label2 = self.parameterLabelArr[x + 1];
                label2.frame = label.frame;
            }
            break;
        }
    }
}

// 隐藏成交额
- (void)hiddenAmount {
    for (int x = 0; x < _parameterLabelArr.count; x ++) {
        YXStockDetailLongPressSubLabel *label = self.parameterLabelArr[x];
        
        if ([label.titleLabel.text isEqualToString: [YXLanguageUtility kLangWithKey:@"market_amount"]]) {
            label.hidden = YES;
            break;
        }
    }
}

- (YXKLineOrderDetailView *)orderDetailView {
    if (!_orderDetailView) {
        _orderDetailView = [[YXKLineOrderDetailView alloc] initWithFrame:CGRectZero andType:(int)self.oritentType];
        _orderDetailView.hidden = YES;
    }
    return _orderDetailView;
}

- (YXKLineCompanyActionView *)companyActionView {
    if (!_companyActionView) {
        _companyActionView = [[YXKLineCompanyActionView alloc] initWithFrame:CGRectZero andType:(int)self.oritentType];
        _companyActionView.hidden = YES;
    }
    return _companyActionView;
}

@end
