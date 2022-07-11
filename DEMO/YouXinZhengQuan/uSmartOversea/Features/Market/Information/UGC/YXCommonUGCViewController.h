//
//  YXCommonUGCViewController.h
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXUGCContentView: UIScrollView
@end

@class YXUGCPublisherView;
@interface YXCommonUGCViewController : YXViewController

@property (nonatomic, strong, readonly) YXUGCContentView *contentView;
@property (nonatomic, strong, readonly) YXUGCPublisherView *navBarPublisherView;

@property (nonatomic, strong, nullable) NSNumber *pullNext;


- (__kindof UIScrollView  * _Nullable)scrollView;
- (CGFloat)bottomHeight;
- (CGFloat)topHeight;
- (BOOL)alwaysShowNavBarPublisher;

@end

NS_ASSUME_NONNULL_END
