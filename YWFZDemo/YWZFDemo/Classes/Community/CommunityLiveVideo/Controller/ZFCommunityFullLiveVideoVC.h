//
//  ZFCommunityFullLiveVideoVC.h
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFCommunityLiveListModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 全屏直播
@interface ZFCommunityFullLiveVideoVC : ZFBaseViewController

@property (nonatomic, strong) UIImage *coverImage;

@property (nonatomic, strong) ZFCommunityLiveListModel *videoModel;
@property (nonatomic, copy) NSString                   *liveID;

@property (nonatomic, copy) void (^playStatusBlock)(ZFCommunityLiveListModel *videoModel);
@property (nonatomic, copy) void (^playNeedStatisticsBlock)(ZFCommunityLiveListModel *videoModel);

@property (nonatomic, assign) BOOL isZego;

- (void)clearPlay;

@end

NS_ASSUME_NONNULL_END
