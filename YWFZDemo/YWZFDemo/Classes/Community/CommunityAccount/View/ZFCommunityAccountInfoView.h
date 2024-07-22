//
//  ZFCommunityAccountInfoView.h
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFCommunityAccountInfoModel;
typedef enum : NSUInteger {
    FollowerButtonActionType,
    FollowingButtonActionType,
    FollowButtonActionType,
    EditProfileButtonActionType,
    UploadAvatarButtonActionType,
    HelpButonActionType,
    GiftButtonAction,
    DrawButtonAction,
    UserRankInforActionType,
} CommunityAccountInfoActionType;


typedef void(^CommunityAccountInfoActionBlcok)(CommunityAccountInfoActionType actionType, ZFCommunityAccountInfoModel *model);

@interface ZFCommunityAccountInfoView : UIView
@property (nonatomic, strong) ZFCommunityAccountInfoModel   *model;
@property (nonatomic, assign) BOOL                          isFollow;
@property (nonatomic, copy) CommunityAccountInfoActionBlcok infoBtnActionBlcok;

- (void)setUserProfileTag;
- (void)clearUserProfileTag;

- (void)isShowBirthdayGift;


/**
 default users button state is edit
 */
- (void)defaultUserIsEditState;
@end
