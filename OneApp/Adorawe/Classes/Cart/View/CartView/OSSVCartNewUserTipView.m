//
//  OSSVCartNewUserTipView.m
// XStarlinkProject
//
//  Created by odd on 2020/9/14.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCartNewUserTipView.h"

@implementation OSSVCartNewUserTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
//        [self addSubview:self.bgImageView];
        [self addSubview:self.bgView];
        [self addSubview:self.tipLabel];
        
//        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(self);
//        }];

        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];


        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(8);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-8);
            make.centerY.equalTo(self.bgView.mas_centerY);
        }];
    }
    return self;
}

//- (UIImageView *)bgImageView {
//    if (!_bgImageView) {
//        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        _bgImageView.image = [UIImage imageNamed:@"cart_new_users_tip"];
//        _bgImageView.contentMode = UIViewContentModeScaleToFill;
//    }
//    return _bgImageView;
//}


- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        if (APP_TYPE == 3) {
            _bgView.backgroundColor = OSSVThemesColors.stlWhiteColor;
            _bgView.layer.borderColor = OSSVThemesColors.col_9F5123.CGColor;
            _bgView.layer.borderWidth = 1.f;
            _bgView.layer.masksToBounds = YES;
        } else {
            _bgView.backgroundColor = OSSVThemesColors.col_FBE9E9;
        }
        _bgView.contentMode = UIViewContentModeScaleToFill;
    }
    return _bgView;
}


- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.font = [UIFont systemFontOfSize:10];
    }
    return _tipLabel;
}

@end
