//
//  LoginViewModel.h
//  ZZZZZ
//
//  Created by ZJ1620 on 16/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
#import "YWLoginNewCountryModel.h"

@class YWLoginModel;

@interface LoginViewModel : BaseViewModel

@property (nonatomic, copy) NSString *deepLinkSource;

/**
 * 校验输入的邮箱是否已注册
 */
- (void)requestVerifyEamilHasRegister:(id)parmaters
                           completion:(void (^)(NSString *tipString))completion
                              failure:(void (^)(id))failure;

/**
 * 登录接口
 */
- (void)requestLoginNetwork:(YWLoginModel *)model
                 completion:(void (^)(id))completion
                    failure:(void (^)(id))failure;

/**
 * Fbid检验接口
 */
- (void)requestFbidCheckNetwork:(id)parmaters
                     completion:(void (^)(id obj))completion
                        failure:(void (^)(id obj))failure;

/**
 * FB登录
 */
- (void)requestFBLoginNetwork:(id)parmaters
                   completion:(void (^)(NSInteger error,NSString *errorMsg))completion
                      failure:(void (^)(id obj))failure;

/**
 * google id检验接口
 */
- (void)requestGoogleidCheckNetwork:(id)parmaters
                         completion:(void (^)(NSInteger error,NSString *errorMsg))completion
                            failure:(void (^)(id obj))failure;

/**
 * Google登录
 */
- (void)requestGoogleLoginNetwork:(id)parmaters
                       completion:(void (^)(NSInteger error,NSString *errorMsg))completion
                          failure:(void (^)(id obj))failure;


/**
 * VKontakte登录
 */
- (void)requestVKontakteLoginNetwork:(id)parmaters
                       completion:(void (^)(NSInteger error,NSString *errorMsg))completion
                          failure:(void (^)(id obj))failure;

/**
 * 注册接口
 */
- (void)requestRegisterNetwork:(YWLoginModel *)model
                    completion:(void (^)(id obj))completion
                       failure:(void (^)(id obj))failure;

/**
 * 忘记密码
 */
- (void)requestForgotNetwork:(id)parmaters
                  completion:(void (^)(id obj))completion
                     failure:(void (^)(id obj))failure;

/**
 * 获取新兴市场国家
 */
- (void)requestNewCountryList:(void (^)(NSArray <YWLoginNewCountryModel *>*list, NSError *error))completion;

/**
 *  发送验证码
 */
- (void)requestsSendVerifyCode:(NSString *)regionCode phone:(NSString *)phone completion:(void (^) (NSError *error))completion;

/**
 *  新兴市场国家用户注册
 */
- (void)requestNewCountryRegister:(YWLoginModel *)model completion:(void(^)(NSError *error))completion;

@end
