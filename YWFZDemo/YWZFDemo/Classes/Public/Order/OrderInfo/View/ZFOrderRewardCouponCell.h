//
//  ZFOrderRewardCouponCell.h
//  ZZZZZ
//
//  Created by 602600 on 2019/10/31.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFOrderRewardCouponCell : UITableViewCell

+ (NSString *)queryReuseIdentifier;

@property (nonatomic, copy) NSString *rewardCouponTip;

@end

NS_ASSUME_NONNULL_END
