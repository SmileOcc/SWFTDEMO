//
//  YXDealStatisticalTableHeadView.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXDealStatisticalTableHeadView.h"

#import "YXDealStatisticalPieChartView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "ASPopover.h"
#import "YXDealStatisticalTypeHeaderView.h"

@interface YXDealStatisticalTableHeadView ()

@property (nonatomic, strong)UILabel *avgTradePriceLab;     //平均成交价
@property (nonatomic, strong)UILabel *totalTradeCountLab;   // 总成交笔数
@property (nonatomic, strong)UILabel *totalTradeVolLab;     //总成交量
@property (nonatomic, strong)UILabel *totalAskCountLab;     // 主动卖出股数
@property (nonatomic, strong)UILabel *totalBidCountLab;     // 主动买入股数
@property (nonatomic, strong)UILabel *totalBothCountLab;    // 中性盘股数

@property (nonatomic, strong) YXDealStatisticalPieChartView *pieView; //饼状图
@property (nonatomic, strong) UILabel *pieNoDataLab;

@property (nonatomic, copy) NSArray *pieColorArr; //饼状图颜色
@property (nonatomic, strong) YXDealStatisticalTypeBtn *typeButton;
@property (nonatomic, strong) YXStockPopover *popover; //弹出框
@property (nonatomic, strong) UIView *menuView;  //弹出的菜单

@end

@implementation YXDealStatisticalTableHeadView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

- (void)configureView {
    self.backgroundColor = [QMUITheme separatorLineColor];
    
    //白色背景
    UIView * bgView = [UIView new];
    bgView.backgroundColor = [QMUITheme foregroundColor];
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self);
        make.top.equalTo(self).offset(0);
    }];
    
    CGFloat horSpace = 12;
    
    CGFloat layoutW = (YXConstant.screenWidth - 32) / 3 - 10;
    
    //MARK:第一部分
    //总览
    UILabel *summaryLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"stock_deal_overview"] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:20 weight:UIFontWeightMedium]];
    [bgView addSubview:summaryLabel];
    [summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView).offset(23);
        make.leading.equalTo(bgView).offset(horSpace);
    }];
    
    //平均成交价
    [bgView addSubview:self.avgTradePriceLab];
    [self.avgTradePriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bgView).offset(horSpace);
        make.top.equalTo(summaryLabel.mas_bottom).offset(23);
        make.height.mas_equalTo(25);
    }];
    UILabel *avgTradePriceTip = [self buildGrayLabelWith:[YXLanguageUtility kLangWithKey:@"stock_deal_average_price"] alpha:0.6];
    avgTradePriceTip.adjustsFontSizeToFitWidth = YES;
    [bgView addSubview:avgTradePriceTip];
    [avgTradePriceTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bgView).offset(horSpace);
        make.top.equalTo(_avgTradePriceLab.mas_bottom).offset(3);
        make.width.mas_lessThanOrEqualTo(layoutW);
    }];
    
    // 总成交笔数
    self.totalTradeCountLab.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:self.totalTradeCountLab];
    [self.totalTradeCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgView);
        make.top.equalTo(summaryLabel.mas_bottom).offset(23);
        make.height.mas_equalTo(25);
    }];
    UILabel *totalTradeCountTip = [self buildGrayLabelWith:[YXLanguageUtility kLangWithKey:@"stock_deal_total_transactions"] alpha:0.6];
    totalTradeCountTip.adjustsFontSizeToFitWidth = YES;
    [bgView addSubview:totalTradeCountTip];
    [totalTradeCountTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgView);
        make.top.equalTo(_totalTradeCountLab.mas_bottom).offset(3);
        make.width.mas_lessThanOrEqualTo(layoutW);
    }];
    
    //总成交量
    self.totalTradeVolLab.textAlignment = NSTextAlignmentRight;
    [bgView addSubview:self.totalTradeVolLab];
    [self.totalTradeVolLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(bgView).offset(-horSpace);
        make.top.equalTo(summaryLabel.mas_bottom).offset(23);
        make.height.mas_equalTo(25);
    }];
    UILabel *totalTradeVolTip = [self buildGrayLabelWith:[YXLanguageUtility kLangWithKey:@"stock_deal_total_volume"] alpha:0.6];
    totalTradeVolTip.adjustsFontSizeToFitWidth = YES;
    [bgView addSubview:totalTradeVolTip];
    [totalTradeVolTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(bgView).offset(-horSpace);
        make.top.equalTo(_totalTradeVolLab.mas_bottom).offset(3);
        make.width.mas_lessThanOrEqualTo(layoutW);
    }];
        
    //MARK:第二部分
    UILabel *secTitle = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"stock_deal_trade_shares_number"] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:20 weight:UIFontWeightMedium]];
    [bgView addSubview:secTitle];
    [secTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bgView).offset(horSpace);
        make.top.equalTo(totalTradeVolTip.mas_bottom).offset(27);
    }];

    CGFloat ratio = YXConstant.screenWidth / 375.0;
    CGFloat WH = 120 * ratio;
    if (WH > 120) {
        WH = 120;
    }
    self.pieView.frame = CGRectMake(0, 156, WH, WH);
    [bgView addSubview:self.pieView];
    [self.pieView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bgView).offset(horSpace);
        make.top.equalTo(secTitle.mas_bottom).offset(24);
        make.size.mas_equalTo(CGSizeMake(WH , WH));

    }];
    
    [bgView addSubview:self.pieNoDataLab];
    [self.pieNoDataLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bgView).offset(horSpace);
        make.top.equalTo(secTitle.mas_bottom).offset(19);
        make.size.mas_equalTo(CGSizeMake(WH, WH));
    }];
    

    //3个颜色
    UIView *bidTip = [UIView new]; //
    bidTip.backgroundColor = self.pieColorArr[0];
    bidTip.layer.cornerRadius = 4;
    bidTip.clipsToBounds = YES;
    [bgView addSubview:bidTip];
    [bidTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.pieView.mas_trailing).offset(20 * ratio);
        make.top.equalTo(secTitle.mas_bottom).offset(48);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];
    UIView *askTip = [UIView new];
    askTip.layer.cornerRadius = 4;
    askTip.clipsToBounds = YES;
    askTip.backgroundColor = self.pieColorArr[1];
    [bgView addSubview:askTip];
    [askTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.pieView.mas_trailing).offset(20 * ratio);
        make.top.equalTo(bidTip.mas_bottom).offset(24);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];
    UIView *bothTip = [UIView new];
    bothTip.layer.cornerRadius = 4;
    bothTip.clipsToBounds = YES;
    bothTip.backgroundColor = self.pieColorArr[2];
    [bgView addSubview:bothTip];
    [bothTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.pieView.mas_trailing).offset(20 * ratio);
        make.top.equalTo(askTip.mas_bottom).offset(24);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];
    //文字提示
    UILabel *bidTipLab = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"stock_deal_active_buy"] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14]];//
    [bgView addSubview:bidTipLab];
    bidTipLab.adjustsFontSizeToFitWidth = YES;
    [bidTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bidTip.mas_trailing).offset(10 * ratio);
        make.centerY.equalTo(bidTip);
    }];
        
    UILabel *askTipLab = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"stock_deal_active_sell"] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14]];
    [bgView addSubview:askTipLab];
    askTipLab.adjustsFontSizeToFitWidth = YES;
    [askTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(askTip.mas_trailing).offset(10 * ratio);
        make.centerY.equalTo(askTip);
    }];
    
    UILabel *bothTipLab = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"stock_deal_neutral_disk"] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14]];
    [bgView addSubview:bothTipLab];
    bothTipLab.adjustsFontSizeToFitWidth = YES;
    [bothTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bothTip.mas_trailing).offset(10 * ratio);
        make.centerY.equalTo(bothTip);
    }];
    
    
    //数字：xx亿股
    // 主动买入股数
    [bgView addSubview:self.totalBidCountLab];
    [self.totalBidCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bidTipLab.mas_trailing);
        make.trailing.equalTo(bgView).offset(-16 * ratio);
        make.centerY.equalTo(bidTip);
    }];
    
    // 主动卖出股数
    [bgView addSubview:self.totalAskCountLab];
    [self.totalAskCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(askTipLab.mas_trailing);
        make.trailing.equalTo(bgView).offset(-16 * ratio);
        make.centerY.equalTo(askTip);
    }];
    
    [bgView addSubview:self.totalBothCountLab];
    [self.totalBothCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bothTipLab.mas_trailing);
        make.trailing.equalTo(bgView).offset(-16 * ratio);
        make.centerY.equalTo(bothTip);
    }];
    
    // 第三部分
    UILabel *detailTitle = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"transaction_details"] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:20 weight:UIFontWeightMedium]];
    detailTitle.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [bgView addSubview:detailTitle];
    [detailTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bgView).offset(horSpace);
        make.height.mas_equalTo(22);
        make.bottom.equalTo(bgView).offset(-15);
    }];
    
    [bgView addSubview:self.typeButton];
    [self.typeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bgView).offset(-16);
        make.centerY.equalTo(detailTitle);
        make.width.mas_equalTo(71);
        make.height.mas_equalTo(30);
    }];
}

- (void)typeButtonEvent:(UIButton *)button{
    // 选中
    for (UIView *view in self.menuView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            if ([btn.currentTitle isEqualToString: self.typeButton.currentTitle]) {
                btn.selected = YES;
            } else {
                btn.selected = NO;
            }
        }
    }
    [self.popover show:self.menuView fromView:button];

}

- (void)subTypeButtonEvent:(UIButton *)button{
    
    [self.popover dismiss];
    if (button.selected) {
        return;
    }
    [self.typeButton setTitle:button.currentTitle forState:UIControlStateNormal];
    if (self.refreshCount) {
        self.refreshCount(button.tag);
    }
    
}

//MARK: 刷新数据
- (void)setStatisData:(YXAnalysisStatisticData *)statisData {
    _statisData = statisData;

    if (statisData != nil) {
        NSString *stockUnit = [YXLanguageUtility kLangWithKey:@"newStock_stock_unit"];
        
        UIFont *numberFont = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        UIFont *unitFont = [UIFont systemFontOfSize:14];
        if ([YXToolUtility is4InchScreenWidth]) {
            stockUnit = [YXLanguageUtility kLangWithKey:@"stock_unit_en"];
            numberFont = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
            unitFont = [UIFont systemFontOfSize:12];
        }

        //平均成交价
        uint32_t priceBase= statisData.priceBase.value;
        self.avgTradePriceLab.text = [YXToolUtility stockPriceData:statisData.avgTradePrice.value deciPoint:priceBase priceBase:priceBase];

        /*总成交笔数       -->格式：
         小于1万                   :xxxx
         大于等于1万，小于1亿        :x.xx万
         大于等于1亿                 :x.xx亿   */
        uint32_t totalTradeCountInt = statisData.totalTradeCount.value;
        NSString *totalTradeCountStr = @(statisData.totalTradeCount.value).stringValue;
        if (totalTradeCountInt < 10000) {
            self.totalTradeCountLab.text = totalTradeCountStr;
        } else {
            if (YXUserManager.isENMode) {
                self.totalTradeCountLab.text = [YXToolUtility stockData:totalTradeCountStr.doubleValue deciPoint:2 stockUnit:@"" priceBase:0];
            } else {
                self.totalTradeCountLab.attributedText = [YXToolUtility stocKNumberData:totalTradeCountStr.longLongValue deciPoint:2 stockUnit:@"" priceBase:0 numberFont:numberFont unitFont:unitFont];
            }
        }
        
        
        //总成交量
        NSString *totalTradeVolStr = [NSNumber numberWithUnsignedInt:statisData.totalTradeVol.value].stringValue;
        if (YXUserManager.isENMode) {
            self.totalTradeVolLab.text = [YXToolUtility stockData:totalTradeVolStr.doubleValue deciPoint:2 stockUnit:stockUnit priceBase:0];
        } else {
            self.totalTradeVolLab.attributedText = [YXToolUtility stocKNumberData:totalTradeVolStr.longLongValue deciPoint:2 stockUnit:stockUnit priceBase:0 numberFont:numberFont unitFont:unitFont];
        }
        
        NSArray<NSNumber *> *countArr = @[
                @(statisData.totalBidCount.value),
                @(statisData.totalAskCount.value),
                @(statisData.totalBothCount.value),
        ];
        //饼图
        if (statisData.totalBidCount.value == 0 &&
            statisData.totalAskCount.value == 0 &&
            statisData.totalBothCount.value == 0) {
            self.pieNoDataLab.hidden = false;
            self.pieView.hidden = true;
        } else {
            self.pieNoDataLab.hidden = true;
            self.pieView.hidden = false;
            [self.pieView setForPieViewData:countArr andColor:self.pieColorArr];
        }

        if (YXUserManager.isENMode) {
            // 主动买入股数
            self.totalBidCountLab.text = [YXToolUtility stockData:countArr[0].doubleValue deciPoint:2 stockUnit:stockUnit priceBase:0];

            // 主动卖出股数
            self.totalAskCountLab.text = [YXToolUtility stockData:countArr[1].doubleValue deciPoint:2 stockUnit:stockUnit priceBase:0];

            //中性盘
            self.totalBothCountLab.text = [YXToolUtility stockData:countArr[2].doubleValue deciPoint:2 stockUnit:stockUnit priceBase:0];
        } else {
            // 主动买入股数
            self.totalBidCountLab.attributedText = [YXToolUtility stocKNumberData:countArr[0].longLongValue deciPoint:2 stockUnit:stockUnit priceBase:0 numberFont:numberFont unitFont:unitFont];

            // 主动卖出股数
            self.totalAskCountLab.attributedText = [YXToolUtility stocKNumberData:countArr[1].longLongValue deciPoint:2 stockUnit:stockUnit priceBase:0 numberFont:numberFont unitFont:unitFont];

            //中性盘
            self.totalBothCountLab.attributedText = [YXToolUtility stocKNumberData:countArr[2].longLongValue deciPoint:2 stockUnit:stockUnit priceBase:0 numberFont:numberFont unitFont:unitFont];
        }
        
    } else {
        self.pieNoDataLab.hidden = false;
        self.pieView.hidden = true;
    }
}


//MARK: getter
- (UILabel *)avgTradePriceLab {
    if (!_avgTradePriceLab) {
        _avgTradePriceLab = [self buildBlackLabelWith:@""];
    }
    return  _avgTradePriceLab;
}
- (UILabel *)totalTradeCountLab {
    if (!_totalTradeCountLab) {
        _totalTradeCountLab = [self buildBlackLabelWith:@""];
    }
    return _totalTradeCountLab;
}
- (UILabel *)totalTradeVolLab {
    if (!_totalTradeVolLab) {
        _totalTradeVolLab = [self buildBlackLabelWith:@""];
    }
    return _totalTradeVolLab;
}
- (UILabel *)totalAskCountLab {
    if (!_totalAskCountLab) {
        _totalAskCountLab = [self buildBlackLabelWith:@""];
        _totalAskCountLab.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _totalAskCountLab.textAlignment = NSTextAlignmentRight;
    }
    return _totalAskCountLab;
}
- (UILabel *)totalBidCountLab {
    if (!_totalBidCountLab) {
        _totalBidCountLab = [self buildBlackLabelWith:@""];
        _totalBidCountLab.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _totalBidCountLab.textAlignment = NSTextAlignmentRight;
    }
    return _totalBidCountLab;
}
- (UILabel *)totalBothCountLab {
    if (!_totalBothCountLab) {
        _totalBothCountLab = [self buildBlackLabelWith:@""];
        _totalBothCountLab.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _totalBothCountLab.textAlignment = NSTextAlignmentRight;
    }
    return _totalBothCountLab;
}
- (YXDealStatisticalPieChartView *)pieView {
    if (!_pieView) {
        _pieView = [[YXDealStatisticalPieChartView alloc] initWithFrame:CGRectZero];
    }
    return _pieView;
}
-(UILabel *)pieNoDataLab {
    if (!_pieNoDataLab) {
        _pieNoDataLab = [self buildGrayLabelWith:[YXLanguageUtility kLangWithKey:@"common_no_data"] alpha:0.5];
        _pieNoDataLab.textAlignment = NSTextAlignmentCenter;
        _pieNoDataLab.hidden = true;
    }
    return _pieNoDataLab;
}
- (NSArray *)pieColorArr {
    if (!_pieColorArr) {
        _pieColorArr = @[
            QMUITheme.stockRedColor,
            QMUITheme.stockGreenColor,
            QMUITheme.stockGrayColor
        ];
    }
    return _pieColorArr;
}

- (YXStockPopover *)popover{
    if (!_popover) {
        _popover = [[YXStockPopover alloc] init];
    }
    return _popover;
}

- (YXDealStatisticalTypeBtn *)typeButton {
    if (!_typeButton) {
        _typeButton = [[YXDealStatisticalTypeBtn alloc] init];
        [_typeButton setImage:[UIImage imageNamed:@"warrant_filter_arrow"] forState:UIControlStateNormal];
        [_typeButton setTitle:[YXLanguageUtility kLangWithKey:@"top_20"] forState:UIControlStateNormal];
        [_typeButton addTarget:self action:@selector(typeButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _typeButton;
}

- (UIView *)menuView {
    
    if (!_menuView) {
        _menuView = [[UIView alloc] init];
//        _menuView.backgroundColor = [UIColor qmui_colorWithHexString:@"#10192A"];
        NSArray *titleArr = @[[YXLanguageUtility kLangWithKey:@"top_20"], [YXLanguageUtility kLangWithKey:@"top_50"]];
        NSInteger count = titleArr.count;
        CGFloat padding = 10;
        CGFloat margin = 21;
        CGFloat btnH = 22;
        CGFloat width = 60;
        if ([YXUserManager isENMode]) {
            width = 100;
        }
        _menuView.frame = CGRectMake(0, 0, width, padding * 2 + (count * btnH) + (count - 1) * margin);        
        for (int x = 0; x < titleArr.count; x ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom title:titleArr[x] font:[UIFont systemFontOfSize:14] titleColor:QMUITheme.textColorLevel2 target:self action:@selector(subTypeButtonEvent:)];
            button.tag = x;
//            button.layer.cornerRadius = 2.0;
//            button.layer.masksToBounds = YES;
//            button.backgroundColor = QMUITheme.backgroundColor;
//            button.layer.borderColor = QMUITheme.itemBorderColor.CGColor;
//            button.layer.borderWidth = 1;
            [button setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateSelected];
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            button.frame = CGRectMake(12, padding + (btnH + margin) * x, width - 24, btnH);
            [self.menuView addSubview:button];

            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(9, CGRectGetMaxY(button.frame) + 10, width - 18, 1)];
            lineView.backgroundColor = [QMUITheme popSeparatorLineColor];
            [self.menuView addSubview:lineView];
        }
    }
    return _menuView;
    
}


//MARK: 构建Label
- (UILabel *)buildBlackLabelWith:(NSString *)text {
    UILabel * lab = [UILabel new];
    lab.text = text;
    lab.textColor = [QMUITheme textColorLevel1];
    lab.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    if ([YXUserManager isENMode] || [YXToolUtility is4InchScreenWidth]) {
        lab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    }
    return lab;
}

- (UILabel *)buildGrayLabelWith:(NSString *)text alpha:(CGFloat)alpha {
    UILabel * lab = [UILabel new];
    lab.text = text;
    lab.textColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:alpha];//0.6 0.65
    lab.font = [UIFont systemFontOfSize:14];
    if ([YXUserManager isENMode] || [YXToolUtility is4InchScreenWidth]) {
        lab.font = [UIFont systemFontOfSize:12];
    }
    return lab;
}

- (QMUIButton *)buildRightImgBtnWith:(NSString *)text type:(NSInteger)type {
    QMUIButton *btn = [QMUIButton buttonWithType:UIButtonTypeCustom];
    btn.imagePosition = QMUIButtonImagePositionRight;
    
    
    [btn setTitle:text forState:UIControlStateNormal];//@"总览"
    if (type > 10) {
        if (@available(iOS 11.0, *)) {
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentTrailing;
        } else {
            // Fallback on earlier versions
        }
        
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn setTitleColor:[[QMUITheme textColorLevel1] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
        //[btn setImage:[UIImage imageNamed:@"sd_statistical_default_sort"] forState:UIControlStateNormal];
    } else {
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
        //[btn setImage:[UIImage imageNamed:@"weaves_detail_help"] forState:UIControlStateNormal];
    }

    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(__kindof UIControl * _Nullable x) {
        //响应
        switch (type) {
            case 1:
                //总览
                break;
            case 11://成交价
                break;
            case 12://主买
                break;
            case 13://主卖
                break;
            case 14://成交量
                break;
            case 15://占比
                break;
                
            default:
                break;
        }
    }];
    return btn;
}


@end
