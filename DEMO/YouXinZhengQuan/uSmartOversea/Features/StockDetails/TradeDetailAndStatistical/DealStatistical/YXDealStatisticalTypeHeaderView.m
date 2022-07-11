//
//  YXDealStatisticalTypeHeaderView.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/7/15.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXDealStatisticalTypeHeaderView.h"
#import "YXStockLineMenuView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXDealStatisticalTypeHeaderTipView : UIView

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) QMUIButton *updateBtn;

@end

@implementation YXDealStatisticalTypeHeaderTipView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.backgroundColor = [QMUITheme.themeTextColor colorWithAlphaComponent:0.1];
        
    self.tipLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"usnational_update_tip"] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14]];
    self.tipLabel.adjustsFontSizeToFitWidth = true;
    self.updateBtn = [QMUIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"trading_account_update"] font:[UIFont systemFontOfSize:14] titleColor:QMUITheme.themeTextColor target:self action:@selector(updateClick:)];
    
    [self addSubview:self.tipLabel];
    [self addSubview:self.updateBtn];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.centerY.equalTo(self);
        make.right.lessThanOrEqualTo(self.updateBtn.mas_left).offset(-10);
    }];
    [self.updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
        make.top.bottom.equalTo(self);
    }];
    
    [self.tipLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.updateBtn setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)updateClick: (UIButton *)sender {
    [YXWebViewModel pushToWebVC:[YXH5Urls myQuotesUrlWithTab:1 levelType:2]];
}

@end




@implementation YXDealStatisticalTypeBtn


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    [self setTitleColor:QMUITheme.textColorLevel1 forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.layer.cornerRadius = 4;
    self.clipsToBounds = YES;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = QMUITheme.foregroundColor.CGColor;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.3;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(6, 0, self.mj_w - 12 - 15 - 3, self.mj_h);
    self.imageView.frame = CGRectMake(self.mj_w - 15 - 6, (self.mj_h - 15) * 0.5, 15, 15);
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.layer.borderColor = QMUITheme.themeTextColor.CGColor;
    } else {
        self.layer.borderColor = QMUITheme.separatorLineColor.CGColor;
    }
}

@end


@interface YXDealStatisticalTypeHeaderView()

@property (nonatomic, strong) YXDealStatisticalTypeBtn *typeBtn;
@property (nonatomic, strong) YXDealStatisticalTypeBtn *marketBtn;
@property (nonatomic, strong) YXDealStatisticalTypeBtn *historyBtn;

@property (nonatomic, strong) YXStockPopover *popover; //弹出框
@property (nonatomic, strong) YXStockLineMenuView *buyTypeMenuView; //菜单栏
@property (nonatomic, strong) YXStockLineMenuView *marketTimeMenuView; //菜单栏
@property (nonatomic, strong) YXStockLineMenuView *historyDateMenuView; //菜单栏

@property (nonatomic, strong) NSArray *buyTypeArr;
@property (nonatomic, strong) NSArray *marketTimeArr;
@property (nonatomic, strong) NSArray *historyDateArr;

@property (nonatomic, strong) NSString *market;

@property (nonatomic, strong) YXDealStatisticalTypeHeaderTipView *tipView;

@end

@implementation YXDealStatisticalTypeHeaderView

- (instancetype)initWithFrame:(CGRect)frame andMarket:(NSString *)market {
    
    if (self = [super initWithFrame:frame]) {
        self.market = market;
        [self setUI];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.backgroundColor = QMUITheme.foregroundColor;
    NSString *today = [NSString stringWithFormat:@"%@", [self getCurrentTime]];
    
    NSInteger marketSelectType = 0;
    
    self.buyTypeArr = @[[YXLanguageUtility kLangWithKey:@"history_biz_type_all"], [YXLanguageUtility kLangWithKey:@"stock_deal_active_buy"], [YXLanguageUtility kLangWithKey:@"stock_deal_active_sell"], [YXLanguageUtility kLangWithKey:@"active_buy_sell"], [YXLanguageUtility kLangWithKey:@"stock_deal_neutral_disk"]];
    
    if ([self.market isEqualToString:kYXMarketHK]) {
        self.marketTimeArr = @[[YXLanguageUtility kLangWithKey:@"all_time_slot"], [YXLanguageUtility kLangWithKey:@"trading_hours"], [YXLanguageUtility kLangWithKey:@"opening_auction_sesstion"], [YXLanguageUtility kLangWithKey:@"closing_auction_sesstion"]];
    } else if ([self.market isEqualToString:kYXMarketUS]) {
        self.marketTimeArr = @[[YXLanguageUtility kLangWithKey:@"all_time_slot"], [YXLanguageUtility kLangWithKey:@"trading_hours"], [YXLanguageUtility kLangWithKey:@"pre_opening_hours"], [YXLanguageUtility kLangWithKey:@"after_trading_hours"]];
    } else {
        self.marketTimeArr = @[[YXLanguageUtility kLangWithKey:@"all_time_slot"], [YXLanguageUtility kLangWithKey:@"trading_hours"], [YXLanguageUtility kLangWithKey:@"auction_sesstion"]];
    }
    self.historyDateArr = @[today];

    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    
    self.typeBtn = [self getTypeBtn];
    self.marketBtn = [self getTypeBtn];
    self.historyBtn = [self getTypeBtn];
    
    [self.typeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(95);
    }];
    [self.marketBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(90);
    }];
    [self.historyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(120);
    }];
    
    [self.typeBtn setTitle:self.buyTypeArr[0] forState:UIControlStateNormal];
    [self.marketBtn setTitle:self.marketTimeArr[marketSelectType] forState:UIControlStateNormal];
    [self.historyBtn setTitle:self.historyDateArr[0] forState:UIControlStateNormal];
    
    self.marketTimeMenuView.selectIndex = marketSelectType;
    
    [stackView addArrangedSubview:self.typeBtn];
    [stackView addArrangedSubview:self.marketBtn];
    [stackView addArrangedSubview:self.historyBtn];
    
    [self addSubview:stackView];
    
    if ([self.market isEqualToString:kYXMarketUS]) {
        
        UIView *lineView = [UIView lineView];
        [self addSubview:self.tapButtonView];
        [self.tapButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.height.mas_equalTo(30);
            if ([YXUserManager isENMode]) {
                make.width.mas_equalTo(260);
            } else {
                make.width.mas_equalTo(192);
            }
            
            make.top.equalTo(self).offset(15);
        }];
        // 提示全美行情升级
        BOOL isShowTip = [[YXUserManager shared] getLevelWith:kYXMarketUS] == QuoteLevelLevel1;
        isShowTip = YES;
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tapButtonView.mas_bottom).offset(12);
            make.height.mas_equalTo(30);
            make.left.equalTo(self).offset(12);
            make.right.equalTo(self).offset(-12);
            if (!isShowTip) {
                make.bottom.equalTo(self).offset(-0);
            }
        }];
        
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(6);
            make.left.right.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
                
        if (isShowTip) {
            [self addSubview:self.tipView];
            [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(40);
                make.top.equalTo(stackView.mas_bottom);
                make.left.right.equalTo(self);
                make.bottom.equalTo(self);
            }];
        }
        

    } else {
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.height.mas_equalTo(30);
            make.left.equalTo(self).offset(12);
            make.right.equalTo(self).offset(-12);
            make.bottom.equalTo(self).offset(0);
        }];
    }
//
//    UIView *lineView = [[UIView alloc] init];
//    lineView.backgroundColor = QMUITheme.separatorLineColor;
//    [self addSubview:lineView];
//    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(0);
//        make.right.equalTo(self).offset(0);
//        make.top.equalTo(stackView.mas_bottom);
//        make.height.mas_equalTo(1);
//    }];
}

- (void)typeBtnDidClick:(UIButton *)sender {
//    sender.selected = YES;
    if (sender == self.typeBtn) {
        [self.popover show:self.buyTypeMenuView fromView:sender];
    } else if (sender == self.marketBtn) {
        [self.popover show:self.marketTimeMenuView fromView:sender];
    } else {
        [self.popover show:self.historyDateMenuView fromView:sender];
    }
    
}


- (void)setTradeDateList:(NSArray *)tradeDateList {
    _tradeDateList = tradeDateList;
    
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:tradeDateList.count];
    for (NSNumber *number in tradeDateList) {
        if (number.stringValue.length > 7) {            
            [arrM addObject:[YXDateHelper commonDateString:number.stringValue format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:NO]];
        }
    }
    
    self.historyDateArr = arrM;
    [self.historyBtn setTitle:arrM.firstObject forState:UIControlStateNormal];
    
}

- (YXDealStatisticalTypeBtn *)getTypeBtn {
    
    YXDealStatisticalTypeBtn *btn1 = [[YXDealStatisticalTypeBtn alloc] init];
    btn1.titleLabel.adjustsFontSizeToFitWidth = YES;
    btn1.titleLabel.minimumScaleFactor = 0.3;
    [btn1 setImage:[UIImage imageNamed:@"kline_pull_down"] forState:UIControlStateNormal];
    
    [btn1 addTarget:self action:@selector(typeBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn1;
}

- (YXStockPopover *)popover{
    if (!_popover) {
        _popover = [[YXStockPopover alloc] init];
    }
    return _popover;
}


- (YXStockLineMenuView *)buyTypeMenuView{
    if (!_buyTypeMenuView) {
        CGFloat width = 110;
        if ([YXUserManager isENMode]) {
            width = 180;
        }
        _buyTypeMenuView = [[YXStockLineMenuView alloc] initWithFrame:CGRectMake(0, 0, width, self.buyTypeArr.count * 40) andTitles:self.buyTypeArr];
        _buyTypeMenuView.selectIndex = 0;
        @weakify(self);
        [_buyTypeMenuView setClickCallBack:^(UIButton * _Nonnull sender) {
            @strongify(self);
            [self.popover dismiss];
            if (sender.selected) {
                return;
            }
            self.typeBtn.selected = NO;
            self.buyTypeMenuView.selectIndex = sender.tag;
            [self.typeBtn setTitle:sender.currentTitle forState:UIControlStateNormal];
            [self refreshData];
        }];
    }
    return _buyTypeMenuView;
}

- (YXStockLineMenuView *)marketTimeMenuView{
    if (!_marketTimeMenuView) {
        CGFloat width = 110;
        if ([YXUserManager isENMode]) {
            width = 150;
        }
        _marketTimeMenuView = [[YXStockLineMenuView alloc] initWithFrame:CGRectMake(0, 0, width, self.marketTimeArr.count * 40) andTitles:self.marketTimeArr];
        
        @weakify(self);
        [_marketTimeMenuView setClickCallBack:^(UIButton * _Nonnull sender) {
            @strongify(self);
            [self.popover dismiss];
            if (sender.selected) {
                return;
            }
            self.marketBtn.selected = NO;
            self.marketTimeMenuView.selectIndex = sender.tag;
            [self.marketBtn setTitle:sender.currentTitle forState:UIControlStateNormal];
            [self refreshData];
        }];
    }
    return _marketTimeMenuView;
}

- (YXStockLineMenuView *)historyDateMenuView{
    if (!_historyDateMenuView) {
        _historyDateMenuView = [[YXStockLineMenuView alloc] initWithFrame:CGRectMake(0, 0, 130, self.historyDateArr.count * 40) andTitles:self.historyDateArr];
        _historyDateMenuView.selectIndex = 0;
        @weakify(self);
        [_historyDateMenuView setClickCallBack:^(UIButton * _Nonnull sender) {
            @strongify(self);
            [self.popover dismiss];
            if (sender.selected) {
                return;
            }
            self.historyBtn.selected = NO;
            self.historyDateMenuView.selectIndex = sender.tag;
            [self.historyBtn setTitle:sender.currentTitle forState:UIControlStateNormal];
            [self refreshData];
        }];
    }
    return _historyDateMenuView;
}

- (YXTapButtonView *)tapButtonView {
    if (_tapButtonView == nil) {
        _tapButtonView = [[YXTapButtonView alloc] initWithTitles:@[[YXLanguageUtility kLangWithKey:@"price_summary"], [YXLanguageUtility kLangWithKey:@"exchanges_summary"]]];
    }
    return _tapButtonView;
}

- (YXDealStatisticalTypeHeaderTipView *)tipView {
    if (_tipView == nil) {
        _tipView = [[YXDealStatisticalTypeHeaderTipView alloc] init];
    }
    return _tipView;
}

//获取当地时间
- (NSString *)getCurrentTime {
    NSDateFormatter *formatter = [NSDateFormatter en_US_POSIXFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}


- (void)refreshData {
    
    NSInteger type = self.buyTypeMenuView.selectIndex;    
    NSInteger marketType = 0;
    
    if (self.marketTimeMenuView.selectIndex == 0) {
        marketType = 3;
    } else {
        marketType = self.marketTimeMenuView.selectIndex - 1;
    }
    
    NSNumber *timeNumber = self.tradeDateList[self.historyDateMenuView.selectIndex];
    
    if (self.refreshDataCallBack) {
        self.refreshDataCallBack(type, marketType, timeNumber.stringValue);
    }
    
}

- (void)updateMarketType:(YXTimeShareLineType)timeLineType {
    if (![self.market isEqualToString:kYXMarketUS]) {
        return;
    }

    NSInteger index = 0;
    if (timeLineType == YXTimeShareLineTypeAll) {
        index = 0;
    } else if (timeLineType == YXTimeShareLineTypeIntra) {
        index = 1;
    } else if (timeLineType == YXTimeShareLineTypePre) {
        index = 2;
    } else if (timeLineType == YXTimeShareLineTypeAfter) {
        index = 3;
    }

    if (index < self.marketTimeArr.count) {
        [self.marketBtn setTitle:self.marketTimeArr[index] forState:UIControlStateNormal];
        self.marketTimeMenuView.selectIndex = index;
    }
}

@end
