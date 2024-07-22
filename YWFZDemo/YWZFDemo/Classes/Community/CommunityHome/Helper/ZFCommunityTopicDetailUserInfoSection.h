//
//  ZFCommunityTopicDetailUserInfoSection.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailBaseSection.h"

@interface ZFCommunityTopicDetailUserInfoSection : ZFCommunityTopicDetailBaseSection

@property (nonatomic, copy) NSString *userAvatarURL;  // 用户头像
@property (nonatomic, copy) NSString *userNickName;   // 用户昵称
@property (nonatomic, copy) NSString *postNumber;     // 发帖数
@property (nonatomic, copy) NSString *likedNumber;    // 总被点赞数
@property (nonatomic, assign) BOOL isFollow;          // 是否已经关注

// 1官方账号, 2认证达人, 3ZMe之星
@property (nonatomic, copy) NSString *identify_type;
@property (nonatomic, copy) NSString *identify_icon;
@property (nonatomic, copy) NSString *identify_content;

@end
