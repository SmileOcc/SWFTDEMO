//
//  ZFAccountTopInfoTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/4/28.
//  Copyright © 2018年 YW. All rights reserved.
//

/*
 * 备注：ZFAccountTopInfoIconView 为封装的 信息显示视图
 * 目前有4个类型的ZFAccountTopInfoIconView。
 * 分别为 订单列表，收藏夹， 优惠券， 以及积分入口。
 * 部分ZFAccountTopInfoIconView上 有数量显示badgeView.
 */

#import "ZFAccountTopInfoTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFAccountTopInfoIconView.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "AccountManager.h"
#import "Constants.h"

@interface ZFAccountTopInfoTableViewCell() <ZFInitViewProtocol>

@property (nonatomic, strong) ZFAccountTopInfoIconView          *orderInfoView;
@property (nonatomic, strong) ZFAccountTopInfoIconView          *wishlistView;
@property (nonatomic, strong) ZFAccountTopInfoIconView          *couponView;
@property (nonatomic, strong) ZFAccountTopInfoIconView          *pointsView;
@end

@implementation ZFAccountTopInfoTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - private methods
/*
 * 更新ICON 数量显示BadgeView
 */
- (void)updateIconBadgeShowInfo {
    self.orderInfoView.badgeText = [AccountManager sharedManager].account.not_paying_order;
    self.couponView.badgeText = [AccountManager sharedManager].account.has_new_coupon;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.orderInfoView];
    [self.contentView addSubview:self.wishlistView];
    [self.contentView addSubview:self.couponView];
    [self.contentView addSubview:self.pointsView];
}

- (void)zfAutoLayoutView {
    [self.orderInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.mas_equalTo(self.contentView);
        make.width.mas_equalTo(KScreenWidth / 4.0);
    }];
    
    [self.wishlistView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.orderInfoView.mas_trailing);
        make.width.mas_equalTo(KScreenWidth / 4.0);
    }];
    
    [self.couponView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.wishlistView.mas_trailing);
        make.width.mas_equalTo(KScreenWidth / 4.0);
    }];
    
    [self.pointsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.bottom.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.couponView.mas_trailing);
        make.width.mas_equalTo(KScreenWidth / 4.0);
    }];
}

#pragma mark - setter


#pragma mark - getter
- (ZFAccountTopInfoIconView *)orderInfoView {
    if (!_orderInfoView) {
        _orderInfoView = [[ZFAccountTopInfoIconView alloc] initWithFrame:CGRectZero];
        _orderInfoView.type = ZFAccountTopInfoIconViewTypeOrder;
        @weakify(self);
        [_orderInfoView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.accountTopInfoOptionCompletionHandler) {
                self.accountTopInfoOptionCompletionHandler(ZFAccountTopInfoOptionTypeOrder);
            }
        }];
    }
    return _orderInfoView;
}

- (ZFAccountTopInfoIconView *)wishlistView {
    if (!_wishlistView) {
        _wishlistView = [[ZFAccountTopInfoIconView alloc] initWithFrame:CGRectZero];
        _wishlistView.type = ZFAccountTopInfoIconViewTypeWishlist;
        @weakify(self);
        [_wishlistView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.accountTopInfoOptionCompletionHandler) {
                self.accountTopInfoOptionCompletionHandler(ZFAccountTopInfoOptionTypeWishlist);
            }
        }];
    }
    return _wishlistView;
}

- (ZFAccountTopInfoIconView *)couponView {
    if (!_couponView) {
        _couponView = [[ZFAccountTopInfoIconView alloc] initWithFrame:CGRectZero];
        _couponView.type = ZFAccountTopInfoIconViewTypeCoupon;
        @weakify(self);
        [_couponView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.accountTopInfoOptionCompletionHandler) {
                self.accountTopInfoOptionCompletionHandler(ZFAccountTopInfoOptionTypeCoupon);
            }
        }];
    }
    return _couponView;
}

- (ZFAccountTopInfoIconView *)pointsView {
    if (!_pointsView) {
        _pointsView = [[ZFAccountTopInfoIconView alloc] initWithFrame:CGRectZero];
        _pointsView.type = ZFAccountTopInfoIconViewTypeZPoint;
        @weakify(self);
        [_pointsView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.accountTopInfoOptionCompletionHandler) {
                self.accountTopInfoOptionCompletionHandler(ZFAccountTopInfoOptionTypePoints);
            }
        }];
    }
    return _pointsView;
}

@end
