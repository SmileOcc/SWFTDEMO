//
//  ZFSelectSizeColorHeader.m
//  ZZZZZ
//
//  Created by YW on 2017/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSelectSizeColorHeader.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFSelectSizeColorHeader() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *titleLabel;
@end

@implementation ZFSelectSizeColorHeader
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)updateTopSpace:(CGFloat)space {
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(space > 0 ? space : 16);
    }];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
//    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.titleLabel];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(16);
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.trailing.mas_equalTo(self);
    }];
}

#pragma mark - setter
- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = _title;
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = ColorHex_Alpha(0x999999, 1.0);
        _titleLabel.font = ZFFontSystemSize(14);
        
    }
    return _titleLabel;
}

@end
