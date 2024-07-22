//
//  ZFCommunityPostListViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityPostListViewModel : BaseViewModel

- (void)requestTopicListData:(id)parmaters
                  completion:(void (^)(id obj, NSDictionary *pageDic))completion
                     failure:(void (^)(id))failure;

//关注
- (void)requestFollowNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
//点赞
- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
@end
