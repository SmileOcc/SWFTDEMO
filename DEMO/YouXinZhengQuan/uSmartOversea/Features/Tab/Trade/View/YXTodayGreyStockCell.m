//
//  YXTodayGreyStockCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/4/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTodayGreyStockCell.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXTodayGreyStockCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *symbolLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UILabel *rocLabel;

@property (nonatomic, strong) QMUIButton *orderBtn;


@end

@implementation YXTodayGreyStockCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    self.backgroundColor = QMUITheme.foregroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.nameLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
    self.symbolLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];

    self.priceLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.stockGrayColor textFont:[UIFont systemFontOfSize:16]];
    self.rocLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.stockGrayColor textFont:[UIFont systemFontOfSize:16]];
    self.orderBtn = [QMUIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"grey_order"] font:[UIFont systemFontOfSize:13] titleColor:UIColor.whiteColor target:self action:@selector(orderClick:)];
    self.orderBtn.backgroundColor = QMUITheme.themeTextColor;
    [self.orderBtn setDisabledTheme:0];
    
    self.orderBtn.clipsToBounds = YES;
    self.orderBtn.layer.cornerRadius = 4;
    self.orderBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.orderBtn.titleLabel.minimumScaleFactor = 0.3;
    self.priceLabel.adjustsFontSizeToFitWidth = YES;
    self.priceLabel.minimumScaleFactor = 0.3;
    self.rocLabel.adjustsFontSizeToFitWidth = YES;
    self.rocLabel.minimumScaleFactor = 0.3;
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.symbolLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.rocLabel];
    [self.contentView addSubview:self.orderBtn];
    
    float scale = YXConstant.screenWidth / 375.0;
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(18);
        make.top.equalTo(self.contentView).offset(8);
        make.width.mas_equalTo(100);
    }];
    
    [self.symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.nameLabel);
        make.bottom.equalTo(self.contentView).offset(-8);
        make.width.mas_equalTo(100);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(167 * scale);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(70);
    }];
    
    [self.rocLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(223 * scale);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(70);
    }];
    
    [self.orderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(66 * scale);
        make.height.mas_equalTo(28);
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-12);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = QMUITheme.separatorLineColor;
    
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(8);
        make.trailing.equalTo(self.contentView).offset(-8);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    
}

- (void)setQuote:(YXV2Quote *)quote {
    _quote = quote;
    NSInteger priceBase = quote.priceBase.value;
    self.nameLabel.text = quote.name ?: @"--";
    self.symbolLabel.text = quote.symbol ?: @"--" ;
    self.priceLabel.text = [YXToolUtility stockPriceData:quote.latestPrice.value deciPoint:priceBase priceBase:priceBase];
    //涨跌幅
    NSString *roc= [YXToolUtility stockPercentData:quote.pctchng.value priceBasic:2 deciPoint:2];
    self.rocLabel.text = quote.pctchng ? (quote.pctchng.value > 0 ? [NSString stringWithFormat:@"%@", roc] : [NSString stringWithFormat:@"%@", roc]) : @"--";
    UIColor *color = [YXToolUtility stockColorWithData:quote.pctchng.value compareData:0];
    self.priceLabel.textColor = color;
    self.rocLabel.textColor = color;
    
}

- (void)orderClick:(UIButton *)sender {
    if (self.orderCallBack) {
        self.orderCallBack(self.quote);
    }
}


@end
