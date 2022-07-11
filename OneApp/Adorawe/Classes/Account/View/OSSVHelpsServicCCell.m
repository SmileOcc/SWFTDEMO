//
//  OSSVHelpsServicCCell.m
// XStarlinkProject
//
//  Created by odd on 2021/8/9.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVHelpsServicCCell.h"

@implementation OSSVHelpsServicCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.bgView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bgView.layer.cornerRadius = 6.0;
        
        self.backgroundColor = [OSSVThemesColors stlClearColor];
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleView];
        [self.titleView addSubview:self.titleLabel];
        [self.titleView addSubview:self.tipLabel];
        [self.contentView addSubview:self.button];

        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.bgView.mas_centerY);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bgView.mas_leading);
            make.trailing.mas_equalTo(self.imageView.mas_leading);
            make.centerY.mas_equalTo(self.bgView.mas_centerY);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleView.mas_top);
            make.leading.mas_equalTo(self.titleView.mas_leading).offset(14);
            make.trailing.mas_equalTo(self.titleView.mas_trailing).offset(-4);
        }];
        
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(0);
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.trailing.mas_equalTo(self.titleView.mas_trailing).offset(-4);
            make.bottom.mas_equalTo(self.titleView.mas_bottom);
        }];
        
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        
    }
    return self;
}

- (void)actionTap {
    if (self.tapBlock) {
        self.tapBlock(self.model);
    }
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button addTarget:self action:@selector(actionTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}


- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectZero];
        _titleView.backgroundColor = [OSSVThemesColors stlClearColor];
    }
    return _titleView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _titleLabel;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _tipLabel.font = [UIFont systemFontOfSize:10];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _tipLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _tipLabel;
}

@end
