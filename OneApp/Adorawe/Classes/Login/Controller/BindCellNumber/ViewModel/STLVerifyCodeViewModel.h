//
//  STLVerifyCodeViewModel.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/8/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface STLVerifyCodeViewModel : BaseViewModel

@property (nonatomic, copy) NSString *countDown;

// 发送验证码
-(void)requestCodeInfo:(void (^)())completion failure:(void (^)())failure;

// 验证验证码
-(void)requestVerifiCode:(id)parms completion:(void (^)(id))completion failure:(void (^)())failure;

@end

NS_ASSUME_NONNULL_END
