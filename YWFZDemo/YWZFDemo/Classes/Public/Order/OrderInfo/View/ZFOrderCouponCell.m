//
//  ZFOrderCouponCell.m
//  ZZZZZ
//
//  Created by YW on 20/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderCouponCell.h"
#import "ZFInitViewProtocol.h"
#import "FilterManager.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "UIView+ZFViewCategorySet.h"

@interface ZFOrderCouponCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *infoLabel;
@property (nonatomic, strong) UILabel               *amountLabel;
@property (nonatomic, strong) UIImageView           *arrowImage;
@property (nonatomic, strong) UIView                *separatorLine;
@end

@implementation ZFOrderCouponCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - Public method
+ (NSString *)queryReuseIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    self.contentView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.infoLabel];
    [self.contentView addSubview:self.amountLabel];
    [self.contentView addSubview:self.arrowImage];
    [self.contentView addSubview:self.separatorLine];
}

- (void)zfAutoLayoutView {
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(12);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.arrowImage.mas_leading).mas_offset(5);
        make.centerY.mas_equalTo(self.infoLabel);
    }];
    
    [self.arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.trailing.mas_equalTo(0);
        make.leading.mas_equalTo(12);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self zfAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 8)];
}

#pragma mark - Setter
- (void)setCouponAmount:(NSString *)couponAmount {
    _couponAmount = couponAmount;
    self.amountLabel.text = couponAmount;
}

- (void)initCouponAmount:(NSString *)couponAmount {
    _couponAmount = couponAmount;
    self.amountLabel.text = couponAmount;
}

#pragma mark - Getter

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:14];
        _infoLabel.textColor = ZFC0x2D2D2D();
        _infoLabel.text = ZFLocalizedString(@"CartOrderInfo_PromotionCodeCell_PromotionCodeLabel",nil);
        [_infoLabel sizeToFit];
    }
    return _infoLabel;
}

- (UILabel *)amountLabel {
    if (!_amountLabel) {
        _amountLabel = [[UILabel alloc] init];
        _amountLabel.font = [UIFont systemFontOfSize:14];
        _amountLabel.textColor = ZFC0xFE5269();
    }
    return _amountLabel;
}

- (UIImageView *)arrowImage
{
    if (!_arrowImage) {
        _arrowImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = [UIImage imageNamed:@"account_arrow_right"];
            [img convertUIWithARLanguage];
            img;
        });
    }
    return _arrowImage;
}

- (UIView *)separatorLine {
    if (!_separatorLine) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    }
    return _separatorLine;
}

@end
