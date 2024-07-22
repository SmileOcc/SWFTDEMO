//
//  ZFNewUserTitleView.m
//  ZZZZZ
//
//  Created by mac on 2019/1/14.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import "ZFNewUserTitleView.h"
#import "Masonry.h"
#import "ZFColorDefiner.h"

@interface ZFNewUserTitleView ()

/** 分隔线 */
@property (nonatomic, strong) UIView *lineView;

@end

@implementation ZFNewUserTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(24);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(24);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = ColorHex_Alpha(0xEEEEEE, 1.0);
    }
    return _lineView;
}

@end
