//
//  YWLoginTypeModeView.m
//  ZZZZZ
//
//  Created by YW on 26/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "YWLoginTypeModeView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface YWLoginTypeModeView ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel   *modeLabel;
@property (nonatomic, strong) UILabel   *adLabel;
@end

@implementation YWLoginTypeModeView
#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    [self addSubview:self.modeLabel];
    [self addSubview:self.adLabel];
}

- (void)zfAutoLayoutView {
    [self.modeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(17);
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
    }];
    
    [self.adLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.modeLabel.mas_bottom).offset(8);
        make.leading.equalTo(self.modeLabel.mas_leading);
        make.trailing.equalTo(self.self.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(-2);
    }];
}

#pragma mark - Setter
- (void)setModel:(YWLoginModel *)model {
    _model = model;
    
    NSString *adTitle = model.type == YWLoginEnterTypeRegister ? model.register_ad : model.login_ad;
    self.adLabel.text = adTitle;
    
    NSString *title = model.type == YWLoginEnterTypeLogin ? ZFLocalizedString(@"login_title",nil) : ZFLocalizedString(@"Register_Button",nil);
    self.modeLabel.text = title;
    
    [self.adLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(ZFIsEmptyString(adTitle) ? 0 : -2);
    }];
}

#pragma mark - Getter
- (UILabel *)modeLabel {
    if (!_modeLabel) {
        _modeLabel = [[UILabel alloc] init];
        _modeLabel.font = [UIFont boldSystemFontOfSize:28];
        _modeLabel.textColor = ZFCOLOR(0, 0, 0, 1);
    }
    return _modeLabel;
}

- (UILabel *)adLabel {
    if (!_adLabel) {
        _adLabel = [[UILabel alloc] init];
        _adLabel.font = ZFFontSystemSize(14);
        _adLabel.numberOfLines = 0;
        _adLabel.preferredMaxLayoutWidth = KScreenWidth - 32;
        _adLabel.textColor = ZFC0x06B190();
    }
    return _adLabel;
}

@end
