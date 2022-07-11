//
//  YXPageView.h
//  ScrollViewDemo
//
//  Created by ellison on 2018/10/8.
//  Copyright © 2018 ellison. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXPageView : UIView

@property (nonatomic, weak) UIViewController *parentViewController;
@property (nonatomic, copy) NSArray<__kindof UIViewController *> *viewControllers;

@property (nonatomic, strong, readonly) UIScrollView *contentView;

@property (nonatomic, assign) BOOL needLayout;

@property (nonatomic, assign) BOOL useCache;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
