//
//  OSSVCouponCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCouponCellModel.h"
#import "OSSVTableViewCellProtocol.h"

#pragma mark - STLCouponTableViewCell

@protocol OSSVCouponCellDelegate <TableViewCellDelegate>

-(void)STL_CouponCellDidClickApply:(OSSVCouponCellModel *)model;

@end

@interface OSSVCouponCell : UITableViewCell
<
OSSVTableViewCellProtocol
>

@property (nonatomic, weak) id<OSSVCouponCellDelegate>delegate;

@end

#pragma mark - coupon save cell

@interface STLCouponSaveCell : UITableViewCell
<
OSSVTableViewCellProtocol
>
@end
