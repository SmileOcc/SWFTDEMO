//
//  HomeViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

@interface OSSVHomesViewModel : BaseViewModel

//- (void)requestNetworkWithOrderWarnWithCompletion:(void (^)(id))completion failure:(void (^)(id))failure;

- (void)homeRequest:(id)parmaters completion:(void (^)(id result, BOOL isCache, BOOL isEqualData))completion failure:(void (^)(id))failure;
- (void)messageRequest:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

///首页浮窗
- (void)requestHomeFloatWithCompletion:(void (^)(OSSVAdvsEventsModel *))completion failure:(void (^)(id))failure;

@end
