//
//  ZFCartUnavailableHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCartUnavailableHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "Masonry.h"
#import "ZFFrameDefiner.h"
#import "UIView+ZFViewCategorySet.h"

@interface ZFCartUnavailableHeaderView () <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView           *iconImageView;
@property (nonatomic, strong) UILabel               *unavailabelLabel;
@property (nonatomic, strong) UIButton              *clearAllButton;
@property (nonatomic, strong) UIView                *emptyView;

@end

@implementation ZFCartUnavailableHeaderView
#pragma mark - init methods
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    [self addTopLeftRightCorners];
//}
//
//- (void)addTopLeftRightCorners {
//    [self.emptyView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];
//}

#pragma mark - action methods
- (void)clearAllButtonAction:(UIButton *)sender {
    if (self.cartUnavailableGoodsClearAllCompletionHandler) {
        self.cartUnavailableGoodsClearAllCompletionHandler();
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFC0xF2F2F2();
    [self.contentView addSubview:self.emptyView];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.unavailabelLabel];
    [self.contentView addSubview:self.clearAllButton];
}

- (void)zfAutoLayoutView {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(4);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    
    [self.unavailabelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView.mas_centerY);
        make.leading.mas_equalTo(self.iconImageView.mas_trailing).offset(4);
        make.trailing.mas_equalTo(self.clearAllButton.mas_leading).offset(-10);
    }];
    
    [self.clearAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.clearAllButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.clearAllButton setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - getter

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"car_unavailableIcon"]];
    }
    return _iconImageView;
}

- (UILabel *)unavailabelLabel {
    if (!_unavailabelLabel) {
        _unavailabelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _unavailabelLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _unavailabelLabel.font = [UIFont systemFontOfSize:14];
        _unavailabelLabel.text = ZFLocalizedString(@"CartUnavailableProductTips", nil);
    }
    return _unavailabelLabel;
}

- (UIButton *)clearAllButton {
    if (!_clearAllButton) {
        _clearAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearAllButton setTitleColor:ZFCOLOR(153, 153, 153, 1.f) forState:UIControlStateNormal];
        [_clearAllButton setTitle:ZFLocalizedString(@"CartClearAllButtonTips", nil) forState:UIControlStateNormal];
        _clearAllButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_clearAllButton addTarget:self action:@selector(clearAllButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearAllButton;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectZero];
        _emptyView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _emptyView;
}
@end
