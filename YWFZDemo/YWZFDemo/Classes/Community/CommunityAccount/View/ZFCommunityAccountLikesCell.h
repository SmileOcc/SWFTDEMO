//
//  ZFCommunityAccountLikesCell.h
//  ZZZZZ
//
//  Created by YW on 2017/8/2.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFCommunityAccountLikesModel;

typedef void(^CommunityAccountLikesTopicCompletionHandler)(NSString *topic);

typedef void(^CommunityAccountLikeFollowUserCompletionHandler)(ZFCommunityAccountLikesModel *model);

typedef void(^CommunityAccountLikesLikeCompletionHandler)(ZFCommunityAccountLikesModel *model);

typedef void(^CommunityAccountLikesUserAccountCompletionHandler)(NSString *userId);

typedef void(^CommunityAccountLikesShareCompletionHandler)(ZFCommunityAccountLikesModel *model);

typedef void(^CommunityAccountLikesReviewCompletionHandler)(void);

@interface ZFCommunityAccountLikesCell : UITableViewCell
@property (nonatomic, strong) ZFCommunityAccountLikesModel      *model;

@property (nonatomic, copy) CommunityAccountLikesTopicCompletionHandler         communityAccountLikesTopicCompletionHandler;

@property (nonatomic, copy) CommunityAccountLikeFollowUserCompletionHandler     communityAccountLikeFollowUserCompletionHandler;

@property (nonatomic, copy) CommunityAccountLikesLikeCompletionHandler          communityAccountLikesLikeCompletionHandler;

@property (nonatomic, copy) CommunityAccountLikesUserAccountCompletionHandler   communityAccountLikesUserAccountCompletionHandler;

@property (nonatomic, copy) CommunityAccountLikesShareCompletionHandler         communityAccountLikesShareCompletionHandler;

@property (nonatomic, copy) CommunityAccountLikesReviewCompletionHandler        communityAccountLikesReviewCompletionHandler;
@end
