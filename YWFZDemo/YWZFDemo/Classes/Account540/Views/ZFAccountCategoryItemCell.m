//
//  ZFAccountCategoryItemCell.m
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountCategoryItemCell.h"
#import "ZFAccountCategorySectionModel.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"
#import "UIButton+ZFButtonCategorySet.h"
#import <Masonry/Masonry.h>
#import "AccountManager.h"
#import "Constants.h"
#import "ZFAccountHeaderCellTypeModel.h"
#import "SystemConfigUtils.h"
#import "ZFThemeFontManager.h"

@interface ZFAccountCategoryItemView : UIControl

@property (nonatomic, strong) UILabel *countsLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView  *redView;

@end

@implementation ZFAccountCategoryItemView

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.countsLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.redView];
        self.titleLabel.text = ZFToString(title);
        
        CGFloat kWidth = (KScreenWidth - 24) / 4.0;

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
            make.height.mas_equalTo(18);
        }];
        
        [self.countsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.bottom.mas_equalTo(self.titleLabel.mas_top);
            make.width.mas_lessThanOrEqualTo(kWidth - 5);
        }];
        
        [self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.countsLabel.mas_trailing).offset(-4);
            make.top.mas_equalTo(self.countsLabel.mas_top).offset(4);
            make.size.mas_equalTo(CGSizeMake(8, 8));
        }];
    }
    return self;
}

- (void)confirmCounts:(NSString *)counts showRed:(BOOL )showRed{
    if (ZFIsEmptyString(counts)) {
        counts = @"0";
    }

    if ([counts integerValue] > 999) {
        if ([SystemConfigUtils isRightToLeftShow]) {
            counts = @"+999";

        } else {
            counts = @"999+";
        }
    }
    self.countsLabel.text = counts;
    self.redView.hidden = !showRed;
}


- (UILabel *)countsLabel {
    if (!_countsLabel) {
        _countsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countsLabel.textColor = ZFC0x333333();
        //_countsLabel.font = ZFNumberFontSize(24);//[UIFont systemFontOfSize:30];
        _countsLabel.font = ZFFontBoldNumbers(24);
        
        _countsLabel.textAlignment = NSTextAlignmentCenter;
        _countsLabel.text = @"0";
    }
    return _countsLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFC0x666666();
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)redView {
    if (!_redView) {
        _redView = [[UIView alloc] initWithFrame:CGRectZero];
        _redView.layer.cornerRadius = 4;
        _redView.layer.masksToBounds = YES;
        _redView.backgroundColor = ZFC0xFE5269();
        _redView.hidden = YES;
    }
    return _redView;
}

@end

@interface ZFAccountCategoryItemCell ()

@property (nonatomic, strong) UIView *mainView;

@property (nonatomic, strong) ZFAccountCategoryItemView *orderButton;
@property (nonatomic, strong) ZFAccountCategoryItemView *wishListButton;
@property (nonatomic, strong) ZFAccountCategoryItemView *couponButton;
@property (nonatomic, strong) ZFAccountCategoryItemView *zPointButton;
@end

@implementation ZFAccountCategoryItemCell

@synthesize cellTypeModel = _cellTypeModel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        //刷新 [未使用订单, 未使用优惠券] 数量
        [self refreshItemDataInfo];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    self.backgroundColor = ZFCClearColor();

    [self.contentView addSubview:self.mainView];
    [self.mainView addSubview:self.orderButton];
    [self.mainView addSubview:self.wishListButton];
    [self.mainView addSubview:self.couponButton];
    [self.mainView addSubview:self.zPointButton];
}

- (void)zfAutoLayoutView {
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.top.bottom.mas_equalTo(self.contentView);
    }];
    
    CGFloat kWidth = (KScreenWidth - 24) / 4.0;
    [self.orderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.mas_equalTo(self.mainView);
        make.width.mas_equalTo(kWidth);
    }];
    
    [self.wishListButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.mainView);
        make.leading.mas_equalTo(self.orderButton.mas_trailing);
        make.width.mas_equalTo(kWidth);
    }];
    
    [self.couponButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.mainView);
        make.leading.mas_equalTo(self.wishListButton.mas_trailing);
        make.width.mas_equalTo(kWidth);
    }];
    
    [self.zPointButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.mas_equalTo(self.mainView);
        make.width.mas_equalTo(kWidth);
    }];
}

#pragma mark - <ButtonAction>

- (void)setCellTypeModel:(ZFAccountHeaderCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;
    
    //刷新 [未使用订单, 未使用优惠券] 数量
    [self refreshItemDataInfo];
}

- (void)refreshItemDataInfo {
    NSString *orderBadge = [AccountManager sharedManager].account.order_number;
    NSString *couponBadge = [AccountManager sharedManager].account.coupon_number;
    NSString *collectBadge = [AccountManager sharedManager].account.collect_number;
    NSString *pointBadge = [AccountManager sharedManager].account.avaid_point;

    BOOL orderShow = [[AccountManager sharedManager].account.not_paying_order boolValue];
    BOOL couponShow = [[AccountManager sharedManager].account.has_new_coupon boolValue];

    [self.orderButton confirmCounts:orderBadge showRed:orderShow];
    [self.wishListButton confirmCounts:collectBadge showRed:NO];
    [self.couponButton confirmCounts:couponBadge showRed:couponShow];
    [self.zPointButton confirmCounts:pointBadge showRed:NO];
}

- (void)setButtonBadgeNum:(UIButton *)button badgeNum:(NSInteger)badgeNum {
    [button showShoppingCarsBageValue:badgeNum
                          bageBgColor:ZFCOLOR_WHITE
                        bageTextColor:ZFC0xFE5269()
                      bageBorderWidth:.5f
                      bageBorderColor:ZFC0xFE5269()];
}

- (void)categoryItemBtnAction:(UIButton *)button {
    if (self.cellTypeModel.accountCellActionBlock) {
        self.cellTypeModel.accountCellActionBlock(button.tag, nil);
    }
}

#pragma mark - <get lazy Load>

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectZero];
        _mainView.backgroundColor = ZFCClearColor();
    }
    return _mainView;
}

- (ZFAccountCategoryItemView *)orderButton {
    if (!_orderButton) {
        _orderButton = [[ZFAccountCategoryItemView alloc] initWithFrame:CGRectZero withTitle:ZFLocalizedString(@"Account_Cell_Orders", nil)];
        [_orderButton addTarget:self action:@selector(categoryItemBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _orderButton.tag = ZFAccountCategoryCell_OrderType;
    }
    return _orderButton;
}

- (ZFAccountCategoryItemView *)wishListButton {
    if (!_wishListButton) {
        _wishListButton = [[ZFAccountCategoryItemView alloc] initWithFrame:CGRectZero withTitle:ZFLocalizedString(@"Account_Cell_Wishlist", nil)];
        [_wishListButton addTarget:self action:@selector(categoryItemBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _wishListButton.tag = ZFAccountCategoryCell_WishListType;
    }
    return _wishListButton;
}

- (ZFAccountCategoryItemView *)couponButton {
    if (!_couponButton) {
        _couponButton = [[ZFAccountCategoryItemView alloc] initWithFrame:CGRectZero withTitle:ZFLocalizedString(@"Account_Cell_Coupon", nil)];
        [_couponButton addTarget:self action:@selector(categoryItemBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _couponButton.tag = ZFAccountCategoryCell_CouponType;
    }
    return _couponButton;
}

- (ZFAccountCategoryItemView *)zPointButton {
    if (!_zPointButton) {
        _zPointButton = [[ZFAccountCategoryItemView alloc] initWithFrame:CGRectZero withTitle:ZFLocalizedString(@"Account_Cell_Points", nil)];
        [_zPointButton addTarget:self action:@selector(categoryItemBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _zPointButton.tag = ZFAccountCategoryCell_ZPointType;
    }
    return _zPointButton;
}

@end
