//
//  OSSVBottomeButtonseView.m
// XStarlinkProject
//
//  Created by Kevin on 2021/1/27.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBottomeButtonseView.h"

@implementation OSSVBottomeButtonseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.cancelBtn];
        [self addSubview:self.payNowBtn];
        [self addSubview:self.buyAgainBtn];
        [self addSubview:self.reviewBtn];
        
        [self addSubview:self.topLineView];
        
        [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(1);
        }];

    }
    return self;
}


- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _topLineView.backgroundColor = [STLThemeColor col_EEEEEE];
    }
    return _topLineView;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.tag = OrderCancel;
        _cancelBtn.hidden = YES;
        _cancelBtn.backgroundColor = [UIColor clearColor];
        [_cancelBtn setTitleColor:[STLThemeColor col_0D0D0D] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        if (APP_TYPE == 3) {
            [_cancelBtn setTitle:STLLocalizedString_(@"cancel", nil) forState:UIControlStateNormal];
        } else {
            [_cancelBtn setTitle:[STLLocalizedString_(@"cancel", nil) uppercaseString] forState:UIControlStateNormal];
        }
        _cancelBtn.layer.borderColor = [STLThemeColor col_EEEEEE].CGColor;
        [_cancelBtn setContentEdgeInsets:UIEdgeInsetsMake(8, 12, 8, 12)];
        _cancelBtn.layer.borderWidth = 1;
        [_cancelBtn addTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.sensor_element_id = @"cancel_order_button";

    }
    return _cancelBtn;
}

- (UIButton *)payNowBtn {
    if (!_payNowBtn) {
        _payNowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _payNowBtn.tag = OrderPayNow;
        _payNowBtn.hidden = YES;
        _payNowBtn.backgroundColor = [STLThemeColor col_0D0D0D];
        [_payNowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _payNowBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_payNowBtn setTitle:STLLocalizedString_(@"payNow", nil).uppercaseString forState:UIControlStateNormal];
        [_payNowBtn setContentEdgeInsets:UIEdgeInsetsMake(8, 12, 8, 12)];
        _payNowBtn.layer.borderWidth = 1;
        _payNowBtn.layer.borderColor = [STLThemeColor col_0D0D0D].CGColor;
        [_payNowBtn addTarget:self action:@selector(clickPayNow:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _payNowBtn;
}

- (UIButton *)buyAgainBtn {
    if (!_buyAgainBtn) {
        _buyAgainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _buyAgainBtn.hidden = YES;
        _buyAgainBtn.backgroundColor = [UIColor clearColor];
        _buyAgainBtn.layer.borderColor = [STLThemeColor col_EEEEEE].CGColor;
        [_buyAgainBtn setTitleColor:[STLThemeColor col_0D0D0D] forState:UIControlStateNormal];
        _buyAgainBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_buyAgainBtn setTitle:[STLLocalizedString_(@"Repurchase",nil) uppercaseString] forState:UIControlStateNormal];
        [_buyAgainBtn setContentEdgeInsets:UIEdgeInsetsMake(8, 12, 8, 12)];
        _buyAgainBtn.layer.borderWidth = 1;
        _buyAgainBtn.sensor_element_id = @"repurchase_complete_button";
        [_buyAgainBtn addTarget:self action:@selector(clickBuyAgain:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buyAgainBtn;
}

- (UIButton *)reviewBtn {
    if (!_reviewBtn) {
        _reviewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _reviewBtn.hidden = YES;
        _reviewBtn.backgroundColor = [UIColor clearColor];
        _reviewBtn.layer.borderColor = [STLThemeColor col_EEEEEE].CGColor;
        [_reviewBtn setTitleColor:[STLThemeColor col_0D0D0D] forState:UIControlStateNormal];
        _reviewBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_reviewBtn setTitle:[STLLocalizedString_(@"reviews",nil) uppercaseString] forState:UIControlStateNormal];
        [_reviewBtn setContentEdgeInsets:UIEdgeInsetsMake(8, 12, 8, 12)];
        _reviewBtn.layer.borderWidth = 1;
        [_reviewBtn addTarget:self action:@selector(clickReview:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reviewBtn;
}
#pragma mark -----UIButton Action
- (void)clickCancel:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(clickCancel:)]) {
        [_delegate clickCancel:sender];
    }
}
- (void)clickPayNow:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(clickPayNow:)]) {
        [_delegate clickPayNow:sender];
    }

}

- (void)clickBuyAgain:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(clickBuyAgain:)]) {
        [_delegate clickBuyAgain:sender];
    }

}
- (void)clickReview:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(clickReview:)]) {
        [_delegate clickReview:sender];
    }

}
- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    
        [self.payNowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-8);
            make.height.mas_equalTo(@28);
        }];
    
        [self.reviewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.payNowBtn.mas_leading).offset(-8);
            make.width.mas_equalTo(@80);
            make.height.mas_equalTo(@28);
        }];
    
        [self.buyAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.reviewBtn.mas_leading).offset(-8);
            make.height.mas_equalTo(@28);
        }];
    
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.buyAgainBtn.mas_leading).offset(-8);
            make.height.mas_equalTo(@28);
    
        }];
}

@end
