//
//  ZFCommunitySearchResultViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/7/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFCommunitySuggestedUsersModel.h"

@interface ZFCommunitySearchViewModel : BaseViewModel

- (void)requestSearchUsersPageData:(BOOL)isFirst
                         searchKey:(NSString *)searchKey
                        completion:(void (^)(NSMutableArray *resultDataArray, NSDictionary *pageDic))completion
                           failure:(void (^)(NSError *error))failure;

- (void)requestCommonPageData:(BOOL)isFirstData
                   completion:(void (^)(NSMutableArray *resultDataArray, NSDictionary *pageDic))completion
                      failure:(void (^)(id))failure;

- (void)requestFollowedNetwork:(id)parmaters UserID:(NSString *)ModelUserId Follow:(BOOL)isFollow completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

@end
