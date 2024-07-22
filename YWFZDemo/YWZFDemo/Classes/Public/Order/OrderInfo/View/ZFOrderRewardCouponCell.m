//
//  ZFOrderRewardCouponCell.m
//  ZZZZZ
//
//  Created by 602600 on 2019/10/31.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderRewardCouponCell.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "YSAlertView.h"
#import "ZFColorDefiner.h"
#import "Masonry.h"
#import "SystemConfigUtils.h"
#import "UILabel+HTML.h"
#import "UIView+ZFViewCategorySet.h"

@interface ZFOrderRewardCouponCell ()

@property (nonatomic, strong) UILabel   *rewardTipLabel;

@property (nonatomic, strong) UIButton  *helptButton;

@end

@implementation ZFOrderRewardCouponCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.rewardTipLabel.text = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

+ (NSString *)queryReuseIdentifier
{
    return NSStringFromClass(self.class);
}

- (void)setRewardCouponTip:(NSString *)rewardCouponTip {
    _rewardCouponTip = rewardCouponTip;
    [self.rewardTipLabel zf_setHTMLFromString:rewardCouponTip];
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    self.contentView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.rewardTipLabel];
    [self.contentView addSubview:self.helptButton];
}

- (void)zfAutoLayoutView {
    [self.helptButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(6);
        make.bottom.mas_equalTo(self.contentView).offset(-6);
        make.size.mas_equalTo(CGSizeMake(18, 18));
        make.trailing.mas_equalTo(self.contentView).offset(-12);
    }];
    
    [self.rewardTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.helptButton);
        make.trailing.mas_equalTo(self.helptButton.mas_leading).offset(-5);
    }];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self zfAddCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(8, 8)];
}

#pragma mark - Action
- (void)showInfo {
    NSString *help = ZFLocalizedString(@"rewardCouponTip", nil);
    ShowAlertSingleBtnView(nil, help, ZFLocalizedString(@"OK",nil));
}

#pragma mark - Getter

- (UILabel *)rewardTipLabel {
    if (!_rewardTipLabel) {
        _rewardTipLabel = [[UILabel alloc] init];
        _rewardTipLabel.font = [UIFont systemFontOfSize:11];
        _rewardTipLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _rewardTipLabel.textAlignment = NSTextAlignmentRight;
    }
    return _rewardTipLabel;
}

- (UIButton *)helptButton {
    if (!_helptButton) {
        _helptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_helptButton setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateNormal];
        [_helptButton setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateSelected];
        _helptButton.userInteractionEnabled = YES;
        [_helptButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
        [_helptButton setEnlargeEdge:10];
    }
    return _helptButton;
}


@end
