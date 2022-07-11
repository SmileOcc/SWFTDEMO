//
//  YXWarrantsMoreSortView.m
//  uSmartOversea
//
//  Created by 井超 on 2019/7/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXWarrantsMoreSortView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXWarrantsMoreSortView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIScrollView *scrollerView;
@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, strong) NSArray *moneynessArr;
@property (nonatomic, strong) NSArray *leverageRatioArr;
@property (nonatomic, strong) NSArray *premiumArr;
@property (nonatomic, strong) NSArray *outstandingRatioArr;

@property (nonatomic, strong) NSMutableArray *moneynessBtnArr;
@property (nonatomic, strong) NSMutableArray *leverageRatioBtnArr;
@property (nonatomic, strong) NSMutableArray *premiumBtnArr;
@property (nonatomic, strong) NSMutableArray *outstandingRatioBtnArr;


@end

@implementation YXWarrantsMoreSortView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    
    return self;
}

- (void)backBtnAction {
    
}

- (void)initialization {
    
    self.scrollerView.contentSize = CGSizeMake(YXConstant.screenWidth, 818);
     
    self.moneynessBtnArr = [[NSMutableArray alloc] init];
    self.leverageRatioBtnArr = [[NSMutableArray alloc] init];
    self.premiumBtnArr = [[NSMutableArray alloc] init];
    self.outstandingRatioBtnArr = [[NSMutableArray alloc] init];
    
    self.backgroundColor = QMUITheme.popupLayerColor;
    
    [self addSubview: self.bottomView];
    [self addSubview:self.scrollerView];
    
    [self.bottomView addSubview:self.confirmBtn];
    
    CGFloat h = 78 + YXConstant.tabBarPadding;
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(h);
    }];
    
    [self.scrollerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.bottom.equalTo(self.bottomView.mas_top).offset(-1);
    }];
        
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomView);
        make.left.equalTo(self.bottomView).offset(16);
        make.right.equalTo(self.bottomView).offset(-16);
        make.height.mas_equalTo(48);
    }];
    
    UILabel *moneynessLab = [[UILabel alloc] init];
    
    moneynessLab.text = [YXLanguageUtility kLangWithKey:@"warrants_in_out"];
    moneynessLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    moneynessLab.textColor = [QMUITheme textColorLevel1];
    [self.scrollerView addSubview:moneynessLab];
    [moneynessLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollerView).offset(14);
        make.top.equalTo(self.scrollerView).offset(10);
    }];
    
    CGFloat interval = 12; //间隔
    CGFloat w = (YXConstant.screenWidth - interval*4)/3;
    CGFloat btnH = 32;
    for (int i = 0; i<self.moneynessArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:self.moneynessArr[i] forState:UIControlStateNormal];
        if (i==0) {
            [self setSelectedStateWithBtn:btn];
        }else {
            [self setUnselectedStateWithBtn:btn];
        }
        [self.moneynessBtnArr addObject:btn];
        [self.scrollerView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.scrollerView).offset(interval*(i+1)+(w*i));
            make.width.mas_equalTo(w);
            make.height.mas_equalTo(btnH);
            make.top.equalTo(moneynessLab.mas_bottom).offset(10);
        }];
        btn.tag = 10 + i;
        [btn addTarget:self action:@selector(moneynessBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UILabel *leverageRatioLab = [[UILabel alloc] init];
    
    leverageRatioLab.text = [YXLanguageUtility kLangWithKey:@"warrants_gearing"];
    leverageRatioLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    leverageRatioLab.textColor = [QMUITheme textColorLevel1];
    [self.scrollerView addSubview:leverageRatioLab];
    [leverageRatioLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollerView).offset(14);
        make.top.equalTo(moneynessLab.mas_bottom).offset(65);
        make.height.mas_equalTo(20);
    }];
    
    for (int i = 0; i<self.leverageRatioArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:self.leverageRatioArr[i] forState:UIControlStateNormal];
        if (i==0) {
            [self setSelectedStateWithBtn:btn];
        }else {
            [self setUnselectedStateWithBtn:btn];
        }
        [self.leverageRatioBtnArr addObject:btn];
        [self.scrollerView addSubview:btn];
        if (i<3) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.scrollerView).offset(interval*(i+1)+(w*i));
                make.width.mas_equalTo(w);
                make.height.mas_equalTo(btnH);
                make.top.equalTo(leverageRatioLab.mas_bottom).offset(10);
            }];
        }else {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.scrollerView).offset(interval*((i-3)+1)+(w*(i-3)));
                make.width.mas_equalTo(w);
                make.height.mas_equalTo(btnH);
                make.top.equalTo(leverageRatioLab.mas_bottom).offset(54);
            }];
        }
       
        btn.tag = 20 + i;
        [btn addTarget:self action:@selector(leverageRatioBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UILabel *premiumLab = [[UILabel alloc] init];
    
    premiumLab.text = [NSString stringWithFormat:@"%@ (%%)", [YXLanguageUtility kLangWithKey:@"warrants_premium"]];
    premiumLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    premiumLab.textColor = [QMUITheme textColorLevel1];
    [self.scrollerView addSubview:premiumLab];
    [premiumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollerView).offset(14);
        make.top.equalTo(leverageRatioLab.mas_bottom).offset(109);
        make.height.mas_equalTo(20);
    }];
    
    for (int i = 0; i<self.premiumArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:self.premiumArr[i] forState:UIControlStateNormal];
        if (i==0) {
            [self setSelectedStateWithBtn:btn];
        }else {
            [self setUnselectedStateWithBtn:btn];
        }
        [self.premiumBtnArr addObject:btn];
        [self.scrollerView addSubview:btn];
        if (i<3) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.scrollerView).offset(interval*(i+1)+(w*i));
                make.width.mas_equalTo(w);
                make.height.mas_equalTo(btnH);
                make.top.equalTo(premiumLab.mas_bottom).offset(10);
            }];
        }else {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.scrollerView).offset(interval*((i-3)+1)+(w*(i-3)));
                make.width.mas_equalTo(w);
                make.height.mas_equalTo(btnH);
                make.top.equalTo(premiumLab.mas_bottom).offset(54);
            }];
        }
        
        btn.tag = 30 + i;
        [btn addTarget:self action:@selector(premiumBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UILabel *outstandingRatioLab = [[UILabel alloc] init];
    
    outstandingRatioLab.text = [NSString stringWithFormat:@"%@ (%%)", [YXLanguageUtility kLangWithKey:@"warrants_outstandingPct"]] ;
    outstandingRatioLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    outstandingRatioLab.textColor = [QMUITheme textColorLevel1];
    [self.scrollerView addSubview:outstandingRatioLab];
    [outstandingRatioLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollerView).offset(14);
        make.top.equalTo(premiumLab.mas_bottom).offset(109);
        make.height.mas_equalTo(20);
    }];
    
    for (int i = 0; i<self.outstandingRatioArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:self.outstandingRatioArr[i] forState:UIControlStateNormal];
        if (i==0) {
            [self setSelectedStateWithBtn:btn];
        }else {
            [self setUnselectedStateWithBtn:btn];
        }
        [self.outstandingRatioBtnArr addObject:btn];
        [self.scrollerView addSubview:btn];
        if (i<3) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.scrollerView).offset(interval*(i+1)+(w*i));
                make.width.mas_equalTo(w);
                make.height.mas_equalTo(btnH);
                make.top.equalTo(outstandingRatioLab.mas_bottom).offset(10);
            }];
        }else {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.scrollerView).offset(interval*((i-3)+1)+(w*(i-3)));
                make.width.mas_equalTo(w);
                make.height.mas_equalTo(btnH);
                make.top.equalTo(outstandingRatioLab.mas_bottom).offset(54);
            }];
        }
        
        btn.tag = 40 + i;
        [btn addTarget:self action:@selector(outstandingRatioBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UILabel *outstandingPctLab = [[UILabel alloc] init];
    
    outstandingPctLab.text = [YXLanguageUtility kLangWithKey:@"warrants_strike"];
    outstandingPctLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    outstandingPctLab.textColor = [QMUITheme textColorLevel1];
    [self.scrollerView addSubview:outstandingPctLab];
    [outstandingPctLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollerView).offset(14);
        make.top.equalTo(outstandingRatioLab.mas_bottom).offset(109);
        make.height.mas_equalTo(20);
    }];
    
    [self.scrollerView addSubview:self.outstandingPctLowTextFld];
    [self.scrollerView addSubview:self.outstandingPctHeightTextFld];
    
    CGFloat textFldW = (YXConstant.screenWidth - 14*4)/2;
    [self.outstandingPctLowTextFld mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollerView).offset(14);
        make.top.equalTo(outstandingPctLab.mas_bottom).offset(10);
        make.width.mas_equalTo(textFldW);
        make.height.mas_equalTo(32);
    }];
    
    [self.outstandingPctHeightTextFld mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.outstandingPctLowTextFld.mas_right).offset(28);
        make.top.equalTo(outstandingPctLab.mas_bottom).offset(10);
        make.width.mas_equalTo(textFldW);
        make.height.mas_equalTo(32);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [QMUITheme.themeTintColor colorWithAlphaComponent:0.2];
    [self.scrollerView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.outstandingPctLowTextFld.mas_right).offset(9);
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(9);
        make.centerY.equalTo(self.outstandingPctLowTextFld);
    }];
    
    UILabel *exchangeRatioLab = [[UILabel alloc] init];
    exchangeRatioLab.text = [YXLanguageUtility kLangWithKey:@"warrants_conversionRatio"];
    exchangeRatioLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    exchangeRatioLab.textColor = [QMUITheme textColorLevel1];
    [self.scrollerView addSubview:exchangeRatioLab];
    [exchangeRatioLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollerView).offset(14);
        make.top.equalTo(outstandingPctLab.mas_bottom).offset(65);
        make.height.mas_equalTo(20);
    }];
    
    [self.scrollerView addSubview:self.exchangeRatioLowTextFld];
    [self.scrollerView addSubview:self.exchangeRatioHeightTextFld];
    
    [self.exchangeRatioLowTextFld mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollerView).offset(14);
        make.top.equalTo(exchangeRatioLab.mas_bottom).offset(10);
        make.width.mas_equalTo(textFldW);
        make.height.mas_equalTo(32);
    }];
    
    [self.exchangeRatioHeightTextFld mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.exchangeRatioLowTextFld.mas_right).offset(28);
        make.top.equalTo(exchangeRatioLab.mas_bottom).offset(10);
        make.width.mas_equalTo(textFldW);
        make.height.mas_equalTo(32);
    }];
    
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = [QMUITheme.themeTintColor colorWithAlphaComponent:0.2];
    [self.scrollerView addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.exchangeRatioLowTextFld.mas_right).offset(9);
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(9);
        make.centerY.equalTo(self.exchangeRatioLowTextFld);
    }];
    
    self.recoveryPriceLowTextFld = [self commonTextField];
    self.recoveryPriceHeightTextFld = [self commonTextField];
    [self.scrollerView addSubview:self.recoveryPriceLowTextFld];
    [self.scrollerView addSubview:self.recoveryPriceHeightTextFld];

    UILabel *recoveryPriceLabel = [[UILabel alloc] init];
    recoveryPriceLabel.text = [YXLanguageUtility kLangWithKey:@"warrants_call_level"];
    recoveryPriceLabel.textColor = [QMUITheme textColorLevel1];
    recoveryPriceLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.scrollerView addSubview:recoveryPriceLabel];
    [recoveryPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollerView).offset(14);
        make.top.equalTo(exchangeRatioLab.mas_bottom).offset(65);
        make.height.mas_equalTo(20);
    }];

    [self.recoveryPriceLowTextFld mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollerView).offset(14);
        make.top.equalTo(recoveryPriceLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(textFldW);
        make.height.mas_equalTo(32);
    }];
    
    [self.recoveryPriceHeightTextFld mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recoveryPriceLowTextFld.mas_right).offset(28);
        make.top.equalTo(recoveryPriceLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(textFldW);
        make.height.mas_equalTo(32);
    }];

    UIView *lineView3 = [[UIView alloc] init];
    lineView3.backgroundColor = [QMUITheme.themeTintColor colorWithAlphaComponent:0.2];
    [self.scrollerView addSubview:lineView3];
    [lineView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recoveryPriceLowTextFld.mas_right).offset(9);
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(9);
        make.centerY.equalTo(self.recoveryPriceLowTextFld);
    }];
    
    self.extendedVolatilityLowTextFld = [self commonTextField];
    self.extendedVolatilityHeightTextFld = [self commonTextField];
    [self.scrollerView addSubview:self.extendedVolatilityLowTextFld];
    [self.scrollerView addSubview:self.extendedVolatilityHeightTextFld];

    UILabel *extendedVolatilityLabel = [[UILabel alloc] init];
    extendedVolatilityLabel.text = [YXLanguageUtility kLangWithKey:@"warrants_volatility"];
    extendedVolatilityLabel.textColor = [QMUITheme textColorLevel1];
    extendedVolatilityLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.scrollerView addSubview:extendedVolatilityLabel];
    [extendedVolatilityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollerView).offset(14);
        make.top.equalTo(recoveryPriceLabel.mas_bottom).offset(65);
        make.height.mas_equalTo(20);
    }];

    [self.extendedVolatilityLowTextFld mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollerView).offset(14);
        make.top.equalTo(extendedVolatilityLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(textFldW);
        make.height.mas_equalTo(32);
    }];
    
    [self.extendedVolatilityHeightTextFld mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.extendedVolatilityLowTextFld.mas_right).offset(28);
        make.top.equalTo(extendedVolatilityLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(textFldW);
        make.height.mas_equalTo(32);
    }];

    UIView *lineView4 = [[UIView alloc] init];
    lineView4.backgroundColor = [QMUITheme.themeTintColor colorWithAlphaComponent:0.2];
    [self.scrollerView addSubview:lineView4];
    [lineView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.extendedVolatilityLowTextFld.mas_right).offset(9);
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(9);
        make.centerY.equalTo(self.extendedVolatilityLowTextFld);
    }];

}

#pragma mark- action
- (void)setSelectedStateWithBtn:(UIButton *)btn {
    [btn setTitleColor: [QMUITheme mainThemeColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    btn.layer.cornerRadius = 4;
    btn.backgroundColor = [QMUITheme.themeTextColor colorWithAlphaComponent:0.1];
    btn.layer.borderWidth = 0;
    btn.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)setUnselectedStateWithBtn:(UIButton *)btn {
    [btn setTitleColor: [QMUITheme textColorLevel2] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.backgroundColor = [UIColor clearColor];
    btn.layer.cornerRadius = 4;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [QMUITheme popSeparatorLineColor].CGColor;
}

- (void)setSelectedStateWithTextFld:(UITextField *)textFld {
    textFld.layer.borderWidth = 1;
    textFld.layer.cornerRadius = 4;
    textFld.layer.borderColor = [QMUITheme mainThemeColor].CGColor;
}

- (void)setUnSelectedStateWithTextFld:(UITextField *)textFld {
    textFld.layer.borderWidth = 1;
    textFld.layer.cornerRadius = 4;
    textFld.layer.borderColor = [QMUITheme popSeparatorLineColor].CGColor;
    
}

- (void)moneynessBtnAction:(UIButton *)btn {
    [self endEditing:YES];
    self.moneyness = btn.tag - 10;
    [self setAllBtnState];
}

- (void)leverageRatioBtnAction:(UIButton *)btn {
    [self endEditing:YES];
    self.leverageRatio = btn.tag - 20;
    [self setAllBtnState];
}

- (void)premiumBtnAction:(UIButton *)btn {
    [self endEditing:YES];
    self.premium = btn.tag - 30;
    [self setAllBtnState];
}

- (void)outstandingRatioBtnAction:(UIButton *)btn {
    [self endEditing:YES];
    self.outstandingRatio = btn.tag - 40;
    [self setAllBtnState];
}

- (void)confirmBtnAction {
    if (self.confirmBlock) {
        self.confirmBlock();
    }
}

- (void)resetBtnAction {
    
    self.outstandingPctLow = @"";
    self.outstandingPctHeight = @"";
    self.exchangeRatioLow = @"";
    self.exchangeRatioHeight = @"";
    self.recoveryPriceLow = @"";
    self.recoveryPriceHeight = @"";
    self.extendedVolatilityLow = @"";
    self.extendedVolatilityHeight = @"";

    
    self.moneyness = 0;
    self.leverageRatio = 0;
    self.premium = 0;
    self.outstandingRatio = 0;
    
    [self setAllBtnState];
  
}

#pragma mark- lazy load
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
//        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (UIScrollView *)scrollerView {
    if (!_scrollerView) {
        _scrollerView = [[UIScrollView alloc] init];
        _scrollerView.backgroundColor = QMUITheme.popupLayerColor;
    }
    return _scrollerView;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.backgroundColor = [QMUITheme mainThemeColor];
        [_confirmBtn setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
        
        [_confirmBtn setTitle: [YXLanguageUtility kLangWithKey:@"common_confirm"] forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_confirmBtn addTarget:self action:@selector(confirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        _confirmBtn.layer.cornerRadius = 4;
        _confirmBtn.layer.masksToBounds = true;
    }
    return _confirmBtn;
}


- (NSArray *)moneynessArr {
    if (!_moneynessArr) {
        _moneynessArr = @[[YXLanguageUtility kLangWithKey:@"common_all"], [YXLanguageUtility kLangWithKey:@"warrants_in"], [YXLanguageUtility kLangWithKey:@"warrants_out"]];
    }
    return _moneynessArr;
}

- (NSArray *)leverageRatioArr {
    if (!_leverageRatioArr) {
        _leverageRatioArr = @[[YXLanguageUtility kLangWithKey:@"common_all"], [YXLanguageUtility kLangWithKey:@"warrants_less_1_multiple"], [YXLanguageUtility kLangWithKey:@"warrants_1_5_multiple"], [YXLanguageUtility kLangWithKey:@"warrants_5_10_multiple"], [YXLanguageUtility kLangWithKey:@"warrants_morethan_10_multiple"]];
    }
    return _leverageRatioArr;
}

- (NSArray *)premiumArr {
    if (!_premiumArr) {
        _premiumArr = @[[YXLanguageUtility kLangWithKey:@"common_all"], @"0-3", @"3-6", @"6-9", @">9"];
    }
    return _premiumArr;
}

- (NSArray *)outstandingRatioArr {
    if (!_outstandingRatioArr) {
        _outstandingRatioArr = @[[YXLanguageUtility kLangWithKey:@"common_all"], @"<30", @"30-50", @"50-70", @">70"];
    }
    return _outstandingRatioArr;
}

- (YXTextField *)outstandingPctLowTextFld {
    if (!_outstandingPctLowTextFld) {
        _outstandingPctLowTextFld = [[YXTextField alloc] init];
        _outstandingPctLowTextFld.textColor = QMUITheme.textColorLevel2;
        _outstandingPctLowTextFld.font = [UIFont systemFontOfSize:14];
        _outstandingPctLowTextFld.delegate = self;
        _outstandingPctLowTextFld.banAction = YES;
        _outstandingPctLowTextFld.keyboardType = UIKeyboardTypeDecimalPad;
        _outstandingPctLowTextFld.integerBitCount = 5;
        _outstandingPctLowTextFld.decimalBitCount = 3;
        _outstandingPctLowTextFld.inputType = InputTypeMoney;
        _outstandingPctLowTextFld.textAlignment = NSTextAlignmentCenter;
        [self setUnSelectedStateWithTextFld:_outstandingPctLowTextFld];
    }
    return _outstandingPctLowTextFld;
}

- (YXTextField *)outstandingPctHeightTextFld {
    if (!_outstandingPctHeightTextFld) {
        _outstandingPctHeightTextFld = [[YXTextField alloc] init];
        _outstandingPctHeightTextFld.textColor = QMUITheme.textColorLevel2;
        _outstandingPctHeightTextFld.font = [UIFont systemFontOfSize:14];
        _outstandingPctHeightTextFld.delegate = self;
        _outstandingPctHeightTextFld.banAction = YES;
        _outstandingPctHeightTextFld.keyboardType = UIKeyboardTypeDecimalPad;
        _outstandingPctHeightTextFld.integerBitCount = 5;
        _outstandingPctHeightTextFld.decimalBitCount = 3;
        _outstandingPctHeightTextFld.inputType = InputTypeMoney;
        _outstandingPctHeightTextFld.textAlignment = NSTextAlignmentCenter;
        [self setUnSelectedStateWithTextFld:_outstandingPctHeightTextFld];
    }
    return _outstandingPctHeightTextFld;
}

- (YXTextField *)exchangeRatioLowTextFld {
    if (!_exchangeRatioLowTextFld) {
        _exchangeRatioLowTextFld = [[YXTextField alloc] init];
        _exchangeRatioLowTextFld.textColor = QMUITheme.textColorLevel2;
        _exchangeRatioLowTextFld.font = [UIFont systemFontOfSize:14];
        _exchangeRatioLowTextFld.delegate = self;
        _exchangeRatioLowTextFld.banAction = YES;
        _exchangeRatioLowTextFld.keyboardType = UIKeyboardTypeDecimalPad;
        _exchangeRatioLowTextFld.integerBitCount = 5;
        _exchangeRatioLowTextFld.decimalBitCount = 3;
        _exchangeRatioLowTextFld.inputType = InputTypeMoney;
        _exchangeRatioLowTextFld.textAlignment = NSTextAlignmentCenter;
        [self setUnSelectedStateWithTextFld:_exchangeRatioLowTextFld];
    }
    return _exchangeRatioLowTextFld;
}

- (YXTextField *)exchangeRatioHeightTextFld {
    if (!_exchangeRatioHeightTextFld) {
        _exchangeRatioHeightTextFld = [[YXTextField alloc] init];
        _exchangeRatioHeightTextFld.textColor = QMUITheme.textColorLevel2;
        _exchangeRatioHeightTextFld.font = [UIFont systemFontOfSize:14];
        _exchangeRatioHeightTextFld.delegate = self;
        _exchangeRatioHeightTextFld.banAction = YES;
        _exchangeRatioHeightTextFld.keyboardType = UIKeyboardTypeDecimalPad;
        _exchangeRatioHeightTextFld.integerBitCount = 5;
        _exchangeRatioHeightTextFld.decimalBitCount = 3;
        _exchangeRatioHeightTextFld.inputType = InputTypeMoney;
        _exchangeRatioHeightTextFld.textAlignment = NSTextAlignmentCenter;
        [self setUnSelectedStateWithTextFld:_exchangeRatioHeightTextFld];
    }
    return _exchangeRatioHeightTextFld;
}

- (YXTextField *)commonTextField {
    YXTextField *textField = [[YXTextField alloc] init];
    textField.textColor = QMUITheme.textColorLevel2;
    textField.font = [UIFont systemFontOfSize:14];
    textField.delegate = self;
    textField.banAction = YES;
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    textField.integerBitCount = 5;
    textField.decimalBitCount = 3;
    textField.inputType = InputTypeMoney;
    textField.textAlignment = NSTextAlignmentCenter;
    [self setUnSelectedStateWithTextFld:textField];
    return textField;
}

- (void)setAllBtnState {
    
    for (UIButton *btn in self.moneynessBtnArr) {
        [self setUnselectedStateWithBtn:btn];
    }
    for (UIButton *btn in self.leverageRatioBtnArr) {
        [self setUnselectedStateWithBtn:btn];
    }
    for (UIButton *btn in self.premiumBtnArr) {
        [self setUnselectedStateWithBtn:btn];
    }
    for (UIButton *btn in self.outstandingRatioBtnArr) {
        [self setUnselectedStateWithBtn:btn];
    }
    
    if (self.moneynessBtnArr.count >  self.moneyness) {
        UIButton *btn = self.moneynessBtnArr[self.moneyness];
        [self setSelectedStateWithBtn:btn];
    }
    if (self.leverageRatioBtnArr.count >  self.leverageRatio) {
        UIButton *btn = self.leverageRatioBtnArr[self.leverageRatio];
        [self setSelectedStateWithBtn:btn];
    }
    if (self.premiumBtnArr.count >  self.premium) {
        UIButton *btn = self.premiumBtnArr[self.premium];
        [self setSelectedStateWithBtn:btn];
    }
    if (self.outstandingRatioBtnArr.count >  self.outstandingRatio) {
        UIButton *btn = self.outstandingRatioBtnArr[self.outstandingRatio];
        [self setSelectedStateWithBtn:btn];
    }
    
    self.outstandingPctLowTextFld.text = self.outstandingPctLow;
    self.outstandingPctHeightTextFld.text = self.outstandingPctHeight;
    
    self.exchangeRatioLowTextFld.text = self.exchangeRatioLow;
    self.exchangeRatioHeightTextFld.text = self.exchangeRatioHeight;
    
    self.recoveryPriceLowTextFld.text = self.recoveryPriceLow;
    self.recoveryPriceHeightTextFld.text = self.recoveryPriceHeight;
    
    self.extendedVolatilityLowTextFld.text = self.extendedVolatilityLow;
    self.extendedVolatilityHeightTextFld.text = self.extendedVolatilityHeight;

}

#pragma mark- delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self setSelectedStateWithTextFld:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self setUnSelectedStateWithTextFld:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    YXTextField *t = (YXTextField *)textField;
    return [t textField:textField shouldChangeCharactersIn:range replacementString:string];
}

@end
