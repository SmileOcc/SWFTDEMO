//
//  ZFMyCouponTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2017/12/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCouponBaseTableViewCell.h"

typedef NS_ENUM(NSInteger, CouponType) {
    CouponAvailable,
    CouponDisabled
};

@class ZFMyCouponModel;
@interface ZFMyCouponTableViewCell : ZFCouponBaseTableViewCell

@property (nonatomic, assign) CouponType couponType;
@property (nonatomic, copy) void(^tagBtnActionHandle)(void);

- (void)configWithModel:(ZFMyCouponModel *)model;
+ (ZFMyCouponTableViewCell *)couponItemCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
