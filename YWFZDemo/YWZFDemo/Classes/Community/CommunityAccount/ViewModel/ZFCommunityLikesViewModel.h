//
//  ZFCommunityLikesViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityLikesViewModel : BaseViewModel

- (void)requestCommunityLikesPageData:(BOOL)isFirstPage
                               userId:(NSString *)userId
                           completion:(void (^)(NSArray *currentPageData, NSDictionary *pageInfo))completion;

- (void)requestFollowNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

//点赞
- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
@end
