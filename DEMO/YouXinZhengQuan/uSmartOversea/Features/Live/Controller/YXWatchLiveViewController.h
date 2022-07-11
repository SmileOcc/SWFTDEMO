//
//  YXWatchLiveViewController.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class YXLivePlayView;
@interface YXWatchLiveViewController : YXViewController

@property (nonatomic, strong) YXLivePlayView *playView;

- (void)showFloatingView;

@end

NS_ASSUME_NONNULL_END
