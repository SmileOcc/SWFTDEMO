//
//  SignViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "SignViewModel.h"
#import "LoginApi.h"
#import "RegisterApi.h"
#import "ForgotPasswordApi.h"
#import "CheckFbidApi.h"
#import "ApiloginApi.h"
#import "AccountModel.h"
#import "OSSVAccountsManager.h"
//#import <Bugly/Bugly.h>
#import "OSSVSavesSexsAip.h"
#import "STLKeychainDataManager.h"

NSString *const SignKeyOfEmail = @"email";
NSString *const SignKeyOfPassword = @"password";
NSString *const SignKeyOfSex = @"sex";
NSString *const SignKeyOfShareUserId = @"invite_uid";
NSString *const SignKeyOfShareTime = @"invite_timestamp";
NSString *const SignKeyOfSubscribe = @"subscribe";

@interface SignViewModel ()

@end

@implementation SignViewModel

#pragma mark NetRequset
- (void)requestLoginNetwork:(id)parmaters completion:(void (^)(id obj, NSString *msg))completion failure:(void (^)(id obj, NSString *msg))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        NSDictionary * dict = (NSDictionary *)parmaters;
        LoginApi *loginApi = [[LoginApi alloc] initWithEmail:dict[SignKeyOfEmail] password:dict[SignKeyOfPassword]];
        [loginApi.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [loginApi  startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            AccountModel *userModel = [self dataAnalysisFromJson: requestJSON request:loginApi];
            //更新单例数据
            if (userModel != nil) {
                [[OSSVAccountsManager sharedManager] updateUserInfo:userModel];
                //将上述数据全部存储到NSUserDefaults中
                [[NSUserDefaults standardUserDefaults] setValue:userModel.email forKey:kUserEmail]; // 保存 邮箱
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserFacebookLogin]; // 设置 是否faceBook 的登录
                //用户token
                [[OSSVAccountsManager sharedManager] saveUserToken:STLToString(userModel.token)];
                
                //用户未选择性别时获取本地性别存储信息并调用性别请求接口
                if ([OSSVAccountsManager sharedManager].account.sex == UserEnumSexTypeDefault && ![OSSVNSStringTool isEmptyString:[[NSUserDefaults standardUserDefaults] objectForKey:kGenderKey]]) {
                    NSString *sex = [[NSUserDefaults standardUserDefaults] stringForKey: kGenderKey];
                    // 修改全局默认参数, 以此为准
                    [OSSVAccountsManager sharedManager].account.sex = [sex intValue];
                    [self requestSaveSexWithSex:@""];
                }
                
                // 保存LeandCloud数据
                [OSSVAccountsManager saveLeandCloudData];
            }
            
            if (completion) {
                completion(requestJSON, requestJSON[kMessagKey]);
            }
            //登录成功，发送通知更新首页悬浮的数据
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_updateHomeFloatBannerData object:nil];
            
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil,@"fail");
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil,@"fail");
        }
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];
    }];
}

- (void)requestSaveSexWithSex:(NSString *)sex {
    
    OSSVSavesSexsAip *api = [[OSSVSavesSexsAip alloc] initWithSex:sex];
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200){
            int sex = [requestJSON[kResult][@"sex"] intValue];
            [OSSVAccountsManager sharedManager].account.sex = sex;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_ChangeGender object:nil];
        }else{
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
    }];
}

- (void)requestRegisterNetwork:(id)parmaters completion:(void (^)(id obj, NSString *msg))completion failure:(void (^)(id obj, NSString *msg))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        NSDictionary * dict = (NSDictionary *)parmaters;
        RegisterApi *registerApi = [[RegisterApi alloc] initWithEmail:dict[SignKeyOfEmail] password:dict[SignKeyOfPassword] sex:dict[SignKeyOfSex]];
        registerApi.subscribe = dict[SignKeyOfSubscribe];
        [registerApi.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [registerApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            AccountModel *userModel = [self dataAnalysisFromJson: requestJSON request:registerApi];
            if (userModel != nil) {
                [[OSSVAccountsManager sharedManager] updateUserInfo:userModel];
                // 保存注册成功的email,方便下次登录
                [[NSUserDefaults standardUserDefaults] setValue:userModel.email forKey:kUserEmail];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserFacebookLogin];
                [[NSUserDefaults standardUserDefaults] synchronize];

                //用户token
                [[OSSVAccountsManager sharedManager] saveUserToken:STLToString(userModel.token)];

                //用户未选择性别时获取本地性别存储信息并调用性别请求接口
                if ([OSSVAccountsManager sharedManager].account.sex == UserEnumSexTypeDefault && ![OSSVNSStringTool isEmptyString:[[NSUserDefaults standardUserDefaults] objectForKey:kGenderKey]]) {
                    NSString *sex = [[NSUserDefaults standardUserDefaults] stringForKey: kGenderKey];
                    // 修改全局默认参数, 以此为准
                    [OSSVAccountsManager sharedManager].account.sex = [sex intValue];
                    [self requestSaveSexWithSex:@""];
                }
                
                // 保存LeandCloud数据
                [OSSVAccountsManager saveLeandCloudData];
            }
            if (completion) {
                completion(requestJSON,requestJSON[kMessagKey]);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil,nil);
            }
            [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];
        }];
    } exception:^{
        if (failure) {
            failure(nil,nil);
        }
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];
    }];
}

- (void)requestForgotPasswordNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        NSString *email = (NSString *)parmaters;
        ForgotPasswordApi *forgotPasswordApi = [[ForgotPasswordApi alloc] initWithEmail:email];
        [forgotPasswordApi.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [forgotPasswordApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSNumber *isSuccessNumber = [self dataAnalysisFromJson: requestJSON request:forgotPasswordApi];
            BOOL isSuccess = isSuccessNumber.boolValue;
            if (completion)
            {
                completion(@(isSuccess));
            }
            
        }
                                         failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure)
            {
                failure(nil);
            }
            
        }];
    }
                                              exception:^{
        
        if (failure)
        {
            failure(nil);
        }
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];
    }];

}

- (void)requestCheckFbidNetwork:(id)parmaters token:(NSString *)token completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    CheckFbidApi *api = [[CheckFbidApi alloc] initWithFbid:parmaters token:token];
    [api.accessoryArray addObject:[[STLRequestAccessory alloc] init]];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        NSString *email = [self dataAnalysisFromJson: requestJSON request:api];
        if (completion) {
            completion(email);
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestApiloginNetwork:(id)parmaters completion:(void (^)(id obj, NSString * isNew, NSString *msg))completion failure:(void (^)(id obj,NSString *msg))failure {
    ApiloginApi *api = [[ApiloginApi alloc] initWithDict:parmaters];
    [api.accessoryArray addObject:[[STLRequestAccessory alloc] init]];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        
        
        NSArray *result = [self dataAnalysisFromJson: requestJSON request:api];
        
        if (result) {
            switch ([result[0] integerValue]) {
                case STLFBRegisterTypeSuccess:
                {
                    AccountModel *userModel = result[1];
                    if (userModel != nil) {
                        //更新单例数据
                        [[OSSVAccountsManager sharedManager] updateUserInfo:userModel];
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserFacebookLogin];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        //用户token
                        [[OSSVAccountsManager sharedManager] saveUserToken:STLToString(userModel.token)];

                        // 保存LeandCloud数据
                        [OSSVAccountsManager saveLeandCloudData];
                        
                        if (completion) {
                            completion(@YES,userModel.is_new,requestJSON[kMessagKey]);
                        }
                    } else {
                        if (completion) {
                            completion(@NO,@"",requestJSON[kMessagKey]);
                        }
                    }
                }
                    break;
                case STLFBRegisterTypeHadRegister:
                {
                    if (completion) {
                        completion(@NO,@"",requestJSON[kMessagKey]);
                    }
                }
                    break;
                default:
                    break;
            }
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil,@"fail");
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    
    if ([request isKindOfClass:[LoginApi class]])
    {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return [AccountModel yy_modelWithJSON:json[kResult]];
        } else if ([json[kStatusCode] integerValue] == kStatusCode_203) {
            
        } else
        {
            ///放到控制器展示
//            [self alertMessage:json[kMessagKey]];
        }
    }
    else if ([request isKindOfClass:[RegisterApi class]])
    {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return [AccountModel yy_modelWithJSON:json[kResult]];
        } else if([json[kStatusCode] integerValue] == kStatusCode_204) {
            
        } else
        {
            [self alertMessage:json[kMessagKey]];
        }
    }
    else if ([request isKindOfClass:[ForgotPasswordApi class]])
    {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return @(YES);
        }
        else
        {
            [self alertMessage:json[kMessagKey]];
        }
    }
    else if ([request isKindOfClass:[CheckFbidApi class]])
    {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return STLToString(json[kResult][@"email"]);
        }
        else
        {
            [self alertMessage:json[kMessagKey]];
        }
    }
    else if ([request isKindOfClass:[ApiloginApi class]])
    {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return @[@(STLFBRegisterTypeSuccess),[AccountModel yy_modelWithJSON:json[kResult]]];
        }
        else if ([json[kStatusCode] integerValue] == 201)
        {
            [self alertMessage:json[kMessagKey]];
            return @[@(STLFBRegisterTypeHadRegister)];
        }
        else
        {
            [self alertMessage:json[kMessagKey]];
        }
    }
    return nil;
}

@end
