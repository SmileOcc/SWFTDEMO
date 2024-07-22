//
//  ZFAccountTopInfoIconView.m
//  ZZZZZ
//
//  Created by YW on 2018/5/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAccountTopInfoIconView.h"
#import "ZFInitViewProtocol.h"
#import "UIView+ZFBadge.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"

@interface ZFAccountTopInfoIconView() <ZFInitViewProtocol>

@property (nonatomic, strong) UIImageView           *iconImageView;
@property (nonatomic, strong) UILabel               *tipsLabel;
@property (nonatomic, strong) UIButton              *enterButton;
@end

@implementation ZFAccountTopInfoIconView
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
    
    [self addSubview:self.enterButton];
    [self addSubview:self.tipsLabel];
}

- (void)zfAutoLayoutView {
    
    [self.enterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top).offset(16);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.enterButton.mas_bottom).offset(8);
        make.leading.trailing.centerX.mas_equalTo(self);
    }];
}

#pragma mark - setter
- (void)setType:(ZFAccountTopInfoIconViewType)type {
    _type = type;
    NSArray *titles = @[ZFLocalizedString(@"Account_Cell_Orders", nil),
                        ZFLocalizedString(@"Account_Cell_Wishlist", nil),
                        ZFLocalizedString(@"Account_Cell_Coupon", nil),
                        ZFLocalizedString(@"Account_Cell_Points", nil)];
    NSArray *iconImageNames = @[@"account_home_order",
                                @"account_home_wishlist_new",
                                @"account_home_coupon_new",
                                @"account_home_z-points"];
    
    self.tipsLabel.text = titles[_type];
    [self.enterButton setImage:[UIImage imageNamed:iconImageNames[_type]] forState:UIControlStateNormal];
}

- (void)setBadgeText:(NSString *)badgeText {
    _badgeText = badgeText; //修改线上类型错误崩溃
    [self.enterButton showShoppingCarsBageValue:[ZFToString(badgeText) integerValue]
                                    bageBgColor:ZFCOLOR_WHITE
                                  bageTextColor:ZFC0xFE5269()
                                bageBorderWidth:.5f
                                bageBorderColor:ZFC0xFE5269()];
//    [self.enterButton showShoppingCarsBageValue:[_badgeText integerValue]];
}

#pragma mark - getter
- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.font = [UIFont systemFontOfSize:12];
        _tipsLabel.textColor = ZFC0x999999();
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipsLabel;
}

- (UIButton *)enterButton {
    if (!_enterButton) {
        _enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _enterButton.userInteractionEnabled = NO;
        [_enterButton setTitleColor:ZFCOLOR(153, 153, 153, 1.f) forState:UIControlStateNormal];
        _enterButton.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _enterButton;
}

@end
