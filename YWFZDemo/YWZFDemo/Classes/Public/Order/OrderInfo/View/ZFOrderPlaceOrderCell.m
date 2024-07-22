//
//  ZFOrderPlaceOrderCell.m
//  ZZZZZ
//
//  Created by YW on 22/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderPlaceOrderCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFOrderPlaceOrderCell()<ZFInitViewProtocol>
@property (nonatomic, strong) UIButton              *placeOrderButton;
@end

@implementation ZFOrderPlaceOrderCell
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

- (void)placeOrderButtonCanTouch:(BOOL)state {
    if (state) {
        self.placeOrderButton.backgroundColor = ZFCOLOR(153, 153, 153, 1);
    }else{
        self.placeOrderButton.backgroundColor = ZFCOLOR(51, 51, 51, 1.0);
    }
}

#pragma mark - Setter
- (void)setIsFastPay:(BOOL)isFastPay {
    _isFastPay = isFastPay;
    NSString *title = isFastPay ? ZFLocalizedString(@"MyOrders_Cell_PayNow",nil) : ZFLocalizedString(@"CartOrderInformationBottomView_PlaceOrderBtn",nil);
    [self.placeOrderButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    self.contentView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.placeOrderButton];
}

- (void)zfAutoLayoutView {
    [self.placeOrderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).with.insets(UIEdgeInsetsZero);
        make.height.mas_equalTo(46);
    }];
}

#pragma mark - Getter
- (UIButton *)placeOrderButton {
    if (!_placeOrderButton) {
        _placeOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_placeOrderButton setTitle:ZFLocalizedString(@"CartOrderInformationBottomView_PlaceOrderBtn",nil) forState:UIControlStateNormal];
        [_placeOrderButton setTitleColor:ZFCOLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
        _placeOrderButton.backgroundColor = ZFCOLOR(51, 51, 51, 1.0);
        _placeOrderButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        _placeOrderButton.userInteractionEnabled = NO;
    }
    return _placeOrderButton;
}
@end
