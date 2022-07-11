//
//  OSSVCartBottomResultView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartBottomResultView.h"
#import "RateModel.h"

@implementation OSSVCartBottomResultView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = OSSVThemesColors.col_FFFFFF;
        [self addSubview:self.lineView];
        [self addSubview:self.choiceBtn];
        [self addSubview:self.allLabel];
        [self addSubview:self.totalView];
        [self addSubview:self.taxLabel];
        [self addSubview:self.deductionView];
        [self addSubview:self.buyBtn];
        [self addSubview:self.tipCoinView];
        [self addSubview:self.tipMsgLabel];
                
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(self);
            make.height.mas_equalTo(0.5);
        }];

        
        [self.choiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(10);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
            make.width.height.mas_equalTo(18);
        }];

        [self.allLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.choiceBtn.mas_centerY);
            make.leading.mas_equalTo(self.choiceBtn.mas_trailing).mas_offset(1);
        }];

        [self.deductionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
            make.top.mas_equalTo(self.top).mas_offset(6);
            make.height.equalTo(13);
        }];

        [self.totalView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.allLabel.mas_centerY);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
            make.height.equalTo(18);
        }];

        [self.taxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.totalView.mas_centerY);
            make.trailing.mas_equalTo(self.totalView.mas_leading).offset(-1);
        }];

        [self.buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(44);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
            make.height.mas_equalTo(44);
        }];
        
        [self.tipMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(self.buyBtn.mas_leading);
//            make.trailing.mas_equalTo(self.buyBtn.mas_trailing);
            make.height.mas_equalTo(29);
            make.top.mas_equalTo(self.buyBtn.mas_bottom);
            make.centerX.mas_equalTo(self.buyBtn.mas_centerX);
            make.width.mas_lessThanOrEqualTo(SCREEN_WIDTH - 24 - 14);
        }];
        
        [self.tipCoinView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.tipMsgLabel.mas_leading).offset(-2);
            make.width.height.mas_equalTo(12);
            make.centerY.mas_equalTo(self.tipMsgLabel.mas_centerY);
        }];
    }
    return self;
}

- (void)updateSelect:(BOOL)select
           cartInfor:(CartInfoModel *)cartInfo
               count:(NSInteger)count{
    
    self.choiceBtn.selected = select;

    if (count > 999) {
        count = 999;
    }

    
//    RateModel *rage = [ExchangeManager  localCurrency];
    //折扣
//    NSString *savePrice = [NSString stringWithFormat:@"%@%@",rage.symbol,[ExchangeManager changeRateModel:[ExchangeManager localCurrency] transforPrice:dedutionPrice priceType:PriceType_Off]];
    NSString *buyTitle = @"";
    if (APP_TYPE == 3) {
        buyTitle = [NSString stringWithFormat:@"%@(%li)",STLLocalizedString_(@"Cart_CheckOut", nil),(long)count];

    } else {
        buyTitle = [NSString stringWithFormat:@"%@(%li)",[STLLocalizedString_(@"Cart_CheckOut", nil) uppercaseString],(long)count];
    }
    
    NSString *taxStr = STLUserDefaultsGet(@"tax");
    NSLog(@"获取到的含税信息：%@", taxStr);
    if (taxStr.length) {
        self.taxLabel.text = [NSString stringWithFormat:@"(%@)", taxStr];
    }
    
    [self.deductionView updateFirstDesc:[NSString stringWithFormat:@"%@:",STLLocalizedString_(@"save", nil)] secondPrice:STLToString(cartInfo.save_converted)];
    [self.totalView updateFirstDesc:[NSString stringWithFormat:@"%@:",STLLocalizedString_(@"total", nil)] secondPrice:STLToString(cartInfo.total_converted)];
    
    [self.buyBtn setTitle:buyTitle forState:UIControlStateNormal];
    
    if ([cartInfo.save floatValue] > 0) {
        self.deductionView.hidden = NO;
        [self.totalView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.deductionView.mas_bottom).offset(2);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
            make.height.equalTo(18);
        }];
    } else {
        self.deductionView.hidden = YES;
        [self.totalView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.allLabel.mas_centerY);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
            make.height.equalTo(18);

        }];
    }
}

#pragma mark -
- (void)choiceTouch:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cartBottomResultView:selectAll:)]) {
        [self.delegate cartBottomResultView:self selectAll:sender.selected];
    }
}

- (void)buyTouch:(UIButton *)sender {
    //新增埋点
      NSString *labelStr = @"";
      if ([OSSVAccountsManager sharedManager].isSignIn) {
          labelStr = @"login_in";
      } else {
          labelStr = @"not_login_in";
      }
      
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cartBottomResultView:eventBuy:)]) {
        [self.delegate cartBottomResultView:self eventBuy:YES];
    }
}

#pragma mark - LazyLoad

- (UILabel *)taxLabel {
    if (!_taxLabel) {
        _taxLabel = [UILabel new];
        _taxLabel.textColor = OSSVThemesColors.col_999999;
        _taxLabel.font = [UIFont systemFontOfSize:10];
        _taxLabel.textAlignment = NSTextAlignmentRight;
    }
    return _taxLabel;
}
- (UIButton *)choiceBtn {
    if (!_choiceBtn) {
        _choiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_choiceBtn addTarget:self action:@selector(choiceTouch:) forControlEvents:UIControlEventTouchUpInside];
        if (APP_TYPE == 3) {
            [_choiceBtn setImage:[UIImage imageNamed:@"viv_ShoppingBag_Unselected"] forState:UIControlStateNormal];
            [_choiceBtn setImage:[UIImage imageNamed:@"viv_ShoppingBag_Selected"] forState:UIControlStateSelected];

        } else {
            [_choiceBtn setImage:[UIImage imageNamed:@"Shopping_UnSelect"] forState:UIControlStateNormal];
            [_choiceBtn setImage:[UIImage imageNamed:@"Shopping_Selected"] forState:UIControlStateSelected];

        }
    }
    return _choiceBtn;
}

- (UILabel *)allLabel {
    if (!_allLabel) {
        _allLabel = [[UILabel alloc] init];
        _allLabel.font = [UIFont systemFontOfSize:13];
        _allLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _allLabel.text = STLLocalizedString_(@"All", nil);
    }
    return _allLabel;
}

- (OSSVPriceView *)deductionView {
    if (!_deductionView) {
        _deductionView = [[OSSVPriceView alloc] initWithFrame:CGRectZero font:[UIFont systemFontOfSize:11] textColor: APP_TYPE == 3 ? OSSVThemesColors.col_9F5123 : OSSVThemesColors.col_B62B21];
    }
    return _deductionView;
}

- (OSSVPriceView *)totalView {
    if (!_totalView) {
        _totalView = [[OSSVPriceView alloc] initWithFrame:CGRectZero font:[UIFont systemFontOfSize:16] textColor:[OSSVThemesColors col_000000:1.0]];
        _totalView.priceLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _totalView;
}


- (UIButton *)buyBtn {
    if (!_buyBtn) {
        _buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _buyBtn.backgroundColor = [OSSVThemesColors col_0D0D0D];
        if (APP_TYPE == 3) {
            _buyBtn.titleLabel.font = [UIFont vivaiaRegularFont:18];
            [_buyBtn setTitle:STLLocalizedString_(@"Cart_CheckOut", nil) forState:UIControlStateNormal];

        } else {
            _buyBtn.titleLabel.font = [UIFont stl_buttonFont:14];
            [_buyBtn setTitle:[STLLocalizedString_(@"Cart_CheckOut", nil) uppercaseString] forState:UIControlStateNormal];

        }
        [_buyBtn setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        [_buyBtn addTarget:self action:@selector(buyTouch:) forControlEvents:UIControlEventTouchUpInside];
        [_buyBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        _buyBtn.layer.cornerRadius = 2.0;
        _buyBtn.layer.masksToBounds = YES;
        
    }
    return _buyBtn;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [OSSVThemesColors col_CCCCCC];
    }
    return _lineView;
}


- (UILabel *)tipMsgLabel {
    if (!_tipMsgLabel) {
        _tipMsgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipMsgLabel.textColor = [OSSVThemesColors col_666666];
        _tipMsgLabel.font = [UIFont systemFontOfSize:11];
//        _tipMsgLabel.text = STLLocalizedString_(@"cart_bottom_tip_CoinsCouponsDiscount", nil);
        _tipMsgLabel.textAlignment = NSTextAlignmentCenter;
        _tipMsgLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _tipMsgLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        }
        _tipMsgLabel.numberOfLines = 1;
    }
    return _tipMsgLabel;
}

- (UIImageView *)tipCoinView{
    if (!_tipCoinView) {
        _tipCoinView = [UIImageView new];
        _tipCoinView.image = [UIImage imageNamed:@"check_coin"];
        _tipCoinView.hidden = YES;
    }
    return _tipCoinView;
}

@end
