//
//  ZFCommunityLiveVideoVC.h
//  ZZZZZ
//
//  Created by YW on 2019/4/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFCommunityLiveListModel.h"
#import "ZFCommunityFullLiveVideoVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveVideoVC : ZFBaseViewController

@property (nonatomic, strong) ZFCommunityLiveListModel *videoModel;
@property (nonatomic, copy) NSString                   *liveID;

@property (nonatomic, copy) void (^playStatusBlock)(ZFCommunityLiveListModel *videoModel);
@property (nonatomic, copy) void (^playNeedStatisticsBlock)(ZFCommunityLiveListModel *videoModel);

@property (nonatomic, assign) BOOL isZego;

@end

NS_ASSUME_NONNULL_END
