//
//  ZFCommunityShowsListViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFCommunityFavesItemModel.h"

@interface ZFCommunityShowsListViewModel : BaseViewModel

- (void)requestShowsListData:(BOOL)firstPage
                  completion:(void (^)(NSArray <ZFCommunityFavesItemModel *> *showsListArray,NSDictionary *pageInfo))completion;

/// 首页社区帖子列表
- (void)requestPostCategoryListData:(BOOL)firstPage
                              catID:(NSString *)catID
                         completion:(void (^)(NSArray <ZFCommunityFavesItemModel *> *showsListArray,NSDictionary *pageInfo))completion;
//关注
- (void)requestFollowNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

//点赞
- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

@end
