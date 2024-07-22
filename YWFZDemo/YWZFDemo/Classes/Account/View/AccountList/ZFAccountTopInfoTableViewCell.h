//
//  ZFAccountTopInfoTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/4/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFAccountTopInfoOptionType) {
    ZFAccountTopInfoOptionTypeOrder = 0,
    ZFAccountTopInfoOptionTypeWishlist,
    ZFAccountTopInfoOptionTypeCoupon,
    ZFAccountTopInfoOptionTypePoints,
};

typedef void(^ZFAccountTopInfoOptionCompletionHandler)(ZFAccountTopInfoOptionType type);

@interface ZFAccountTopInfoTableViewCell : UITableViewCell

@property (nonatomic, copy) ZFAccountTopInfoOptionCompletionHandler     accountTopInfoOptionCompletionHandler;

- (void)updateIconBadgeShowInfo;

@end
