//
//  STLCouponAlertView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/19.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCouponsAlertView.h"

@interface OSSVCouponsAlertView ()

@property (nonatomic, strong) UIView          *contentbgView;
@property (nonatomic, strong) UIImageView     *imgView;
@property (nonatomic, strong) UILabel         *titleLabel;
@property (nonatomic, strong) UILabel         *messagLabel;
@property (nonatomic, strong) UIButton        *confirmButton;
@end


@implementation OSSVCouponsAlertView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.backgroundColor = [OSSVThemesColors col_000000:0.7];
        
        self.contentbgView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.contentbgView];
        [self.contentbgView addSubview:self.imgView];
        [self.contentbgView addSubview:self.titleLabel];
        [self.contentbgView addSubview:self.messagLabel];
        [self.contentbgView addSubview:self.confirmButton];
        
        [self.contentbgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self).mas_offset(48);
            make.trailing.mas_equalTo(self).mas_offset(-48);
            make.center.mas_equalTo(self);
        }];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentbgView.mas_top).mas_offset(23);
            make.centerX.mas_equalTo(self.contentbgView);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentbgView.mas_centerX);
            make.top.mas_equalTo(self.imgView.mas_bottom).mas_offset(15);
        }];
        
        [self.messagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentbgView.mas_leading).mas_offset(24);
            make.trailing.mas_equalTo(self.contentbgView.mas_trailing).mas_offset(-24);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(10);
        }];
        
        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.messagLabel.mas_bottom).mas_offset(22);
            make.bottom.mas_equalTo(self.contentbgView.mas_bottom).mas_offset(-20);
            make.centerX.mas_equalTo(self.contentbgView);
        }];
        
    }
    return self;
}

- (void)showView:(UIView *)superView msg:(NSString *)msg{
    if (superView) {
        [self removeFromSuperview];
        [superView addSubview:self];
        self.hidden = NO;
        self.messagLabel.text = STLToString(msg);
    } else {
        if (self.superview) {
            [self removeFromSuperview];
        }
        self.hidden = YES;
    }
}

- (void)actionConfirm {
    [self showView:nil msg:nil];
    
    if (self.operateBlock) {
        self.operateBlock();
    }
}
#pragma mark -

- (UIView *)contentbgView {
    if (!_contentbgView) {
        _contentbgView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentbgView.layer.cornerRadius = 2;
    }
    return _contentbgView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imgView.image = [UIImage imageNamed:@"activity_gift"];
    }
    return _imgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textColor = OSSVThemesColors.col_F67160;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = [NSString stringWithFormat:@"%@...",STLLocalizedString_(@"Sorry", nil)];
    }
    return _titleLabel;
}
- (UILabel *)messagLabel {
    if (!_messagLabel) {
        _messagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messagLabel.textAlignment = NSTextAlignmentCenter;
        _messagLabel.numberOfLines = 2;
        _messagLabel.font = [UIFont systemFontOfSize:14];
        _messagLabel.textColor = OSSVThemesColors.col_666666;
        _messagLabel.text = @"";
    }
    return _messagLabel;
}
- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setBackgroundImage:[UIImage imageNamed:@"confirm_boot"] forState:UIControlStateNormal];
        if (APP_TYPE == 3) {
            [_confirmButton setTitle:STLLocalizedString_(@"confirm", nil) forState:UIControlStateNormal];
        } else {
            [_confirmButton setTitle:STLLocalizedString_(@"confirm", nil).uppercaseString forState:UIControlStateNormal];
        }
        [_confirmButton setTitleColor:OSSVThemesColors.col_FFFFFF forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(actionConfirm) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_confirmButton setContentEdgeInsets:UIEdgeInsetsMake(6, 10, 6, 10)];
    }
    return _confirmButton;
}
@end
