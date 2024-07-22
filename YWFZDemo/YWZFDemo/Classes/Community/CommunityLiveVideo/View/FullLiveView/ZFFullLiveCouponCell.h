//
//  ZFFullLiveCouponCell.h
//  ZZZZZ
//
//  Created by YW on 2019/12/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "NSStringUtils.h"
#import "NSString+Extended.h"
#import "Masonry.h"
#import "Configuration.h"

#import "ZFGoodsDetailCouponModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveCouponCell : UITableViewCell


@property (nonatomic, copy) void (^selectBlock)(void);

@property (nonatomic, strong) ZFGoodsDetailCouponModel *couponModel;

///背景视图
@property (nonatomic, strong) UIView        *contentBackView;
///背景图片
@property (nonatomic, strong) UIImageView   *contentImageView;
///优惠金额或者优惠折扣label
@property (nonatomic, strong) UILabel       *codeLabel;
///时间label
@property (nonatomic, strong) UILabel       *dateLabel;
///优惠明细label
@property (nonatomic, strong) UILabel       *expiresLabel;

///优惠券失效视图
@property (nonatomic, strong) UIImageView   *invalidCouponIcon;
///优惠券失效文字
@property (nonatomic, strong) UILabel       *invalidText;

@property (nonatomic, strong) UIButton      *receiveButton;

@property (nonatomic, assign) BOOL          isCanReceive;


- (void)configurate:(ZFGoodsDetailCouponModel *)couponModel canReceive:(BOOL)canReceive;

@end

NS_ASSUME_NONNULL_END
