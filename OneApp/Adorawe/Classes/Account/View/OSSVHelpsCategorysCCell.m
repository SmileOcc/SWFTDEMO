//
//  OSSVHelpsCategorysCCell.m
// XStarlinkProject
//
//  Created by odd on 2021/1/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVHelpsCategorysCCell.h"

@implementation OSSVHelpsCategorysCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.backgroundColor = [OSSVThemesColors stlClearColor];
        [self.contentView addSubview:tempView];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.tipLabel];
        [self.contentView addSubview:self.bottomLineView];
        [self.contentView addSubview:self.rightLineView];
        
        [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.mas_centerY);
                    make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(tempView.mas_top);
            make.centerX.mas_equalTo(tempView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(48, 48));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.imageView.mas_bottom).offset(4);
            make.bottom.mas_equalTo(tempView.mas_bottom);
            make.leading.mas_equalTo(self.mas_leading).offset(4);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-4);
        }];
        
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
            make.leading.mas_equalTo(self.mas_leading).offset(4);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-4);
        }];
        
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.height.mas_equalTo(0.5 * kScale_375);
        }];
        
        [self.rightLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing);
            make.width.mas_equalTo(0.5 * kScale_375);
            make.top.bottom.mas_equalTo(self);
        }];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.textColor = OSSVThemesColors.col_B62B21;
        _tipLabel.font = [UIFont systemFontOfSize:9];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _bottomLineView;
}

- (UIView *)rightLineView {
    if (!_rightLineView) {
        _rightLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _rightLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _rightLineView;
}
@end
