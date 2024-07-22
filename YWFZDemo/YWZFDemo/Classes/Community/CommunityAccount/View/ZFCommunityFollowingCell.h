//
//  ZFCommunityFollowingCell.h
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFCommunityFollowModel;

typedef void(^CommunityFollowUserCompletionHandler)(ZFCommunityFollowModel *model);

@interface ZFCommunityFollowingCell : UITableViewCell
@property (nonatomic, strong) ZFCommunityFollowModel        *model;
@property (nonatomic, copy) CommunityFollowUserCompletionHandler        communityFollowUserCompletionHandler;
@end
