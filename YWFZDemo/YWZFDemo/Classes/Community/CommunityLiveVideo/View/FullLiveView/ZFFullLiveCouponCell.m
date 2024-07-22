//
//  ZFFullLiveCouponCell.m
//  ZZZZZ
//
//  Created by YW on 2019/12/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveCouponCell.h"
#import "UIColor+ExTypeChange.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"

@implementation ZFFullLiveCouponCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = ZFC0xFFFFFF();
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtoclo
- (void)zfInitView {
    [self.contentView addSubview:self.contentBackView];
    
    [self.contentBackView addSubview:self.contentImageView];
    
    [self.contentImageView addSubview:self.codeLabel];
    [self.contentImageView addSubview:self.dateLabel];
    
    [self.contentImageView addSubview:self.invalidCouponIcon];
    [self.invalidCouponIcon addSubview:self.invalidText];
    
    [self.contentBackView addSubview:self.expiresLabel];
    self.contentBackView.layer.cornerRadius = 5;
    
    [self.contentBackView addSubview:self.receiveButton];

}

- (void)zfAutoLayoutView {
    [self.contentBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(6);
        make.leading.mas_equalTo(self.contentView).offset(16);
        make.trailing.mas_equalTo(self.contentView).offset(-16);
        make.bottom.mas_equalTo(self.contentView).offset(-6);
    }];
    
    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentBackView);
        make.leading.mas_equalTo(self.contentBackView);
        make.trailing.mas_equalTo(self.contentBackView);
    }];
    
    CGFloat leftPadding = 18.0;
    //优惠券优惠金额
    [self.codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentBackView.mas_leading).offset(leftPadding);
    }];
    
    //优惠券到期时间
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.codeLabel.mas_bottom).offset(5);
        make.centerY.mas_equalTo(self.contentBackView.mas_centerY);
        make.leading.mas_equalTo(self.codeLabel.mas_leading);
        make.trailing.mas_equalTo(self.contentBackView.mas_trailing);
    }];
    
    //优惠券明细
    [self.expiresLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dateLabel.mas_bottom).mas_offset(6);
        make.leading.mas_equalTo(self.codeLabel.mas_leading);
        make.trailing.mas_equalTo(self.contentBackView.mas_trailing);
    }];
    
    [self.invalidCouponIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentBackView).offset(5);
        make.bottom.mas_equalTo(self.contentBackView.mas_bottom).offset(13);
        make.width.height.mas_offset(72);
    }];
    
    [self.invalidText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.invalidCouponIcon);
        make.trailing.leading.mas_equalTo(self.invalidCouponIcon);
    }];
    
    [self.receiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentBackView.mas_trailing).offset(-20.0f);
        make.height.mas_offset(28);
        make.width.mas_greaterThanOrEqualTo(70);
        make.width.mas_lessThanOrEqualTo(120);
        make.centerY.mas_equalTo(self.contentBackView.mas_centerY);
    }];
    
}


- (void)actionReceive:(UIButton *)sender {
    if (self.selectBlock) {
        self.selectBlock();
    }
}

- (void)configurate:(ZFGoodsDetailCouponModel *)couponModel canReceive:(BOOL)canReceive {
    self.isCanReceive = canReceive;
    self.couponModel = couponModel;
}

#pragma mark - setter/getter

- (void)setCouponModel:(ZFGoodsDetailCouponModel *)couponModel {
    
    _couponModel = couponModel;
    
    self.codeLabel.text = ZFToString(couponModel.preferentialHead);
    self.dateLabel.text = ZFToString(couponModel.endTime);
    self.expiresLabel.text = ZFToString(couponModel.discounts);
    self.invalidCouponIcon.hidden = YES;
    self.receiveButton.hidden = YES;
    NSString *invalidTitle = @"";
    
    // coupon状态；1:可领取;2:已领取;3:已领取完
    if (couponModel.couponStats == 1) {
        self.receiveButton.hidden = NO;
        self.codeLabel.textColor = ZFC0xFFFFFF();
        self.expiresLabel.textColor = ZFC0xFFFFFF();
        self.dateLabel.textColor = ZFC0xFFFFFF();
        self.contentImageView.image = ZFImageWithName(@"live_coupon_big_bg");
        
        if (self.isCanReceive) {
            self.receiveButton.backgroundColor = ZFC0xFFFFFF();
        } else {
            self.receiveButton.backgroundColor = ZFC0xFFBCBC();
        }
    } else if (couponModel.couponStats == 2) {
        self.invalidCouponIcon.hidden = NO;
        self.codeLabel.textColor = ZFC0xAAAAAA();
        self.expiresLabel.textColor = ZFC0xAAAAAA();
        self.dateLabel.textColor = ZFC0xAAAAAA();
        invalidTitle = ZFLocalizedString(@"Detail_CouponClaimed", nil);
        self.contentImageView.image = ZFImageWithName(@"live_coupon_big_bggray");
    } else {
        self.invalidCouponIcon.hidden = NO;
        self.codeLabel.textColor = ZFC0xAAAAAA();
        self.expiresLabel.textColor = ZFC0xAAAAAA();
        self.dateLabel.textColor = ZFC0xAAAAAA();
        invalidTitle = ZFLocalizedString(@"Detail_CouponUsedUp", nil);
        self.contentImageView.image = ZFImageWithName(@"live_coupon_big_bggray");
    }
    self.invalidText.text = invalidTitle;
}

-(UIView *)contentBackView
{
    if (!_contentBackView) {
        _contentBackView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            view;
        });
    }
    return _contentBackView;
}

- (UIImageView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView                 = [[UIImageView alloc] init];
        _contentImageView.backgroundColor = [UIColor clearColor];
        _contentImageView.contentMode     =  UIViewContentModeScaleToFill;
        _contentImageView.layer.masksToBounds = YES;
        _contentImageView.userInteractionEnabled = YES;
    }
    return _contentImageView;
}

- (UILabel *)codeLabel {
    if (!_codeLabel) {
        _codeLabel = [[UILabel alloc] init];
        _codeLabel.textColor = [UIColor whiteColor];
        _codeLabel.font = [UIFont boldSystemFontOfSize:18.0];
    }
    return _codeLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _dateLabel;
}

- (UILabel *)expiresLabel {
    if (!_expiresLabel) {
        _expiresLabel = [[UILabel alloc] init];
        _expiresLabel.textColor = ZFC0xFFFFFF();
        _expiresLabel.font = [UIFont systemFontOfSize:14.0];
        _expiresLabel.numberOfLines = 0;
    }
    return _expiresLabel;
}


- (UIButton *)receiveButton {
    if (!_receiveButton) {
        _receiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _receiveButton.backgroundColor = ZFC0xFFFFFF();
        [_receiveButton setTitleColor:ZFC0xFF6E81() forState:UIControlStateNormal];
        _receiveButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _receiveButton.layer.cornerRadius = 14;
        _receiveButton.layer.masksToBounds = YES;
        [_receiveButton setTitle:ZFLocalizedString(@"Detail_ReceiveCouponTitle", nil) forState:UIControlStateNormal];
        _receiveButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        [_receiveButton addTarget:self action:@selector(actionReceive:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _receiveButton;
}


- (UIImageView *)invalidCouponIcon
{
    if (!_invalidCouponIcon) {
        _invalidCouponIcon = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = ZFImageWithName(@"Coupon_tag");
            img;
        });
    }
    return _invalidCouponIcon;
}

-(UILabel *)invalidText
{
    if (!_invalidText) {
        _invalidText = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = @"";
            label.textColor = [UIColor colorWithHexString:@"CCCCCC"];
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _invalidText;
}

@end
