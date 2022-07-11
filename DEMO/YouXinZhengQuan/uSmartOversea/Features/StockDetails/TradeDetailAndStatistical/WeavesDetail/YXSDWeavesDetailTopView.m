//
//  YXSDWeavesDetailTopView.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXSDWeavesDetailTopView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "YXDateToolUtility.h"

@interface YXSDWeavesDetailTopView()

@property(nonatomic, strong)UILabel *stockNameLab;  //股票名称
@property(nonatomic, strong)UILabel *stockCodeLab;  //股票代码
@property(nonatomic, strong)UILabel *priceLab;      //股票价格
@property(nonatomic, strong)UILabel *flowPriceLab;  //涨跌额
@property(nonatomic, strong)UILabel *flowRatioLab;  //涨跌幅
@property (nonatomic, strong) UIImageView *directionImageView;
//YXStockDetailTool.changeDirectionImage(change)

@end

@implementation YXSDWeavesDetailTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [QMUITheme foregroundColor];
        
        [self addSubview:self.stockNameLab];
        [self addSubview:self.stockCodeLab];
        [self addSubview:self.priceLab];
        [self addSubview:self.directionImageView];
        [self addSubview:self.flowPriceLab];
        [self addSubview:self.flowRatioLab];
    
        [self.stockNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(16);
            make.height.mas_equalTo(21);
            make.top.equalTo(self).offset(8);
        }];
        [self.stockCodeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.stockNameLab.mas_right).offset(6);
            make.centerY.equalTo(self.stockNameLab);
            make.trailing.lessThanOrEqualTo(self).offset(-16);
        }];
        
        [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(16);
            make.top.equalTo(self.stockNameLab.mas_bottom).offset(4);
        }];
        
        [self.directionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.priceLab.mas_right).offset(12);
            make.width.height.mas_equalTo(16);
            make.centerY.equalTo(self.priceLab);
        }];
        
        [self.flowPriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.priceLab);
            make.left.equalTo(self.directionImageView.mas_right).offset(1);
        }];
        [self.flowRatioLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.priceLab);
            make.left.equalTo(self.flowPriceLab.mas_right).offset(3);;
        }];
        
    }
    return self;
}


//MARK: refresh
- (void)setQuote:(YXV2Quote *)quote {
    _quote = quote;

    self.stockNameLab.text = quote.name;

    if ([quote.market isEqualToString:kYXMarketUsOption]) {
        self.stockCodeLab.text = @"";
    } else {
        self.stockCodeLab.text = [NSString stringWithFormat:@"(%@.%@)",quote.symbol, quote.market.uppercaseString];
    }
    
    //股票价格
    if (quote.latestPrice.value <= 0.0) {
        self.priceLab.text = @"--";
    } else {
        self.priceLab.text = [YXToolUtility stockPriceData:quote.latestPrice.value deciPoint:quote.priceBase.value priceBase:quote.priceBase.value];
    }
    //涨跌额
    NSString *change = [YXToolUtility stockPriceData:quote.netchng.value deciPoint:quote.priceBase.value priceBase:quote.priceBase.value];
    if (change.doubleValue > 0) {
        self.flowPriceLab.text = [NSString stringWithFormat:@"%@", change];
    } else if (change.doubleValue < 0) {
        self.flowPriceLab.text = [NSString stringWithFormat:@"%@", change];
    } else {
        self.flowPriceLab.text = change;
    }

    //涨跌幅
    NSString *roc = [YXToolUtility stockPercentData:quote.pctchng.value priceBasic:2 deciPoint:2];
    if (quote.pctchng) {
        if (roc.doubleValue <= 0) {
            self.flowRatioLab.text = [NSString stringWithFormat:@"(%@)", roc];
        } else if (roc.doubleValue > 0) {
            self.flowRatioLab.text = [NSString stringWithFormat:@"(%@)", roc];
        }
    } else {
        self.flowRatioLab.text = @"(--)";
    }
    
    self.directionImageView.image = [YXStockDetailTool changeDirectionImage:quote.netchng.value];
    
    //当前股价, 涨跌幅, 涨跌额
    UIColor *color = [YXToolUtility changeColor:quote.netchng.value];
    self.priceLab.textColor = color;
    self.flowPriceLab.textColor = color;
    self.flowRatioLab.textColor = color;
    
}


//- (UILabel *)buildColorLabel {
//    UILabel *label = [[UILabel alloc] init];
//    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
//    label.textColor = QMUITheme.stockRedColor;
//    label.textAlignment = NSTextAlignmentRight;
//    label.adjustsFontSizeToFitWidth = YES;
//    label.minimumScaleFactor = 0.3;
//    return label;
//}
//MARK: getter

- (UILabel *)stockNameLab {
    if (_stockNameLab == nil) {
        _stockNameLab = [[UILabel alloc] init];
        _stockNameLab.font = [UIFont systemFontOfSize:18];
        _stockNameLab.textColor = [QMUITheme textColorLevel1];
        _stockNameLab.adjustsFontSizeToFitWidth = YES;
        _stockNameLab.minimumScaleFactor = 0.7;
    }
    return _stockNameLab;
}
- (UILabel *)stockCodeLab {
    if (_stockCodeLab == nil) {
        _stockCodeLab = [[UILabel alloc] init];
        _stockCodeLab.textColor = [QMUITheme textColorLevel3];
        _stockCodeLab.font = [UIFont systemFontOfSize:14];
        _stockCodeLab.adjustsFontSizeToFitWidth = YES;
        _stockCodeLab.minimumScaleFactor = 0.7;
    }
    return _stockCodeLab;
}
- (UILabel *)priceLab {
    if (!_priceLab) {
        _priceLab = [UILabel labelWithText:@"--" textColor:QMUITheme.stockGrayColor textFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
    }
    return _priceLab;
}
- (UILabel *)flowPriceLab {
    if (!_flowPriceLab) {
        _flowPriceLab = [UILabel labelWithText:@"--" textColor:QMUITheme.stockGrayColor textFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium]];
    }
    return _flowPriceLab;
}
- (UILabel *)flowRatioLab {
    if (!_flowRatioLab) {
        _flowRatioLab = [UILabel labelWithText:@"--" textColor:QMUITheme.stockGrayColor textFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium]];
    }
    return _flowRatioLab;
}

- (UIImageView *)directionImageView {
    if (_directionImageView == nil) {
        _directionImageView = [[UIImageView alloc] init];
    }
    return _directionImageView;
}

@end
