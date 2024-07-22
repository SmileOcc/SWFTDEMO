//
//  ZFTabBarController.h
//  Dezzal
//
//  Created by 7FD75 on 16/7/21.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFNavigationController.h"

typedef NS_ENUM(NSInteger, TabBarIndex) {
    TabBarIndexHome,
    TabBarIndexCommunity,
    TabBarIndexAccount,
};

@interface ZFTabBarController : UITabBarController

- (ZFNavigationController *)navigationControllerWithMoudle:(NSInteger)moudle;

- (void)setZFTabBarIndex:(NSInteger)index;

- (void)isShowNewCouponDot;

@end
