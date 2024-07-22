//
//  ZFCommunityMessageListCell.h
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFCommunityMessageModel;

typedef void(^CommunityMessageListFollowUserCompletionHandler)(ZFCommunityMessageModel *model);

typedef void(^CommunityMessageAccountDetailCompletioinHandler)(ZFCommunityMessageModel *model);

@interface ZFCommunityMessageListCell : UITableViewCell

@property (nonatomic, strong) ZFCommunityMessageModel       *model;

@property (nonatomic, copy) CommunityMessageListFollowUserCompletionHandler communityMessageListFollowUserCompletionHandler;

@property (nonatomic, copy) CommunityMessageAccountDetailCompletioinHandler communityMessageAccountDetailCompletioinHandler;

- (void)showReadMark:(BOOL)show;
@end
