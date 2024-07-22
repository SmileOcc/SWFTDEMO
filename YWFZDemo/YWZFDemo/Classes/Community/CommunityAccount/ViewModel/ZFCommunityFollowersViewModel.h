//
//  ZFCommunityFollowersViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityFollowersViewModel : BaseViewModel
@property (nonatomic, copy) NSString        *userId;

- (void)requestFollowersListData:(id)parmaters
                      completion:(void (^)(id obj, NSDictionary *pageDic))completion
                         failure:(void (^)(id))failure;

- (void)requestFollowUserNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

@end
