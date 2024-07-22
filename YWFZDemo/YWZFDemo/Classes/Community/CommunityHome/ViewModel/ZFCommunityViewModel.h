//
//  ZFCommunityViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFCommunityHotTopicModel.h"
#import "ZFOutfitSearchHotWordManager.h"

@interface ZFCommunityViewModel : BaseViewModel

+ (void)requestMessageCountNetwork:(id)parmaters
                        completion:(void (^)(NSInteger msgCount))completion
                           failure:(void (^)(NSError *error))failure;

/**
* 热门话题列表
*/
- (void)requestHotTopicList:(BOOL)isPicture completion:(void(^)(NSArray<ZFCommunityHotTopicModel *> *results))completion;

/**
* 关联帖子最多的话题列表
*/
- (void)requestReviewTopicList:(id)parmaters completion:(void(^)(NSArray<HotWordModel *> *results))completion;
@end
