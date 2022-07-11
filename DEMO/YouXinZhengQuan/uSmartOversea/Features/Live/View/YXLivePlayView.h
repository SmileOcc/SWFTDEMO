//
//  YXLivePlayView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@import TXLiteAVSDK_Professional;
@class YXLiveDetailModel;
NS_ASSUME_NONNULL_BEGIN


@interface YXLiveWatchEndView: UIView
@property (nonatomic, strong) UILabel *countLabel;

@end


@interface YXLivePlayView : UIView

// 视频的方向
@property (nonatomic, assign) BOOL isPortrait;

@property (nonatomic, strong) NSString *showUrl;

@property (nonatomic, strong, nullable) TXLivePlayer *txLivePlayer;

// 是否全屏
@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, copy) void (^scaleCallBack)(BOOL isFullScreen);

@property (nonatomic, strong) UILabel *watchCountLabel;

@property (nonatomic, strong) NSString *countStr;

- (void)closeFullScreen;

// 用来锁屏显示
@property (nonatomic, strong) YXLiveDetailModel *liveModel;
@property (nonatomic, assign) BOOL isPlaying; //横屏返回到竖屏时用

@end

NS_ASSUME_NONNULL_END
