//
//  OSSVCheckOutOneProductCell.m
// XStarlinkProject
//
//  Created by fan wang on 2021/8/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCheckOutOneProductCell.h"


@implementation OSSVCheckOutOneProductCell

- (instancetype)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
        UIView *ws = self.contentView;
        [ws addSubview:self.iconView];
        [ws addSubview:self.titleLabel];
        [ws addSubview:self.propertyLabel];
        
        [ws addSubview:self.priceLabel];
        [ws addSubview:self.countLabel];
        
        [ws bringSubviewToFront:self.iconView];
        
        [ws addSubview:self.markView];
        [self.markView addSubview:self.stateLabel];
        
        [ws mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(ws.mas_leading);
            make.width.mas_offset(72);
            if (APP_TYPE == 3) {
                make.height.mas_offset(72);
            } else {
                make.height.mas_offset(96);
            }
            make.bottom.equalTo(0);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconView.mas_top).offset(2);
            make.leading.mas_equalTo(self.iconView.mas_trailing).offset(8);
            make.trailing.mas_equalTo(ws.mas_trailing);
        }];
        
        [self.propertyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
            make.leading.mas_equalTo(self.iconView.mas_trailing).offset(8);
            make.trailing.mas_equalTo(ws.mas_trailing);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.iconView.mas_bottom);
            make.leading.mas_equalTo(self.propertyLabel.mas_leading);
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-2);
            make.bottom.mas_equalTo(self.priceLabel.mas_bottom);
        }];
        
        
        [self.markView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.iconView);
        }];
        
        UIImageView *stateImage = [[UIImageView alloc] init];
        stateImage.image = [UIImage imageNamed:@"goods_hanger"];
        [self.markView addSubview:stateImage];
        self.stateImageView = stateImage;
        [stateImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(27);
            make.centerX.mas_equalTo(self.markView.mas_centerX);
            make.width.height.equalTo(24);
        }];
        
        [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(stateImage.mas_bottom).offset(8);
            make.leading.mas_equalTo(self.markView.mas_leading).offset(4);
            make.trailing.mas_equalTo(self.markView.mas_trailing).offset(-4);
        }];
        

//        self
    }
    return self;
}

#pragma mark - setter and getter

- (YYAnimatedImageView *)iconView {
    if (!_iconView) {
        _iconView = [[YYAnimatedImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.clipsToBounds = YES;
        if (APP_TYPE != 3) {
            _iconView.layer.masksToBounds = true;
            _iconView.layer.borderWidth = 0.5*kScale_375;
            _iconView.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        }
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = OSSVThemesColors.col_6C6C6C;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
            _titleLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        }
    }
    return _titleLabel;
}

- (UILabel *)propertyLabel {
    if (!_propertyLabel) {
        _propertyLabel = [[UILabel alloc] init];
        _propertyLabel.font = [UIFont boldSystemFontOfSize:12];
        _propertyLabel.textColor = OSSVThemesColors.col_6C6C6C;
        _propertyLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _propertyLabel.textAlignment = NSTextAlignmentRight;
            _propertyLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        }
    }
    return _propertyLabel;
}


- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _priceLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _priceLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = [UIFont systemFontOfSize:14];
        _countLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _countLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _countLabel;
}

- (UIView *)markView {
    if (!_markView) {
        _markView = [[UIView alloc] initWithFrame:CGRectZero];
        _markView.backgroundColor = [OSSVThemesColors col_0D0D0D:0.6];
        _markView.hidden = YES;
    }
    return _markView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stateLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _stateLabel.font = [UIFont systemFontOfSize:11];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.text = STLLocalizedString_(@"Goods_Unavailable", nil);
        _stateLabel.numberOfLines = 0;

    }
    return _stateLabel;
}



@end
