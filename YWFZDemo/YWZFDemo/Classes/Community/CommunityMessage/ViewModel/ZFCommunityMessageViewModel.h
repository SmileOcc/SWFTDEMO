//
//  ZFCommunityMessageViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityMessageViewModel : BaseViewModel

- (void)requestMessageListData:(id)parmaters
                    completion:(void (^)(id obj, NSDictionary *pageDic))completion
                       failure:(void (^)(id))failure;

- (void)requestFollowedNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
@end
