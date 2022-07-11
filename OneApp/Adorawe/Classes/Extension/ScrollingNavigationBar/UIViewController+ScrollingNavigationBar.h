//
//  UIViewController+ScrollingNavigationBar.h
//  GearBest
//
//  Created by zhaowei on 16/4/26.
//  Copyright © 2016年 gearbest. All rights reserved.
//

@interface UIViewController(ScrollingNavigationBar)<UIGestureRecognizerDelegate>
- (void)followScrollView:(UIView*)scrollableView;
- (void)followScrollView:(UIView*)scrollableView withDelay:(float)delay;

- (void)showNavbar;
- (void)showNavBarAnimated:(BOOL)animated;

- (void)stopFollowingScrollView;
- (void)setScrollingEnabled:(BOOL)enabled;

- (void)setShouldScrollWhenContentFits:(BOOL)enabled;
@end
