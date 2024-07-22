//
//  CouponItemCell.h
//  ZZZZZ
//
//  Created by YW on 2017/6/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCouponBaseTableViewCell.h"

typedef NS_ENUM(NSInteger, CouponType) {
    CouponUnused = 1,
    CouponUsed,
    CouponExpired
};

@class CouponItemModel;

@interface CouponItemCell : ZFCouponBaseTableViewCell
@property (nonatomic, strong) NSNumber *currentTime;
@property (nonatomic, strong) CouponItemModel *couponModel;
@property (nonatomic, copy) void(^userItActionHandle)(void);
@property (nonatomic, copy) void(^tagBtnActionHandle)(void);
@property (nonatomic, assign) CouponType couponType;

+ (CouponItemCell *)couponItemCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@end
