//
//  ZFOrderPaymentCell.m
//  ZZZZZ
//
//  Created by YW on 17/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderCurrentPaymentCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"

@interface ZFOrderCurrentPaymentCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) YYAnimatedImageView   *icon;
@property (nonatomic, strong) UILabel               *paymentLabel;
@end

@implementation ZFOrderCurrentPaymentCell
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
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.contentView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.paymentLabel];
}

- (void)zfAutoLayoutView {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(12);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.paymentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.icon.mas_trailing).offset(12);
        make.centerY.mas_equalTo(self.contentView);
    }];
}

#pragma mark - Setter
- (void)setCurrentPayment:(NSString *)currentPayment {
    _currentPayment = currentPayment;
    self.paymentLabel.text = currentPayment;
}

#pragma mark - Getter
- (YYAnimatedImageView *)icon {
    if (!_icon) {
        _icon = [YYAnimatedImageView new];
        _icon.image = [UIImage imageNamed:@"payment"];
    }
    return _icon;
}

- (UILabel *)paymentLabel {
    if (!_paymentLabel) {
        _paymentLabel = [[UILabel alloc] init];
        _paymentLabel.font = [UIFont boldSystemFontOfSize:16];
        _paymentLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _paymentLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _paymentLabel;
}
@end
