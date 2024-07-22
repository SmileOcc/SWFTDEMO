//
//  ZFSearchPopularHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2017/12/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchPopularHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFSearchPopularHeaderView() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *titleLabel;
@end

@implementation ZFSearchPopularHeaderView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.titleLabel];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.trailing.centerY.mas_equalTo(self);
    }];
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ColorHex_Alpha(0x2d2d2d, 1);
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.text = ZFLocalizedString(@"SearchHotSearchText", nil);
    }
    return _titleLabel;
}

@end
