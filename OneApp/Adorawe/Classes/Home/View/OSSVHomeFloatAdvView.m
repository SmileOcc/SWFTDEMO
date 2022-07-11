//
//  STLHomeFloatBannerView.m
// XStarlinkProject
//
//  Created by odd on 2021/3/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVHomeFloatAdvView.h"

@implementation OSSVHomeFloatAdvView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.floatBannerImageView];
        [self addSubview:self.floatCloseButton];
        
        [self.floatBannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(60, 60));
        }];
        
        [self.floatCloseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.trailing.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
    }
    return self;
}

- (void)floatBannerImageViewAction {
    if (self.floatEventBlock) {
        self.floatEventBlock(self.advModel);
    }
}

- (void)actionClose:(UIButton *)sender {
    self.hidden = YES;
    if (self.floatCloseBlock) {
        self.floatCloseBlock();
    }
}

- (YYAnimatedImageView *)floatBannerImageView {
    if (!_floatBannerImageView) {
        _floatBannerImageView = [[YYAnimatedImageView alloc] init];
        _floatBannerImageView.backgroundColor = [UIColor clearColor];
        _floatBannerImageView.contentMode = UIViewContentModeScaleAspectFit;
        _floatBannerImageView.clipsToBounds = YES;
       
        
        _floatBannerImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(floatBannerImageViewAction)];
        [_floatBannerImageView addGestureRecognizer:tapGesture];
    }
    return _floatBannerImageView;
}

- (UIButton *)floatCloseButton {
    if (!_floatCloseButton) {
        _floatCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_floatCloseButton setImage:[UIImage imageNamed:@"float_icon_close"] forState:UIControlStateNormal];
        [_floatCloseButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _floatCloseButton;
}

@end
