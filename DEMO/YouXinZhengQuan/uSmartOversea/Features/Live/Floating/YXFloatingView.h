//
//  YXFloatingView.h
//  uSmartOversea
//
//  Created by Apple on 2020/10/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMDragView.h"
@class YXLiveDetailModel;

@import TXLiteAVSDK_Professional;

NS_ASSUME_NONNULL_BEGIN

@interface YXFloatingView : WMDragView

@property (nonatomic, strong) TXLivePlayer *txLivePlayer;

@property (nonatomic, copy) NSString *liveId;

@property (nonatomic, weak, nullable) UIViewController *sourceViewController;

// 用来锁屏显示
@property (nonatomic, strong) YXLiveDetailModel *liveModel;

+ (YXFloatingView *)sharedView;

- (void)startPlay:(NSString *)showUrl isPortrait:(BOOL)isPortrait;

- (void)hideFloating;

@end

NS_ASSUME_NONNULL_END
