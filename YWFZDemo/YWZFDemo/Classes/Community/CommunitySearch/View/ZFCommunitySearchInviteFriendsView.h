//
//  ZFCommunitySearchInviteFriendsView.h
//  ZZZZZ
//
//  Created by YW on 2017/7/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^InviteContactCompletionHandler)(void);
typedef void(^InviteFacebookCompletionHandler)(void);

@interface ZFCommunitySearchInviteFriendsView : UIView

@property (nonatomic, copy) InviteContactCompletionHandler      inviteContactCompletionHandler;
@property (nonatomic, copy) InviteFacebookCompletionHandler     inviteFacebookCompletionHandler;

@end
