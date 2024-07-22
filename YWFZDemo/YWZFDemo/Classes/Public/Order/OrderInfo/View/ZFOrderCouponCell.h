//
//  ZFOrderCouponCell.h
//  ZZZZZ
//
//  Created by YW on 20/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFOrderCouponCell : UITableViewCell

@property (nonatomic,copy) NSString *couponAmount;
@property (nonatomic, assign) BOOL                  isCod;

- (void)initCouponAmount:(NSString *)couponAmount;
+ (NSString *)queryReuseIdentifier;

@end
