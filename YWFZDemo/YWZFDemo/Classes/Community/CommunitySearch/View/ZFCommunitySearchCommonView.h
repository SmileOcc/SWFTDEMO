//
//  ZFCommunitySearchCommonView.h
//  ZZZZZ
//
//  Created by YW on 2017/7/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CommunitySuggestedUserInfoCompletionHandler)(NSString *userId);

typedef void(^CommunityInviteFacebookCompletionHandler)(void);

typedef void(^CommunityInviteContactsCompletionHandler)(void);
@interface ZFCommunitySearchCommonView : UIView

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, assign, getter=isNoResultTips) BOOL          noResultTips;

@property (nonatomic, copy) CommunitySuggestedUserInfoCompletionHandler         communitySuggestedUserInfoCompletionHandler;

@property (nonatomic, copy) CommunityInviteFacebookCompletionHandler    communityInviteFacebookCompletionHandler;

@property (nonatomic, copy) CommunityInviteContactsCompletionHandler    communityInviteContactsCompletionHandler;
@end

