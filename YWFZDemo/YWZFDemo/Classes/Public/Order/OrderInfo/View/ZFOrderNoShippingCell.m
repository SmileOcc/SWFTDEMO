//
//  ZFOrderNoShippingCell.m
//  ZZZZZ
//
//  Created by YW on 19/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderNoShippingCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "UIView+ZFViewCategorySet.h"

@interface ZFOrderNoShippingCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) YYAnimatedImageView   *warnIcon;
@property (nonatomic, strong) UILabel               *tipLabel;
@property (nonatomic, strong) UIView                *separatorLine;
@end

@implementation ZFOrderNoShippingCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - Public method
+ (NSString *)queryReuseIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    self.contentView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.warnIcon];
    [self.contentView addSubview:self.tipLabel];
    [self.contentView addSubview:self.separatorLine];
}

- (void)zfAutoLayoutView {
    [self.warnIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 18));
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.warnIcon.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.contentView.mas_top).offset(20);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-20);
    }];
    
    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
           make.bottom.trailing.mas_equalTo(0);
           make.leading.mas_equalTo(12);
           make.height.mas_equalTo(0.5);
       }];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self zfAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 8)];
}

#pragma mark - Getter
- (YYAnimatedImageView *)warnIcon {
    if (!_warnIcon) {
        _warnIcon = [YYAnimatedImageView new];
        _warnIcon.image = [UIImage imageNamed:@"warn"];
    }
    return _warnIcon;
}

-(UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.numberOfLines = 0;
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        _tipLabel.text = ZFLocalizedString(@"CartOrderInfoViewModel_PlaceOrder_NoShipping",nil);
    }
    return _tipLabel;
}

- (UIView *)separatorLine {
    if (!_separatorLine) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    }
    return _separatorLine;
}

@end
