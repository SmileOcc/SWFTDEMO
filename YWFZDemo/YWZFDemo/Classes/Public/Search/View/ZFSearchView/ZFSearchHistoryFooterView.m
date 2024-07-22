//
//  ZFSearchHistoryFooterView.m
//  ZZZZZ
//
//  Created by YW on 2019/8/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFSearchHistoryFooterView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "NSUserDefaults+SafeAccess.h"
#import "Masonry.h"
#import "ZFPubilcKeyDefiner.h"
#import "UIButton+ZFButtonCategorySet.h"

@interface ZFSearchHistoryFooterView () <ZFInitViewProtocol>

@property (nonatomic, strong) UIButton          *moreButton;

@end

@implementation ZFSearchHistoryFooterView

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
    [self addSubview:self.moreButton];
}

- (void)zfAutoLayoutView {
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(25);
    }];
}

#pragma mark - action methods
- (void)moreButtonAction:(UIButton *)sender {
    if (self.searchHistoryMoreCompletionHandler) {
        self.searchHistoryMoreCompletionHandler();
    }
}

#pragma mark - getter

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_moreButton setImage:[UIImage imageNamed:@"search_more"] forState:UIControlStateNormal];
        [_moreButton setTitleColor:ZFCOLOR(153, 153, 153, 1.0) forState:UIControlStateNormal];
        [_moreButton setTitle:ZFLocalizedString(@"Search_Tool_Morel", nil) forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_moreButton zfLayoutStyle:ZFButtonEdgeInsetsStyleRight imageTitleSpace:2];
    }
    return _moreButton;
}

@end
