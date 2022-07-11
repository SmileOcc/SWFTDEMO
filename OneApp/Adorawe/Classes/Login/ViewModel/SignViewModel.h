//
//  SignViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

UIKIT_EXTERN NSString *const SignKeyOfEmail;
UIKIT_EXTERN NSString *const SignKeyOfPassword;
UIKIT_EXTERN NSString *const SignKeyOfSex;
UIKIT_EXTERN NSString *const SignKeyOfShareUserId;
UIKIT_EXTERN NSString *const SignKeyOfShareTime;
UIKIT_EXTERN NSString *const SignKeyOfSubscribe;

@interface SignViewModel : BaseViewModel

@property (nonatomic,weak) UIViewController *controller;

- (void)requestLoginNetwork:(id)parmaters completion:(void (^)(id obj, NSString *msg))completion failure:(void (^)(id obj, NSString *msg))failure;

- (void)requestRegisterNetwork:(id)parmaters completion:(void (^)(id obj, NSString *msg))completion failure:(void (^)(id obj, NSString *msg))failure;

- (void)requestForgotPasswordNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

- (void)requestCheckFbidNetwork:(id)parmaters token:(NSString *)token completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

- (void)requestApiloginNetwork:(id)parmaters completion:(void (^)(id obj, NSString *isNew, NSString *msg))completion failure:(void (^)(id obj, NSString *msg))failure;
@end
