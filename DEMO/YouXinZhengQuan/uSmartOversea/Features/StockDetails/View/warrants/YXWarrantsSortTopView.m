//
//  YXWarrantsSortTopView.m
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/6/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXWarrantsSortTopView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@implementation YXWarrantsSortTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSortView];
    }
    return self;
}

- (instancetype)initSgWarrantsWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.typeBtn];
        self.typeBtn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
        
        [self addSubview:self.dateBtn];
        self.dateBtn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
        
        [self addSubview:self.moreBtn];
        self.moreBtn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;


        UIView *lineView = [UIView lineView];
        [self addSubview:lineView];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.typeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(16);
            make.top.bottom.equalTo(self);
        }];
        
        
        [self.dateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.typeBtn.mas_right).offset(24);
            make.top.bottom.equalTo(self);
        }];
        
        [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-16);
            make.top.bottom.equalTo(self);
        }];
    }
    return self;
}

- (QMUIButton *)creatButton {
    QMUIButton *btn = [[QMUIButton alloc] init];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.spacingBetweenImageAndTitle = 3;
    btn.imagePosition = QMUIButtonImagePositionRight;
    UIImage *arrowImageNormal = [[UIImage imageNamed:@"warrant_filter_arrow"] qmui_imageWithTintColor: [QMUITheme textColorLevel3]];
    UIImage *arrowImageSelected = [[UIImage imageNamed:@"warrant_filter_arrow"] qmui_imageWithTintColor: [QMUITheme themeTintColor]];
    [btn setImage:arrowImageNormal forState:UIControlStateNormal];
    [btn setImage:arrowImageSelected forState:UIControlStateSelected];
    [btn setTitleColor: [QMUITheme textColorLevel3] forState:UIControlStateNormal];
    [btn setTitleColor: [QMUITheme themeTintColor] forState:UIControlStateSelected];
    
    return btn;
}

- (QMUIButton *)typeBtn {
    if (!_typeBtn){
        _typeBtn = [self creatButton];
        [_typeBtn setTitle: [YXLanguageUtility kLangWithKey:@"warrants_type"] forState:UIControlStateNormal];
        _typeBtn.titleLabel.adjustsFontSizeToFitWidth = true;
        _typeBtn.titleLabel.minimumScaleFactor = 0.8;
        _typeBtn.titleLabel.numberOfLines = 2;
    }
    return _typeBtn;
}

- (QMUIButton *)issuerBtn {
    if (!_issuerBtn){
        _issuerBtn = [self creatButton];
        [_issuerBtn setTitle:[YXLanguageUtility kLangWithKey:@"stock_issuer"] forState:UIControlStateNormal];
        _issuerBtn.titleLabel.adjustsFontSizeToFitWidth = true;
        _issuerBtn.titleLabel.minimumScaleFactor = 0.8;
        _issuerBtn.titleLabel.numberOfLines = 2;
    }
    return _issuerBtn;
}

- (QMUIButton *)dateBtn {
    if (!_dateBtn){
        _dateBtn = [self creatButton];
        [_dateBtn setTitle:[YXLanguageUtility kLangWithKey:@"warrants_end_date"] forState:UIControlStateNormal];
        _dateBtn.titleLabel.adjustsFontSizeToFitWidth = true;
        _dateBtn.titleLabel.minimumScaleFactor = 0.8;
        _dateBtn.titleLabel.numberOfLines = 2;
    }
    return _dateBtn;
}

- (QMUIButton *)moreBtn {
    if (!_moreBtn){
        _moreBtn = [self creatButton];
        UIImage *arrowImageNormal = [[UIImage imageNamed:@"warrant_filter"] qmui_imageWithTintColor: [QMUITheme textColorLevel3]];
        UIImage *arrowImageSelected = [[UIImage imageNamed:@"warrant_filter"] qmui_imageWithTintColor: [QMUITheme themeTintColor]];
        [_moreBtn setImage:arrowImageNormal forState:UIControlStateNormal];
        [_moreBtn setImage:arrowImageSelected forState:UIControlStateSelected];
        [_moreBtn setTitle: [YXLanguageUtility kLangWithKey:@"warrants_more_sort"] forState:UIControlStateNormal];
        _moreBtn.titleLabel.adjustsFontSizeToFitWidth = true;
        _moreBtn.titleLabel.minimumScaleFactor = 0.8;
        _moreBtn.titleLabel.numberOfLines = 2;
    }
    return _moreBtn;
}

- (void)setupSortView {
    [self addSubview:self.typeBtn];
    [self addSubview:self.issuerBtn];
    [self addSubview:self.dateBtn];
    [self addSubview:self.moreBtn];

    UIView *lineView = [UIView lineView];
    [self addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
    CGFloat scale = YXConstant.screenWidth / 375.0;
    CGFloat btnW = 80 * scale;
    CGFloat spaceW = 16 * scale;
    //泰语文案太长了
    if ([YXUserManager curLanguage] == YXLanguageTypeTH) {
        spaceW = 12 * scale;
    }
    
    //最后一个按钮  加个15的宽
    CGFloat lastBtnW = YXConstant.screenWidth - 16*2 - spaceW * 3 - btnW * 3 + 15;
    
    [self.typeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.top.bottom.equalTo(self);
        make.width.mas_lessThanOrEqualTo(btnW);
    }];
    
    [self.issuerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.typeBtn.mas_right).offset(13);
        make.top.bottom.equalTo(self);
        make.width.mas_lessThanOrEqualTo(btnW);
    }];
    
    [self.dateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.issuerBtn.mas_right).offset(13);
        make.top.bottom.equalTo(self);
        make.width.mas_lessThanOrEqualTo(btnW);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(lastBtnW);
    }];
    
//    [self setBtnEdgeInsets];
}

- (void)setBtnEdgeInsets {

    self.moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -self.moreBtn.imageView.image.size.width, 0, self.moreBtn.imageView.image.size.width);
    self.moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, self.moreBtn.titleLabel.frame.size.width-2, 0, -(self.moreBtn.titleLabel.frame.size.width+2));

    self.dateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -self.dateBtn.imageView.image.size.width, 0, self.dateBtn.imageView.image.size.width);
    self.dateBtn.imageEdgeInsets = UIEdgeInsetsMake(0, self.dateBtn.titleLabel.frame.size.width-10, 0, -(self.dateBtn.titleLabel.frame.size.width+13));

    self.issuerBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -self.issuerBtn.imageView.image.size.width, 0, self.issuerBtn.imageView.image.size.width);
    self.issuerBtn.imageEdgeInsets = UIEdgeInsetsMake(0, self.issuerBtn.titleLabel.frame.size.width-10, 0, -(self.issuerBtn.titleLabel.frame.size.width+13));

    self.typeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -self.typeBtn.imageView.image.size.width+10, 0, self.typeBtn.imageView.image.size.width-10);
    self.typeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, self.typeBtn.titleLabel.frame.size.width+12, 0, -(self.typeBtn.titleLabel.frame.size.width-12));
}

- (void)setIssuerBtnSelected {
    [self.issuerBtn setTitleColor:[QMUITheme textColorLevel2] forState:UIControlStateNormal];
//    [self.issuerBtn setImage:[UIImage arrowWithColor:QMUITheme.themeTextColor size:CGSizeMake(9, 4.5)] forState:UIControlStateNormal];
}

- (void)setIssuerBtnNormal {
    [self.issuerBtn setTitleColor:[QMUITheme textColorLevel3] forState:UIControlStateNormal];
//    [self.issuerBtn setImage:[UIImage arrowWithColor: [QMUITheme.themeTintColor colorWithAlphaComponent:0.4] size:CGSizeMake(9, 4.5)] forState:UIControlStateNormal];
}

- (void)setTypeBtnSelected {
    [self.typeBtn setTitleColor: [QMUITheme textColorLevel2] forState:UIControlStateNormal];
//    [self.typeBtn setImage:[UIImage arrowWithColor: QMUITheme.themeTextColor size:CGSizeMake(9, 4.5)] forState:UIControlStateNormal];
}

- (void)setTypeBtnNormal {
    [self.typeBtn setTitleColor: [QMUITheme textColorLevel3] forState:UIControlStateNormal];
//    [self.typeBtn setImage: [UIImage arrowWithColor: [QMUITheme.themeTintColor colorWithAlphaComponent:0.4] size:CGSizeMake(9, 4.5)] forState:UIControlStateNormal];
}

- (void)setDateBtnSelected {
//    [self.dateBtn setImage:[UIImage arrowWithColor: QMUITheme.themeTextColor size:CGSizeMake(9, 4.5)] forState:UIControlStateNormal];
    [self.dateBtn setTitleColor:[QMUITheme textColorLevel2] forState:UIControlStateNormal];
}

- (void)setDateBtnNormal {
//    [self.dateBtn setImage: [UIImage arrowWithColor: [QMUITheme.themeTintColor colorWithAlphaComponent:0.4] size:CGSizeMake(9, 4.5)] forState:UIControlStateNormal];
    [self.dateBtn setTitleColor: [QMUITheme textColorLevel3] forState:UIControlStateNormal];
}

- (void)setMoreBtnSelected {
    [self.moreBtn setTitleColor: [QMUITheme textColorLevel2] forState: UIControlStateNormal];
//    [self.moreBtn setImage: [UIImage imageNamed:@"warrants_sort_s"] forState:UIControlStateNormal];
}

- (void)setMoreBtnNormal {
    [self.moreBtn setTitleColor: [QMUITheme textColorLevel3] forState:UIControlStateNormal];
//    [self.moreBtn setImage: [UIImage imageNamed:@"warrants_sort"] forState:UIControlStateNormal];
}

- (void)setSortBtnState {
    
    if (self.typeArr.count > self.type) {
        switch (self.type) {
            case YXBullAndBellTypeBull:
                [self.typeBtn setTitle:[YXLanguageUtility kLangWithKey:@"warrants_bull"] forState:UIControlStateNormal];
                break;
            case YXBullAndBellTypeBear:
                [self.typeBtn setTitle:[YXLanguageUtility kLangWithKey:@"warrants_bear"] forState:UIControlStateNormal];

                break;
            case YXBullAndBellTypeSell:
                
                [self.typeBtn setTitle:[YXLanguageUtility kLangWithKey:@"warrants_sell"] forState:UIControlStateNormal];
                break;
            case YXBullAndBellTypeBuy:
                [self.typeBtn setTitle:[YXLanguageUtility kLangWithKey:@"warrants_buy"] forState:UIControlStateNormal];

                break;
            default:
                
                [self.typeBtn setTitle: [YXLanguageUtility kLangWithKey:@"warrants_type"] forState:UIControlStateNormal];
                break;
        }
    }
    
    if (self.dateArr.count > self.expireDate) {
        if (self.expireDate > 0) {
            
            [self.dateBtn setTitle:self.dateArr[self.expireDate] forState:UIControlStateNormal];
        }else {
            
            [self.dateBtn setTitle: [YXLanguageUtility kLangWithKey:@"warrants_end_date"] forState:UIControlStateNormal];
        }
    }
    
    if (self.issuerIndex == 0) {
        [self.issuerBtn setTitle:[YXLanguageUtility kLangWithKey:@"stock_issuer"] forState:UIControlStateNormal];
    } else {
        [self.issuerBtn setTitle:self.issuerArr[self.issuerIndex] forState:UIControlStateNormal];
    }
    
    if (self.moneyness > 0 ||
        self.leverageRatio > 0 ||
        self.premium > 0 ||
        self.outstandingRatio > 0 ||
        self.outstandingPctLow.length > 0 ||
        self.outstandingPctHeight.length > 0 ||
        self.exchangeRatioLow.length > 0 ||
        self.exchangeRatioHeight.length > 0 ||
        self.recoveryPriceLow.length > 0 ||
        self.recoveryPriceHeight.length > 0 ||
        self.extendedVolatilityLow.length > 0 ||
        self.extendedVolatilityHeight.length > 0) {
        
        [self setMoreBtnSelected];
    }else {
        [self setMoreBtnNormal];
    }
    
//    [self setBtnEdgeInsets];
}

- (void)setAllButtonNormal {
    self.typeBtn.selected = NO;
    self.issuerBtn.selected = NO;
    self.dateBtn.selected = NO;
    self.moreBtn.selected = NO;
}

- (void)setSelectedWithButton:(UIButton *)btn {
    self.typeBtn.selected = NO;
    self.issuerBtn.selected = NO;
    self.dateBtn.selected = NO;
    self.moreBtn.selected = NO;
    
    btn.selected = YES;
}
@end
