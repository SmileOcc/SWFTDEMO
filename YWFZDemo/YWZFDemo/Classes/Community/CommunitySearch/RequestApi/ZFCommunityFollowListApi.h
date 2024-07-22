//
//  ZFCommunityFollowListApi.h
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

typedef NS_ENUM(NSInteger, ZFUserListType) {
    ZFUserListTypeLike = 5,
    ZFUserListTypeFollowing = 0,
    ZFUserListTypeFollowed = 1,
};

@interface ZFCommunityFollowListApi : SYBaseRequest

- (instancetype)initWithCurPage:(NSString *)curPage userListType:(ZFUserListType)userListType userId:(NSString *)userId;

@end

