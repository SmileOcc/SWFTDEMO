//
//  ZFFullLiveCouponListCell.h
//  ZZZZZ
//
//  Created by YW on 2019/12/23.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsDetailCouponModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveCouponListCell : UITableViewCell

@property (nonatomic, strong) ZFGoodsDetailCouponModel *couponModel;


@property (nonatomic, copy) void (^receiveCouponBlock)(ZFGoodsDetailCouponModel *couponModel);


@end

NS_ASSUME_NONNULL_END
