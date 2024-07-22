//
//  ZFCommunitySearchSuggestUsersListCell.h
//  ZZZZZ
//
//  Created by YW on 2017/7/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFCommunitySuggestedUsersModel;

typedef void(^FollowUserCompletionHandler)(ZFCommunitySuggestedUsersModel *model);

@interface ZFCommunitySearchSuggestUsersListCell : UITableViewCell

@property (nonatomic, strong) ZFCommunitySuggestedUsersModel    *model;

@property (nonatomic, copy) FollowUserCompletionHandler     followUserCompletionHandler;

@end

