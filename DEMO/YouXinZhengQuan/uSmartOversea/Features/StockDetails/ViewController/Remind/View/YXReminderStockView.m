//
//  YXReminderStockView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXReminderStockView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>


@interface YXReminderStockView()

@property (nonatomic, strong) UILabel *stockNameLabel;//股票名称
@property (nonatomic, strong) UILabel *stockSymbolLabel;//股票代码
@property (nonatomic, strong) UILabel *stockPriceLabel;//股票价格
@property (nonatomic, strong) UILabel *stockFlowLabel; //涨跌额
@property (nonatomic, strong) UILabel *stockFlowRatioLabel; //涨跌幅
@property (nonatomic, strong) UIImageView *stockRocImageView; //涨跌图片

@end

@implementation YXReminderStockView



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
    //股票名
    _stockNameLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
    _stockNameLabel.adjustsFontSizeToFitWidth = YES;
    _stockNameLabel.minimumScaleFactor = 0.3;
    
    _stockSymbolLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:14]];
    //价格
    _stockPriceLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:16 weight:UIFontWeightBold]];
    //涨跌额
    _stockFlowLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium]];
    //涨跌幅
    _stockFlowRatioLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium]];
    
    _stockRocImageView = [[UIImageView alloc] initWithImage:[YXStockDetailTool changeDirectionImage:0]];
    
    [self addSubview:self.stockNameLabel];
    [self addSubview:self.stockSymbolLabel];
    [self addSubview:self.stockRocImageView];
    [self addSubview:self.stockFlowRatioLabel];
    [self addSubview:self.stockFlowLabel];
    [self addSubview:self.stockPriceLabel];
    
    [self.stockPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.top.equalTo(self.stockNameLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(20);
    }];
    
    [self.stockRocImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.stockPriceLabel);
        make.width.height.mas_equalTo(16);
        make.left.equalTo(self.stockPriceLabel.mas_right).offset(12);
    }];
    
    [self.stockFlowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.stockPriceLabel);
        make.left.equalTo(self.stockRocImageView.mas_right).offset(2);
    }];
    
    [self.stockFlowRatioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.stockPriceLabel);
        make.left.equalTo(self.stockFlowLabel.mas_right).offset(2);
    }];
    
    [self.stockNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(16);
        make.left.equalTo(self).offset(16);
        make.height.mas_equalTo(21);
    }];
    [self.stockSymbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.stockNameLabel.mas_right).offset(3);
        make.centerY.equalTo(self.stockNameLabel);
        make.right.lessThanOrEqualTo(self).offset(-16);
    }];
    
    UIView *lineView = [UIView lineView];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setQuote:(YXV2Quote *)quote {
    _quote = quote;
    
    //股票名
    if (quote.name > 0) {
        self.stockNameLabel.text = quote.name;
    }
    self.stockSymbolLabel.text = [NSString stringWithFormat:@"(%@)", quote.symbol];
    //股票价格
    self.stockPriceLabel.text = [YXToolUtility stockPriceData:quote.latestPrice.value deciPoint:quote.priceBase.value priceBase:quote.priceBase.value];
    
    //涨跌额
    NSString *change = [YXToolUtility stockPriceData:quote.netchng.value deciPoint:quote.priceBase.value priceBase:quote.priceBase.value];
    if (quote.netchng.value > 0) {
        self.stockFlowLabel.text = [NSString stringWithFormat:@"+%@", change];
    } else if (quote.netchng.value < 0) {
        self.stockFlowLabel.text = [NSString stringWithFormat:@"%@", change];
    } else {
        self.stockFlowLabel.text = change;
    }
    
    self.stockRocImageView.image = [YXStockDetailTool changeDirectionImage:change.doubleValue];
    
    //涨跌幅
    NSString *roc= [YXToolUtility stockPercentData:quote.pctchng.value priceBasic:2 deciPoint:2];
    self.stockFlowRatioLabel.text = roc;
    
    UIColor *color = [YXToolUtility stockChangeColor:quote.netchng.value];
    self.stockPriceLabel.textColor = color;
    self.stockFlowLabel.textColor = color;
    self.stockFlowRatioLabel.textColor = color;
}

@end
