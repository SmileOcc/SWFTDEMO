//
//  YXTimeLineLongPressView.m
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/11/23.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXTimeLineLongPressView.h"
#import "YXStockDetailLongPressSubLabel.h"
#import "YXTimeLineModel.h"
#import "YXDateToolUtility.h"
#import <Masonry/Masonry.h>
#import "UILabel+create.h"
#import "YXToolUtility.h"
#import "uSmartOversea-Swift.h"

@interface YXTimeLineLongPressView ()

@property (nonatomic, strong) UILabel *timeLineDateLabel; //日期label
@property (nonatomic, strong) NSMutableArray *parameterLabelArr; //参数标签数组

@property (nonatomic, assign) BOOL isSmall;

@end

@implementation YXTimeLineLongPressView

- (instancetype)initWithFrame:(CGRect)frame andType:(YXKlineScreenOrientType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.oritentType = type;
        [self initUI];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame andType:(YXKlineScreenOrientType)type andIsSmall:(BOOL)isSmall {
    self = [super initWithFrame:frame];
    if (self) {
        self.oritentType = type;
        self.isSmall = isSmall;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    
    self.backgroundColor = QMUITheme.foregroundColor;

    //1, 日期标签
    [self addSubview:self.timeLineDateLabel];
    [self.timeLineDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.oritentType == YXKlineScreenOrientTypeRight) {
            make.left.mas_equalTo(self.mas_left).offset(12);
            make.top.mas_equalTo(self.mas_top).offset(8);
        } else {
            make.left.mas_equalTo(self.mas_left).offset(16);
            make.top.mas_equalTo(self.mas_top).offset(12);
        }
//        if (self.isSmall) {
//            make.top.mas_equalTo(self.mas_top).offset(2);
//        } else {
//            make.top.mas_equalTo(self.mas_top).offset(8);
//        }
    }];
    [_timeLineDateLabel sizeToFit];
    
    //2, 参数指标(一列一列的约束)
    
    double leftMargin = 16;
    double rightMargin = 16;
    double margin = 15;
    CGFloat height = 28;
    CGFloat topMargin = 40;
    NSInteger maxColumn = 2;
    
    CGFloat partWidth = (YXConstant.screenWidth - leftMargin - rightMargin - margin * (maxColumn - 1)) * 1.0 / maxColumn;

    if (self.oritentType == YXKlineScreenOrientTypeRight) {
        leftMargin = 12;
        rightMargin = 26;
        topMargin = 26;
        margin = 44;
        maxColumn = 3;
        partWidth = (YXConstant.screenHeight - YXConstant.navBarPadding - leftMargin - rightMargin - margin * (maxColumn - 1)) * 1.0 / maxColumn;
    }
    
    for (int x = 0; x < self.parameterLabelArr.count; x++) {
        YXStockDetailLongPressSubLabel *paraLabel = self.parameterLabelArr[x];
        [self addSubview:paraLabel];
        paraLabel.maxTitleWidth = 80;
        NSInteger line = x / maxColumn;
        NSInteger column = x % maxColumn;
        
        [paraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(leftMargin + (partWidth + margin) * column);
            make.top.mas_equalTo(self.mas_top).offset(topMargin + line * height);
            make.height.mas_equalTo(height);
            make.width.mas_equalTo(partWidth);
        }];
    }

//    UIView *lastView = self.parameterLabelArr.lastObject;
//    [self addSubview:self.orderDetailView];
//    [self.orderDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(lastView.mas_bottom).offset(10);
//        make.left.right.equalTo(self);
//        make.bottom.equalTo(self);
//        make.height.mas_equalTo(0);
//    }];
    
}


- (UILabel *)timeLineDateLabel{
    
    if (!_timeLineDateLabel) {
        _timeLineDateLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium]];
    }
    return _timeLineDateLabel;
    
}

- (NSMutableArray *)parameterLabelArr{
    
    NSArray *titleArr = @[[YXLanguageUtility kLangWithKey:@"stock_detail_price"], [YXLanguageUtility kLangWithKey:@"stock_detail_average_price"], [YXLanguageUtility kLangWithKey:@"market_change"], [YXLanguageUtility kLangWithKey:@"market_roc"], [YXLanguageUtility kLangWithKey:@"market_volume"], [YXLanguageUtility kLangWithKey:@"market_amount"]];
    if (!_parameterLabelArr) {
        _parameterLabelArr = [NSMutableArray arrayWithCapacity:6];
        for (int x = 0; x < 6; x++) {
            YXStockDetailLongPressSubLabel *paraLabel = [[YXStockDetailLongPressSubLabel alloc] init];
            paraLabel.titleLabel.text = titleArr[x];
            paraLabel.paraLabel.text = @"";
            paraLabel.margin = UIScreen.mainScreen.bounds.size.width / 3.0 * 0.08;
            [_parameterLabelArr addObject:paraLabel];
        }
    }
    return _parameterLabelArr;
    
}

- (void)setTimeSignalModel:(YXTimeLine *)timeSignalModel{
    
    _timeSignalModel = timeSignalModel;
    //除数位数比
    NSInteger square = timeSignalModel.priceBase.value > 0 ? timeSignalModel.priceBase.value : 0;
    //时间
    if (timeSignalModel.latestTime.value <= 0) {
        _timeLineDateLabel.text = @"--";
    } else {
        //月日
        _timeLineDateLabel.text = [YXDateHelper commonDateStringWithNumber:timeSignalModel.latestTime.value format:YXCommonDateFormatDF_MDHM scaleType:YXCommonDateScaleTypeScale showWeek:NO];
    }
    for (int x = 0; x < _parameterLabelArr.count; x ++) {
        YXStockDetailLongPressSubLabel *label = _parameterLabelArr[x];
        switch (x) {
            case 0:  //价格
                label.paraLabel.text = timeSignalModel.price != nil ? [YXToolUtility stockPriceData:timeSignalModel.price.value deciPoint:square priceBase:square] : @"--";
                break;
            case 1:   //均价
                label.paraLabel.text = timeSignalModel.avg != nil ? [YXToolUtility stockPriceData:timeSignalModel.avg.value deciPoint:square priceBase:square]  : @"--";
                break;
            case 2:  //涨跌额
            {
                NSString *change = [YXToolUtility stockPriceData:timeSignalModel.netchng.value deciPoint:square priceBase:timeSignalModel.priceBase.value];
                if (timeSignalModel.netchng.value > 0) {
                    label.paraLabel.text = [NSString stringWithFormat:@"+%@", change];
                } else if (timeSignalModel.netchng.value < 0) {
                    label.paraLabel.text = [NSString stringWithFormat:@"%@", change];
                } else {
                    label.paraLabel.text = change;
                }
                if (timeSignalModel && timeSignalModel.netchng.value == 0) {
                    label.paraLabel.text = @"0.000";
                }
            }
                break;
            case 3:   //涨跌幅
            {
                NSString *roc= [YXToolUtility stockPercentData:timeSignalModel.pctchng.value priceBasic:2 deciPoint:2];
                label.paraLabel.text = timeSignalModel.pctchng != nil ? (timeSignalModel.pctchng.value > 0 ? [NSString stringWithFormat:@"%@%@", roc, @""] : [NSString stringWithFormat:@"%@%@", roc, @""]) : @"--";
                if (timeSignalModel.pctchng.value == 0.00) {
                    label.paraLabel.text = roc;
                }
                if (timeSignalModel && timeSignalModel.pctchng.value == 0.00) {
                    label.paraLabel.text = @"0.00%";
                }
            }
                break;
            case 4:
            {
                //成交量
                NSString *unitString = [YXLanguageUtility kLangWithKey:@"stock_unit_en"];
                if ([self.market isEqualToString:kYXMarketUsOption]) {
                    unitString = [YXLanguageUtility kLangWithKey:@"options_page"];
                }
                NSString *str = [YXToolUtility stockData: timeSignalModel.volume.value deciPoint:2 stockUnit:unitString priceBase: 0];
                label.paraLabel.text = str;

                if ([_market isEqualToString:@"us"]) {
                    if (timeSignalModel.volume.value <= 0) {
//                        label.hidden = YES;
                    } else {
                        label.hidden = NO;
                    }
                }
                break;
            }
            case 5:  //成交额
            {
                NSString *str = [YXToolUtility stockData:timeSignalModel.amount.value deciPoint:2 stockUnit:@"" priceBase:timeSignalModel.priceBase.value];
                label.paraLabel.text = str;
                if ([_market isEqualToString:@"hk"]) {
                    if (timeSignalModel.amount.value <= 0) {
//                        label.hidden = YES;
                    } else {
                        label.hidden = NO;
                    }
                }
                break;
            }
            default:
                break;
        }
    }
    //红涨绿跌, 不涨不跌为灰色
    UIColor *color = [YXToolUtility changeColor:timeSignalModel.netchng.value];
    YXStockDetailLongPressSubLabel *priceLabel = _parameterLabelArr[0];
    YXStockDetailLongPressSubLabel *changeLabel = _parameterLabelArr[2];
    YXStockDetailLongPressSubLabel *roclabel = _parameterLabelArr[3];
    priceLabel.paraLabel.textColor = color;
    changeLabel.paraLabel.textColor = color;
    roclabel.paraLabel.textColor = color;

//    YXKLineInsideEvent *orderEvent = nil;
//    if (timeSignalModel.klineEvents.count > 0) {
//        for (YXKLineInsideEvent *event in timeSignalModel.klineEvents) {
//            if (event.type.value == 0 && (event.bought.count > 0 || event.sold.count > 0)) {
//                orderEvent = event;
//                break;
//            }
//        }
//    }
//
//    if (orderEvent.bought.count > 0 || orderEvent.sold.count > 0) {
//        self.orderDetailView.hidden = NO;
//        if (self.oritentType == YXKlineScreenOrientTypePortrait) {
//            [self.orderDetailView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.height.mas_equalTo(30);
//            }];
//        } else {
//            [self.orderDetailView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.height.mas_equalTo(20);
//            }];
//        }
//        self.orderDetailView.market = self.market;
//        self.orderDetailView.timelineSingleModel = timeSignalModel;
//
//    } else {
//        self.orderDetailView.hidden = YES;
//        [self.orderDetailView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(0);
//        }];
//    }
    
}

- (void)hiddenVolume {
    for (int x = 0; x < _parameterLabelArr.count; x ++) {
        if (x == 4) {
            YXStockDetailLongPressSubLabel *label = self.parameterLabelArr[x];
            label.hidden = YES;
            break;
        }
    }
}

- (void)hiddenAmount {
    for (int x = 0; x < _parameterLabelArr.count; x ++) {
        if (x == 5) {
            YXStockDetailLongPressSubLabel *label = self.parameterLabelArr[x];
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

@end
