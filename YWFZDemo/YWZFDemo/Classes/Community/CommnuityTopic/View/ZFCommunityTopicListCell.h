//
//  ZFCommunityTopicListCell.h
//  ZZZZZ
//
//  Created by YW on 2017/8/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFCommunityPostListModel;

typedef void(^CommunityTopicListTopicCompletionHandler)(NSString *topic);

typedef void(^CommunityTopicListFollowCompletionHandler)(ZFCommunityPostListModel *model);

typedef void(^CommunityTopicListLikeCompletionHandler)(ZFCommunityPostListModel *model);

typedef void(^CommunityTopicListShareCompletionHandler)(ZFCommunityPostListModel *model);

typedef void(^CommunityTopicListAccountCompletionHandler)(ZFCommunityPostListModel *model);

typedef void(^CommunityTopicListReviewCompletionHandler)(void);

@interface ZFCommunityTopicListCell : UITableViewCell
@property (nonatomic, strong) ZFCommunityPostListModel     *model;

@property (nonatomic, copy) CommunityTopicListTopicCompletionHandler        communityTopicListTopicCompletionHandler;

@property (nonatomic, copy) CommunityTopicListFollowCompletionHandler       communityTopicListFollowCompletionHandler;

@property (nonatomic, copy) CommunityTopicListLikeCompletionHandler         communityTopicListLikeCompletionHandler;

@property (nonatomic, copy) CommunityTopicListShareCompletionHandler        communityTopicListShareCompletionHandler;

@property (nonatomic, copy) CommunityTopicListAccountCompletionHandler      communityTopicListAccountCompletionHandler;

@property (nonatomic, copy) CommunityTopicListReviewCompletionHandler       communityTopicListReviewCompletionHandler;
@end
