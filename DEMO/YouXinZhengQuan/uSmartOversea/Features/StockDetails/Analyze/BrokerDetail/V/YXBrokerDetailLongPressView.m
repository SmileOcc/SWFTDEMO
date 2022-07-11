//
//  YXBrokerDetailLongPressView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXBrokerDetailLongPressView.h"
#import "YXBrokerDetailModel.h"
#import "YXStockDetailUtility.h"
#import "UILabel+create.h"
#import <Masonry/Masonry.h>
#import "YXDateToolUtility.h"
#import "YXDateModel.h"
#import "YXToolUtility.h"
#import "uSmartOversea-Swift.h"

@interface YXBrokerDetailLongPressView ()

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *ratoLabel;

@property (nonatomic, strong) UILabel *volumnLabel;

@property (nonatomic, strong) UILabel *buyLabel;

@property (nonatomic, strong) UILabel *openLabel;

@property (nonatomic, strong) UILabel *closeLabel;

@property (nonatomic, strong) UILabel *rocLabel;

@property (nonatomic, strong) NSArray *titleArr;

@property (nonatomic, assign) YXBrokerLineType type;

@end

@implementation YXBrokerDetailLongPressView



- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andType:(YXBrokerLineType)type {
    if (self = [super initWithFrame:frame]) {
        self.type = type;
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.backgroundColor = QMUITheme.foregroundColor;
    self.layer.backgroundColor = QMUITheme.foregroundColor.CGColor;
    self.layer.shadowColor = [[QMUITheme.textColorLevel3 colorWithAlphaComponent:0.25] CGColor];
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 4;

    if (self.type == YXBrokerLineTypeBroker) {
        self.titleArr = @[[YXLanguageUtility kLangWithKey:@"broker_percent"], [YXLanguageUtility kLangWithKey:@"economic_hold_num"], [YXLanguageUtility kLangWithKey:@"economic_change_volume"]];
    } else if (self.type == YXBrokerLineTypeHkwolun) {
        self.titleArr = @[[YXLanguageUtility kLangWithKey:@"broker_percent"], [YXLanguageUtility kLangWithKey:@"economic_hold_num"], [YXLanguageUtility kLangWithKey:@"economic_change_volume"]];
    } else {
        self.titleArr = @[[YXLanguageUtility kLangWithKey:@"sales_ratio"], [YXLanguageUtility kLangWithKey:@"trade_turnover"], [YXLanguageUtility kLangWithKey:@"sales_amount"]];
    }
    
    self.dateLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:12]];
    self.ratoLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentRight];
    self.volumnLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentRight];
    self.buyLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentRight];
    self.openLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentRight];
    self.closeLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentRight];
    self.rocLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:10] textAlignment:NSTextAlignmentRight];
    
    UILabel *ratoTitle = [UILabel labelWithText:self.titleArr[0] textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:10]];
    UILabel *volumnTitle = [UILabel labelWithText:self.titleArr[1] textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:10]];
    UILabel *buyTitle = [UILabel labelWithText:self.titleArr[2] textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:10]];
    UILabel *openTitle = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"stockST_open_price"] textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:10]];
    UILabel *closeTitle = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"economic_close"] textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:10]];
    UILabel *rocTitle = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"market_roc"] textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:10]];
    
    [self addSubview:self.dateLabel];
    [self addSubview:self.ratoLabel];
    [self addSubview:self.volumnLabel];
    [self addSubview:self.buyLabel];
    [self addSubview:self.openLabel];
    [self addSubview:self.closeLabel];
    [self addSubview:self.rocLabel];
    
    [self addSubview:ratoTitle];
    [self addSubview:volumnTitle];
    [self addSubview:buyTitle];
    [self addSubview:openTitle];
    [self addSubview:closeTitle];
    [self addSubview:rocTitle];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(8);
        make.top.equalTo(self).offset(8);
        make.height.mas_equalTo(14);
    }];
    [ratoTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(8);
        make.top.equalTo(self).offset(24);
        make.height.mas_equalTo(20);
    }];
    [volumnTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(8);
        make.top.equalTo(self).offset(44);;
        make.height.mas_equalTo(20);
    }];
    [buyTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(8);
        make.top.equalTo(self).offset(64);;
        make.height.mas_equalTo(20);
    }];
    [openTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(8);
        make.top.equalTo(self).offset(84);;
        make.height.mas_equalTo(20);
    }];
    [closeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(8);
        make.top.equalTo(self).offset(104);;
        make.height.mas_equalTo(20);
    }];
    [rocTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(8);
        make.top.equalTo(self).offset(124);;
        make.height.mas_equalTo(20);
    }];
    
    [self.ratoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-8);
        make.top.equalTo(ratoTitle);
        make.height.mas_equalTo(20);
    }];
    [self.volumnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-8);
        make.top.equalTo(volumnTitle);
        make.height.mas_equalTo(20);
    }];
    [self.buyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-8);
        make.top.equalTo(buyTitle);
        make.height.mas_equalTo(20);
    }];
    [self.openLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-8);
        make.top.equalTo(openTitle);
        make.height.mas_equalTo(20);
    }];
    [self.closeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-8);
        make.top.equalTo(closeTitle);
        make.height.mas_equalTo(20);
    }];
    [self.rocLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-8);
        make.top.equalTo(rocTitle);
        make.height.mas_equalTo(20);
    }];
}

- (void)setSubModel:(YXBrokerDetailSubModel *)subModel {
    _subModel = subModel;
    
    self.dateLabel.text = [YXDateHelper commonDateString:subModel.date format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeScale showWeek:YES];

    if (subModel.holdRatio < 100) {
        self.ratoLabel.text = [NSString stringWithFormat:@"%.3f%%", subModel.holdRatio / 100.0];
    } else {
        self.ratoLabel.text = [NSString stringWithFormat:@"%.2f%%", subModel.holdRatio / 100.0];
    }
    
    self.volumnLabel.text = [YXToolUtility stocKNumberData:subModel.holdVolume deciPoint:2 stockUnit:[YXLanguageUtility kLangWithKey:@"stock_unit_en"] priceBase:0].string;
    
    NSString *buyStr = [YXToolUtility stocKNumberData:subModel.changeVolume deciPoint:2 stockUnit:[YXLanguageUtility kLangWithKey:@"stock_unit_en"] priceBase:0].string;
    if (subModel.changeVolume > 0) {
        self.buyLabel.text = [NSString stringWithFormat:@"+%@", buyStr];
    } else {
        self.buyLabel.text = buyStr;
    }
    
    UIColor *color = QMUITheme.stockGrayColor;
    UIColor *openColor = QMUITheme.stockGrayColor;
    if (subModel.pctchng > 0) {
        color = QMUITheme.stockRedColor;
    } else if (subModel.pctchng < 0) {
        color = QMUITheme.stockGreenColor;
    }
    if (subModel.open > subModel.preClose) {
        openColor = QMUITheme.stockRedColor;
    } else if  (subModel.open < subModel.preClose) {
        openColor = QMUITheme.stockGreenColor;
    }
    self.openLabel.textColor = openColor;
    self.closeLabel.textColor = color;
    self.rocLabel.textColor = color;

    self.openLabel.text = [YXToolUtility stockPriceData:subModel.open deciPoint:self.priceBase priceBase:self.priceBase];
    self.closeLabel.text = [YXToolUtility stockPriceData:subModel.close deciPoint:self.priceBase priceBase:self.priceBase];
    if (subModel.open > 0 && subModel.close > 0) {
        NSString *str = @"";
        if (subModel.pctchng > 0) {
            str = @"+";
        }
        self.rocLabel.text = [NSString stringWithFormat:@"%@%.2f%%", str, subModel.pctchng / 100.0];
    } else {
        self.rocLabel.text = @"--";
    }
}

@end
