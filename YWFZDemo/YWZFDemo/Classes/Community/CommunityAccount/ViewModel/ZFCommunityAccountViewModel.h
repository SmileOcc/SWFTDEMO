//
//  ZFCommunityAccountViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityAccountViewModel : BaseViewModel

- (void)requestFollowNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;


//// ===== 不能用，H5用的 ===== /////
//验证用户是否开通加入分佣计划
- (void)requestCheckCommissionNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
//开通加入分佣计划
- (void)requestJionCommissionNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;
//// ===== 不能用，H5用的 ===== /////
@end
