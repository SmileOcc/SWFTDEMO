//
//  ZFCouponWarningView.m
//  ZZZZZ
//
//  Created by YW on 2017/12/2.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCouponWarningView.h"
#import "ZFInitViewProtocol.h"
#import "FilterManager.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFCouponWarningView() <ZFInitViewProtocol>

@property (nonatomic, strong) UIView  *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation ZFCouponWarningView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = ZFCOLOR(255, 237, 245, 1);
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.contentLabel];
}

- (void)zfAutoLayoutView {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.leading.mas_equalTo(self.contentView.mas_leading);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(5.0f);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
    }];
}

#pragma mark - getter/setter
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ZFC0xFE5269();
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.text = ZFLocalizedString(@"MyCoupon_Coupon_Warning_Title", nil);
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = ZFC0xFE5269();
        _contentLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _contentLabel;
}

- (void)setCouponAmount:(NSString *)couponAmount {
    _couponAmount = couponAmount;
    
    NSString *money = [FilterManager adapterCodWithAmount:couponAmount andCod:self.currentPaymentType == CurrentPaymentTypeCOD priceType:PriceType_Coupon];
    
    NSString *contentText = [NSString stringWithFormat:ZFLocalizedString(@"MyCoupon_Coupon_Warning_Content", nil), money];
    
    NSMutableAttributedString *textAttr = [[NSMutableAttributedString alloc] initWithString:contentText];
    
    NSRange range = [contentText rangeOfString:money];
    if (contentText.length >= (range.location + range.length)) {
        
        [textAttr addAttributes:@{
            NSForegroundColorAttributeName : ZFC0xFE5269(),
            NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
        } range:range];
    }
    self.contentLabel.text = nil;
    self.contentLabel.attributedText = textAttr;
}

@end
