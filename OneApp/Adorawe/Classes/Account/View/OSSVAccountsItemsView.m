//
//  OSSVAccountsItemsView.m
// XStarlinkProject
//
//  Created by odd on 2020/8/3.
//  Copyright © 2020 starlink. All rights reserved.
//  订单状态（Unpaid, processing, Shipped ）

#import "OSSVAccountsItemsView.h"
#import "UIView+STLBadge.h"

@implementation OSSVAccountsItemsView

- (instancetype)initWithFrame:(CGRect)frame image:(NSString *)image title:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
                
        [self addSubview:self.imageView];
        [self addSubview:self.numberLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.numberRedDotView];
        [self addSubview:self.imageRedDotView];
        [self addSubview:self.badgeBgView];
        [self.badgeBgView addSubview:self.badgeLabel];

        self.titleLabel.text = STLToString(title);
        self.imageView.image = [UIImage imageNamed:image];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
            make.height.mas_equalTo(18);
        }];
        
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.bottom.mas_equalTo(self.titleLabel.mas_top);
        }];
        
        [self.badgeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.imageView.mas_trailing).offset(8);
            make.bottom.mas_equalTo(self.imageView.mas_top).offset(8);
            make.height.mas_equalTo(16);
            make.width.mas_greaterThanOrEqualTo(16);
        }];
        
        [self.badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.badgeBgView.mas_trailing).offset(-5);
            make.leading.mas_equalTo(self.badgeBgView.mas_leading).offset(5);
            make.centerY.mas_equalTo(self.badgeBgView.mas_centerY);
            make.height.mas_equalTo(16);
        }];
        
        [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_lessThanOrEqualTo(self.mas_width);
            make.centerY.mas_equalTo(self.imageView.mas_centerY);
            make.centerX.mas_equalTo(self.imageView.mas_centerX);
        }];
    
        [self.numberRedDotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_top);
            make.width.height.mas_equalTo(8);
            make.leading.equalTo(self.numberLabel.mas_trailing);
        }];
        
        [self.imageRedDotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_top);
            make.leading.equalTo(self.imageView.mas_trailing).offset(-2);
            make.width.height.mas_equalTo(8);
        }];
        
  }
    return self;
}

- (void)image:(NSString *)image title:(NSString *)title {
    self.titleLabel.text = STLToString(title);
    self.imageView.image = [UIImage imageNamed:image];
}

- (void)confirmCounts:(NSString *)counts titleNumber:(NSInteger)count showRed:(BOOL )showRed{
    if (STLIsEmptyString(counts)) {
        counts = @"";
    }
    if ([counts integerValue] > 99) {
        counts = @"99+";
    }
    self.badgeBgView.hidden = STLIsEmptyString(counts) ? YES : NO;
    self.badgeLabel.text = counts;
    
    if (count >= 0) {
        if (count > 99) {
            count = 99;
            self.numberLabel.text = [NSString stringWithFormat:@"%li+",count];
        } else {
            self.numberLabel.text = [NSString stringWithFormat:@"%li",count];
        }
        self.numberLabel.hidden = NO;
        self.imageView.hidden = YES;
    } else {
        self.numberLabel.hidden = YES;
        self.imageView.hidden = NO;
    }
    
    if (showRed) {
        self.badgeBgView.hidden = YES;
        self.numberRedDotView.hidden = count > 0 ? NO : YES;
        self.imageRedDotView.hidden = count > 0 ? YES : NO;

    } else {
        self.numberRedDotView.hidden = YES;
        self.imageRedDotView.hidden = YES;
    }
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
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = [UIFont systemFontOfSize:18];
        _numberLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _numberLabel.hidden = YES;
    }
    return _numberLabel;
}

- (UIView *)numberRedDotView {
    if (!_numberRedDotView) {
        _numberRedDotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        _numberRedDotView.tag = 999;
        _numberRedDotView.backgroundColor = [OSSVThemesColors col_B62B21];
        _numberRedDotView.layer.cornerRadius = 4;
        _numberRedDotView.clipsToBounds = YES;
        _numberRedDotView.layer.borderColor = [OSSVThemesColors stlWhiteColor].CGColor;
        _numberRedDotView.layer.borderWidth = 1.0;
        _numberRedDotView.hidden = YES;
    }
    return  _numberRedDotView;
}

- (UIView *)imageRedDotView {
    if (!_imageRedDotView) {
        _imageRedDotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        _imageRedDotView.tag = 999;
        _imageRedDotView.backgroundColor = [OSSVThemesColors col_B62B21];
        _imageRedDotView.layer.cornerRadius = 4;
        _imageRedDotView.clipsToBounds = YES;
        _imageRedDotView.layer.borderColor = [OSSVThemesColors stlWhiteColor].CGColor;
        _imageRedDotView.layer.borderWidth = 1.0;
        _imageRedDotView.hidden = YES;
    }
    return  _imageRedDotView;
}

- (UIView *)badgeBgView {
    if (!_badgeBgView) {
        _badgeBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _badgeBgView.layer.cornerRadius = 8;
        _badgeBgView.layer.borderColor = [OSSVThemesColors stlWhiteColor].CGColor;
        _badgeBgView.layer.borderWidth = 1;
        _badgeBgView.layer.masksToBounds = YES;
        _badgeBgView.backgroundColor = [OSSVThemesColors col_B62B21];
        _badgeBgView.hidden = YES;
    }
    return _badgeBgView;
}

- (UILabel *)badgeLabel {
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _badgeLabel.backgroundColor = [OSSVThemesColors stlClearColor];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _badgeLabel.font = [UIFont systemFontOfSize:9];
        
    }
    return _badgeLabel;
}


@end
