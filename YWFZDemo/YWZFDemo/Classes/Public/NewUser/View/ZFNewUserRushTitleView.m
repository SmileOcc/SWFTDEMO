//
//  ZFNewUserRushTitleView.m
//  ZZZZZ
//
//  Created by mac on 2019/1/15.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import "ZFNewUserRushTitleView.h"
#import "Masonry.h"
#import "ZFColorDefiner.h"
#import "ZFThemeManager.h"

@interface ZFNewUserRushTitleView ()

/** 分隔线 */
@property (nonatomic, strong) UIView *lineView;

@end

@implementation ZFNewUserRushTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = ZFCOLOR_WHITE;
        [self addSubview:self.lineView];
        [self addSubview:self.titleLabel];
        self.backgroundColor = ZFC0xFFFFFF();
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(10);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom).offset(15);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(20);
    }];
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = ColorHex_Alpha(0xEEEEEE, 1.0);
    }
    return _lineView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    return _titleLabel;
}

@end
