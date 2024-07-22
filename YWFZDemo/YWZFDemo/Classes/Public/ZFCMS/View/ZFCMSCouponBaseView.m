//
//  ZFCMSCouponBaseView.m
//  ZZZZZ
//
//  Created by YW on 2019/11/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSCouponBaseView.h"

@implementation ZFCMSCouponBaseView

- (void)updateItem:(ZFCMSItemModel *)itemModel sectionModel:(ZFCMSSectionModel *)sectionModel contentSize:(CGSize )contentSize {
    
}

- (void)configurateColor:(ZFCMSItemModel *)itemModel {
    
}
- (YYAnimatedImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _bgImageView.hidden = YES;
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bgImageView;
}


- (UIView *)descContentView {
    if (!_descContentView) {
        _descContentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _descContentView;
}


- (UILabel *)couponTitleLabel {
    if (!_couponTitleLabel) {
        _couponTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _couponTitleLabel.textAlignment = NSTextAlignmentCenter;
        _couponTitleLabel.textColor = ColorHex_Alpha(0x5F1818, 1.0);
        _couponTitleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _couponTitleLabel;
}

- (UILabel *)couponDescLabel {
    if (!_couponDescLabel) {
        _couponDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _couponDescLabel.textAlignment = NSTextAlignmentCenter;
        _couponDescLabel.textColor = ColorHex_Alpha(0xCA7373, 1.0);
    }
    return _couponDescLabel;
}

- (UILabel *)numsPercentageLabel {
    if (!_numsPercentageLabel) {
        _numsPercentageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numsPercentageLabel.textColor = ColorHex_Alpha(0x5F1818, 1);
    }
    return _numsPercentageLabel;
}

- (UIView *)couponStateContentView {
    if (!_couponStateContentView) {
        _couponStateContentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _couponStateContentView;
}

- (UIButton *)couponStateButton {
    if (!_couponStateButton) {
        _couponStateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _couponStateButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        [_couponStateButton setTitle:ZFLocalizedString(@"Hom_Coupon_Claim", nil) forState:UIControlStateNormal];
        _couponStateButton.userInteractionEnabled = NO;
    }
    return _couponStateButton;
}

- (QLCycleProgressView *)circleProgressView {
    if (!_circleProgressView) {
        _circleProgressView = [[QLCycleProgressView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)];
        _circleProgressView.needAnimation = NO;
        _circleProgressView.mainColor = ZFCThemeColor_A(0.3);
        _circleProgressView.fillColor = ColorHex_Alpha(0xFE5269, 0.36);
        _circleProgressView.progress = 0;
        _circleProgressView.hidden = YES;
    }
    return _circleProgressView;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _progressLabel.textColor = ColorHex_Alpha(0x5F1818, 1.0);
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font = [UIFont systemFontOfSize:8];
        _progressLabel.numberOfLines = 2;

    }
    return _progressLabel;
}

- (ZFCMSLineProgressView *)horizontalProgressView {
    if (!_horizontalProgressView) {
        _horizontalProgressView = [[ZFCMSLineProgressView alloc] initWithFrame:CGRectZero];
        _horizontalProgressView.hidden = YES;
    }
    return _horizontalProgressView;
}

- (UIImageView *)couponStateImageView {
    if (!_couponStateImageView) {
        _couponStateImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _couponStateImageView;
}

- (UIView *)whiteCircleViewOne {
    if (!_whiteCircleViewOne) {
        _whiteCircleViewOne = [[UIView alloc] initWithFrame:CGRectZero];
        _whiteCircleViewOne.backgroundColor = ZFC0xFFFFFF();
        _whiteCircleViewOne.layer.cornerRadius = kCouponItemWhiteH / 2.0;
        _whiteCircleViewOne.layer.masksToBounds = YES;
    }
    return _whiteCircleViewOne;
}

- (UIView *)whiteCircleViewTwo {
    if (!_whiteCircleViewTwo) {
        _whiteCircleViewTwo = [[UIView alloc] initWithFrame:CGRectZero];
        _whiteCircleViewTwo.backgroundColor = ZFC0xFFFFFF();
        _whiteCircleViewTwo.layer.cornerRadius = kCouponItemWhiteH / 2.0;
        _whiteCircleViewTwo.layer.masksToBounds = YES;
    }
    return _whiteCircleViewTwo;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor clearColor];
    }
    return _lineView;
}
@end
