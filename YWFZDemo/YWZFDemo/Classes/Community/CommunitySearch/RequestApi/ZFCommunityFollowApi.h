//
//  ZFCommunityFollowApi.h
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface ZFCommunityFollowApi : SYBaseRequest
- (instancetype)initWithFollowStatue:(NSInteger)followStatue followedUserId:(NSString *)followedUserId;
@end

