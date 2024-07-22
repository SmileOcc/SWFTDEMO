//
//  ZFCommunityLikeApi.h
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface ZFCommunityLikeApi : SYBaseRequest
- (instancetype)initWithReviewId:(NSString *)reviewId flag:(NSInteger)flag;
@end
