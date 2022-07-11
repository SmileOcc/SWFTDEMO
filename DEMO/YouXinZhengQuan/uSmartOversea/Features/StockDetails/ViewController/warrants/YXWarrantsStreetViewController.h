//
//  YXWarrantsStreetViewController.h
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/11/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXTableViewController.h"
#import "YXWarrantsStreetHeaderView.h"

NS_ASSUME_NONNULL_BEGIN

@class YXWarrantsMainViewController;
@interface YXWarrantsStreetViewController : YXTableViewController

@property (nonatomic, strong) YXWarrantsStreetHeaderView *headerView;

@property (nonatomic, weak) YXWarrantsMainViewController *mainViewController;

- (void)updateHeaderView;

@end

NS_ASSUME_NONNULL_END
