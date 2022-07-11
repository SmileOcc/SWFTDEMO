//
//  OSSVCartNoDataView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartNoDataView.h"


@interface OSSVCartNoDataView()

@property (nonatomic, strong) YYAnimatedImageView      *imageView;
@property (nonatomic, strong) UILabel                  *titleLabel;
@property (nonatomic, strong) UIButton                 *button;

@property (nonatomic, copy) CartNoDataBlock            noDataBlock;
@end


@implementation OSSVCartNoDataView

- (instancetype)initWithFrame:(CGRect)frame completion:(CartNoDataBlock)noDataBlock {
    
    if (self = [super initWithFrame:frame]) {
        
        self.noDataBlock = noDataBlock;
        self.backgroundColor = [UIColor whiteColor];

        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.button];
        
        
        // 此处本来是直接通过上部图片距离距离的高度  height = 100 或 10 直接修改，但为了适配设计图，做以下丑陋改变
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            if (IPHONE_4X_3_5) {
                make.size.mas_equalTo(CGSizeMake(120, 80));
                make.top.mas_equalTo(self.mas_top).offset(35);
            } else {
                make.top.mas_equalTo(self.mas_top).offset(46);
            }
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            if (IPHONE_4X_3_5) {
                make.top.mas_equalTo(self.mas_top).offset(130);
            } else {
                make.top.mas_equalTo(self.mas_top).offset(196);
            }
        }];
        
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.width.mas_equalTo(@180);
            make.height.mas_equalTo(@40);
            if (IPHONE_4X_3_5) {
                make.top.mas_equalTo(self.mas_top).offset(170);
            } else {
                make.top.mas_equalTo(self.mas_top).offset(246);
            }
        }];
    }
    return self;
}

#pragma mark - LazyLoad

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [YYAnimatedImageView new];
        _imageView.image = [UIImage imageNamed:@"cart_bank"];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = OSSVThemesColors.col_333333;
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.text = STLLocalizedString_(@"cart_blank", nil);
    }
    return _titleLabel;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button addTarget:self action:@selector(emptyJumpOperationTouch) forControlEvents:UIControlEventTouchUpInside];
        _button.backgroundColor = OSSVThemesColors.col_FF9522;
        _button.titleLabel.font = [UIFont systemFontOfSize:14];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button setTitle:STLLocalizedString_(@"cart_blank_button_title", nil) forState:UIControlStateNormal];
        _button.layer.cornerRadius = 3;
    }
    return _button;
}

- (void)emptyJumpOperationTouch {
    if (self.noDataBlock) {
        self.noDataBlock();
    }
}
@end
