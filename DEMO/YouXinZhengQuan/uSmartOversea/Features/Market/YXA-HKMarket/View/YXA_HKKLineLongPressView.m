//
//  YXA_HKKLineLongPressView.m
//  uSmartOversea
//
//  Created by youxin on 2020/3/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXA_HKKLineLongPressView.h"
#import "YXStockDetailUtility.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXA_HKKLineLongPressView ()

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *totalFundLabel;

@property (nonatomic, strong) UILabel *shFundLabel;

@property (nonatomic, strong) UILabel *szFundLabel;

@property (nonatomic, strong) UILabel *shIndexValueLabel;

@property (nonatomic, strong) UILabel *szIndexValueLabel;

@property (nonatomic, strong) UILabel *totalFundTitleLabel;

@property (nonatomic, strong) UILabel *shFundTitleLabel;

@property (nonatomic, strong) UILabel *szFundTitleLabel;

@property (nonatomic, strong) UILabel *shIndexValueTitleLabel;

@property (nonatomic, strong) UILabel *szIndexValueTitleLabel;

@property (nonatomic, assign) YXA_HKKLineDirection type;

@property (nonatomic, strong) NSArray *titleArr;

@end

@implementation YXA_HKKLineLongPressView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andType:(YXA_HKKLineDirection)type; {
    if (self = [super initWithFrame:frame]) {
        self.type = type;
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.backgroundColor = QMUITheme.backgroundColor;
    
    if (self.type == YXA_HKKLineDirectionNorth) {
        self.titleArr = @[[YXLanguageUtility kLangWithKey:@"bubear_cn_connect"], [YXLanguageUtility kLangWithKey:@"markets_news_sh_connect"], [YXLanguageUtility kLangWithKey:@"markets_news_sz_connect"], [YXLanguageUtility kLangWithKey:@"bubear_sse_composite"], [YXLanguageUtility kLangWithKey:@"bubear_szse_composite"]];
    }else {
        self.titleArr = @[[YXLanguageUtility kLangWithKey:@"bubear_hk_connect"], [YXLanguageUtility kLangWithKey:@"bubear_shhk_connect"], [YXLanguageUtility kLangWithKey:@"bubear_szhk_connect"], [YXLanguageUtility kLangWithKey:@"common_hkHSI"], @""];
    }
    
    self.dateLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:10]];
    self.totalFundLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentRight];
    self.shFundLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentRight];
    self.szFundLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentRight];
    self.shIndexValueLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentRight];
    self.szIndexValueLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentRight];
    
    
    self.totalFundTitleLabel = [UILabel labelWithText:self.titleArr[0] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:10]];
    self.shFundTitleLabel = [UILabel labelWithText:self.titleArr[1] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:10]];
    self.szFundTitleLabel = [UILabel labelWithText:self.titleArr[2] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:10]];
    self.shIndexValueTitleLabel = [UILabel labelWithText:self.titleArr[3] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:10]];
    self.szIndexValueTitleLabel = [UILabel labelWithText:self.titleArr[4] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:10]];
    
    
    UIStackView *titleStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.totalFundTitleLabel, self.shFundTitleLabel, self.szFundTitleLabel, self.shIndexValueTitleLabel, self.szIndexValueTitleLabel]];
    titleStackView.axis = UILayoutConstraintAxisVertical;
    titleStackView.alignment = UIStackViewAlignmentLeading;
    titleStackView.distribution = UIStackViewDistributionFill;
    
    UIStackView *valueStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.totalFundLabel, self.shFundLabel, self.szFundLabel, self.shIndexValueLabel, self.szIndexValueLabel]];
    valueStackView.axis = UILayoutConstraintAxisVertical;
    valueStackView.alignment = UIStackViewAlignmentTrailing;
    valueStackView.distribution = UIStackViewDistributionFill;
    
    [self addSubview:self.dateLabel];
    [self addSubview:titleStackView];
    [self addSubview:valueStackView];
    
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(4);
        make.top.equalTo(self);
        make.height.mas_equalTo(16);
    }];
    
    [titleStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(4);
        make.top.equalTo(self.dateLabel.mas_bottom).offset(3);
        make.bottom.equalTo(self).offset(-3);
    }];
    
    [valueStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-4);
        make.top.equalTo(self.dateLabel.mas_bottom).offset(3);
    }];
}


- (void)setModel:(YXA_HKFundTrendKlineCustomModel *)model {
    _model = model;
    
    NSString *unit = [YXLanguageUtility kLangWithKey:@"common_billion"];
    double total = model.totalAmount;
    double sh = model.shAmount;
    double sz = model.szAmount;
    if ([YXUserManager isENMode]) {
        unit = [YXLanguageUtility kLangWithKey:@"common_unit_billion"];
        total = total/10.0;
        sh = sh/10.0;
        sz = sz/10.0;
    }
    
    self.dateLabel.text = [YXDateHelper commonDateString:model.time format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:YES];
    self.totalFundLabel.text = [NSString stringWithFormat:@"%.2lf%@", total, unit];
    
    if (model.totalAmount > 0) {
        self.totalFundLabel.textColor = QMUITheme.stockRedColor;
        self.totalFundLabel.text = [NSString stringWithFormat:@"+%@", self.totalFundLabel.text];
    }else {
        self.totalFundLabel.textColor = QMUITheme.stockGreenColor;
    }
    
    self.shFundLabel.text = [NSString stringWithFormat:@"%.2lf%@", sh, unit];
    
    if (model.shAmount > 0) {
        self.shFundLabel.textColor = QMUITheme.stockRedColor;
        self.shFundLabel.text = [NSString stringWithFormat:@"+%@", self.shFundLabel.text];
    }else {
        self.shFundLabel.textColor = QMUITheme.stockGreenColor;
    }
    
    self.szFundLabel.text = [NSString stringWithFormat:@"%.2lf%@", sz, unit];
    
    if (model.szAmount > 0) {
        self.szFundLabel.textColor = QMUITheme.stockRedColor;
        self.szFundLabel.text = [NSString stringWithFormat:@"+%@", self.szFundLabel.text];
    }else {
        self.szFundLabel.textColor = QMUITheme.stockGreenColor;
    }
    
    if (self.type == YXA_HKKLineDirectionNorth) {
        // 当是指数是，amount代表的值时指数的涨跌额
        self.shIndexValueLabel.text = [NSString stringWithFormat:@"%.2lf", model.shIndexPrice];
        if (model.shIndexChangeAmount > 0) {
            self.shIndexValueLabel.textColor = QMUITheme.stockRedColor;
        }else if (model.shIndexChangeAmount < 0) {
            self.shIndexValueLabel.textColor = QMUITheme.stockGreenColor;
        }else {
            self.shIndexValueLabel.textColor = QMUITheme.stockGrayColor;
        }
        self.szIndexValueLabel.text = [NSString stringWithFormat:@"%.2lf", model.szIndexPrice];
        if (model.szIndexChangeAmount > 0) {
            self.szIndexValueLabel.textColor = QMUITheme.stockRedColor;
        }else if (model.szIndexChangeAmount < 0) {
            self.szIndexValueLabel.textColor = QMUITheme.stockGreenColor;
        }else {
            self.szIndexValueLabel.textColor = QMUITheme.stockGrayColor;
        }
    }else {
        self.shIndexValueLabel.text = [NSString stringWithFormat:@"%.2lf", model.HSIIndexPrice];
        if (model.HSIIndexChangeAmount > 0) {
            self.shIndexValueLabel.textColor = QMUITheme.stockRedColor;
        }else if (model.HSIIndexChangeAmount < 0) {
            self.shIndexValueLabel.textColor = QMUITheme.stockGreenColor;
        }else {
            self.shIndexValueLabel.textColor = QMUITheme.stockGrayColor;
        }
    }
    
    self.totalFundLabel.hidden = self.totalFundTitleLabel.hidden = !self.isShowTotalFundTrend;
    self.shFundLabel.hidden = self.shFundTitleLabel.hidden = !self.isShowSHFundTrend;
    self.szFundLabel.hidden = self.szFundTitleLabel.hidden = !self.isShowSZFundTrend;
    self.shIndexValueLabel.hidden = self.shIndexValueTitleLabel.hidden = !self.isShowSHIndexLine;
    self.szIndexValueLabel.hidden = self.szIndexValueTitleLabel.hidden = !self.isShowSZIndexLine;
}


@end
