//
//  YWLoginTypeConfirmView.m
//  ZZZZZ
//
//  Created by Tsang_Fa on 2018/6/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "YWLoginTypeConfirmView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIButton+ZFButtonCategorySet.h"

@interface YWLoginTypeConfirmView ()<ZFInitViewProtocol>
@property (nonatomic, strong) UIButton  *confirmButton;
@end

@implementation YWLoginTypeConfirmView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.backgroundColor = ZFCOLOR_WHITE;
    }
    return self;
}

- (void)zfInitView {
    [self addSubview:self.confirmButton];
}

- (void)zfAutoLayoutView {
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.top.mas_equalTo(36);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self);
    }];
}

#pragma mark - Action
- (void)doneHandler {
    if (self.confirmCellHandler) {
        self.confirmCellHandler();
    }
}

#pragma mark - Setter
- (void)setModel:(YWLoginModel *)model {
    _model = model;
    
    NSString *title = model.type == YWLoginEnterTypeLogin ? ZFLocalizedString(@"SignIn_Button",nil) : ZFLocalizedString(@"REGISTER",nil);
    [self.confirmButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - Getter
- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.layer.cornerRadius = 3;
        _confirmButton.layer.masksToBounds = YES;
        [_confirmButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        [_confirmButton setTitle:ZFLocalizedString(@"REGISTER",nil) forState:UIControlStateNormal];
        [_confirmButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = ZFFontBoldSize(16);
        [_confirmButton addTarget:self action:@selector(doneHandler) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

@end
