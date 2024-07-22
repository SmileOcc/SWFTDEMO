//
//  ZFSearchHistroyHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2017/12/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchHistroyHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "NSUserDefaults+SafeAccess.h"
#import "Masonry.h"
#import "ZFPubilcKeyDefiner.h"

@interface ZFSearchHistroyHeaderView() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *titleLabel;
@property (nonatomic, strong) UIButton          *clearIconButton;
@property (nonatomic, strong) UIButton          *clearButton;
@end

@implementation ZFSearchHistroyHeaderView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)clearButtonAction:(UIButton *)sender {
    if (self.searchHistoryClearCompletionHandler) {
        NSMutableDictionary *historyInfo = (NSMutableDictionary *)[[[NSUserDefaults standardUserDefaults] valueForKey:kSearchHistoryKey] mutableCopy];
        [historyInfo removeAllObjects];
        [NSUserDefaults setZFObject:historyInfo forKey:kSearchHistoryKey];
        self.searchHistoryClearCompletionHandler();
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.titleLabel];
    [self addSubview:self.clearIconButton];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.centerY.mas_equalTo(self);
        make.trailing.mas_equalTo(self.clearIconButton.mas_leading);
    }];

    
    [self.clearIconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
    }];
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ColorHex_Alpha(0x2d2d2d, 1);
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.text = ZFLocalizedString(@"SearchSearchHistoryText", nil);
    }
    return _titleLabel;
}

- (UIButton *)clearIconButton {
    if (!_clearIconButton) {
        _clearIconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearIconButton setImage:[UIImage imageNamed:@"rubbish-min"] forState:UIControlStateNormal];
        [_clearIconButton addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearIconButton;
}

@end
