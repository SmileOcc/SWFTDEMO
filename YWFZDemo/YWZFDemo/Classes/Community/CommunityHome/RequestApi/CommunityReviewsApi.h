//
//  CommunityReviewsApi.h
//  Yoshop
//
//  Created by YW on 16/7/15.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "SYBaseRequest.h"

@interface CommunityReviewsApi : SYBaseRequest

- (instancetype)initWithcurPage:(NSInteger)curPage pageSize:(NSString*)pageSize reviewId:(NSString *)reviewId;

@end
