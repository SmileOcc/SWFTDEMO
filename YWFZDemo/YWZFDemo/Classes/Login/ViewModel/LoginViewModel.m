//
//  LoginViewModel.m
//  ZZZZZ
//
//  Created by ZJ1620 on 16/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "LoginViewModel.h"
#import "ForgotPasswordApi.h"
#import "FbidCheckApi.h"
#import "FBLoginApi.h"
#import "GoogleLoginApi.h"
#import "ZFVKontakteApi.h"
#import "ZFValidationEmailPai.h"
#ifdef LeandCloudEnabled
#   import <AVOSCloud/AVOSCloud.h>
#endif
#import <AdSupport/AdSupport.h>
#import "YWLoginModel.h"
#import "YWLocalHostManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "YSAlertView.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "RSA.h"

static NSString *const RegisterKeyEmail = @"email";
static NSString *const RegisterKeyPassword = @"password";
static NSString *const RegisterKeyConfirmPassword = @"confirmPassword";

@implementation LoginViewModel

#pragma mark - NetRequset

/**
 * 校验输入的邮箱是否已注册
 */
- (void)requestVerifyEamilHasRegister:(id)parmaters
                           completion:(void (^)(NSString *tipString))completion
                              failure:(void (^)(id))failure
{
    NSDictionary *dict = parmaters;
    NSString *email = ZFToString(dict[@"email"]);
    ZFValidationEmailPai *validationEmailPai = [[ZFValidationEmailPai alloc] initWithEmail:email];
    [validationEmailPai startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(validationEmailPai.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            NSDictionary *dataDict = requestJSON[ZFResultKey];
            
            //'error’:1, 状态：0验证通过 1验证不通过
            NSString *tipString = nil;
            if ([dataDict[@"error"] integerValue] == 1) {
                tipString = ZFToString(dataDict[@"msg"]);
            }
            
            if (completion) {
                completion(tipString);
            }
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        YWLog(@"\n-------------------------- 错误日志 --------------------------\n接口:%@\n状态码:%ld\n报错信息:%@",NSStringFromClass(request.class),request.responseStatusCode,request.responseString);
        if (failure) {
            failure(nil);
        }
        ShowToastToViewWithText(dict, ZFLocalizedString(@"Global_Network_Not_Available",nil));
    }];
}

/**
 * 更新用户信息
 */
- (void)updateAccountInfo:(NSDictionary *)dataDict
{
    AccountModel *userModel = [AccountModel yy_modelWithJSON:dataDict[@"data"]];
    [[AccountManager sharedManager] updateUserInfo:userModel];
    [[NSUserDefaults standardUserDefaults] setValue:userModel.email forKey:kUserEmail];
    [[NSUserDefaults standardUserDefaults] setValue:@([dataDict[@"data"][@"cart_number"] integerValue]) forKey:kCollectionBadgeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * 处理登录注册返回
 */
- (void)dealwithLoginAndReginster:(NSDictionary *)responseObject
                       completion:(void (^)(id))completion
{
    NSDictionary *resultDict = responseObject[ZFResultKey];
    if (ZFJudgeNSDictionary(resultDict) && [resultDict[@"error"] integerValue] == 0) {
        
        NSDictionary *dataDict = resultDict[ZFDataKey];
        NSString *encryptString = resultDict[@"encryptData"];
        
        if (ZFJudgeNSDictionary(dataDict) && !ZFIsEmptyString(encryptString)) {
            // 重要敏感信息放在加密字段里面
            NSString *decryptJson = [RSA decryptString:encryptString publicKey:kEncryptPublicKey];
            
            if (!ZFIsEmptyString(decryptJson)) {
                NSData *jsonData = [decryptJson dataUsingEncoding:NSUTF8StringEncoding];
                if (jsonData) {
                    NSDictionary *encryptDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                options:NSJSONReadingMutableContainers
                                                                                  error:nil];
                    if (ZFJudgeNSDictionary(encryptDict)) {
                        NSMutableDictionary *fullResultDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
                        YWLog(@"登录注册接口: 合并普通信息和加密的敏感信息===%@", encryptDict)
                        [fullResultDict addEntriesFromDictionary:encryptDict];
                        
                        // 更新用户信息
                        [self updateAccountInfo:@{ZFDataKey : fullResultDict}];
                        
                        // 保存LeandCloud数据
                        [AccountManager saveLeandCloudData];
                        
                        if (completion) {
                            completion(nil);
                        }
                        return ;
                    }
                }
            }
        }
    }
    NSString *errorTipStr = ZFGetStringFromDict(resultDict, @"msg");
    if (ZFIsEmptyString(errorTipStr)) {
        errorTipStr = ZFLocalizedString(@"EmptyCustomViewManager_titleLabel", nil);
    }
    NSString *cancelTitle = ZFLocalizedString(@"LoginForgotView_OK",nil);
    ShowAlertSingleBtnView(nil, errorTipStr, cancelTitle);
}

/**
 * 登录接口
 */
- (void)requestLoginNetwork:(YWLoginModel *)model
                 completion:(void (^)(id))completion
                    failure:(void (^)(id))failure
{
    ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
    NSString *device_id = [AccountManager sharedManager].device_id;
    NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    
    NSDictionary *dataDict = @{@"sess_id"           : ZFToString(SESSIONID),
                               @"email"             : ZFToString(model.email),
                               @"password"          : ZFToString(model.password),
                               ZFApiCountryIdKey    : ZFToString(accountModel.region_id),
                               ZFApiCountryCodeKey  : ZFToString(accountModel.region_code),
                               ZFApiDeviceId        : ZFToString(device_id),
                               ZFApiLangKey         : ZFToString(lang),
                               };
    
    NSString *dataJson = [dataDict yy_modelToJSONString];
    NSString *encryptString = [RSA encryptString:dataJson publicKey:kEncryptPublicKey];
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.eventName = @"sign_in";
    requestModel.taget = self.controller;
    requestModel.url = API(Port_login);
    requestModel.forbidAddPublicArgument = YES; // 登录接口需要加密,不添加公共参数
    requestModel.parmaters = @{@"is_enc"  : @"2",
                               @"data"    : ZFToString(encryptString) };
    ShowLoadingToView(nil);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        HideLoadingFromView(nil);
        [self dealwithLoginAndReginster:responseObject completion:completion];
        
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        if (failure) {
            failure(nil);
        }
        ShowToastToViewWithText(nil, error.domain);
    }];
}

/**
 * Fbid检验接口
 */
- (void)requestFbidCheckNetwork:(id)parmaters
                     completion:(void (^)(id obj))completion
                        failure:(void (^)(id obj))failure {
    
    NSDictionary *dict = parmaters;
    FbidCheckApi *checkApi = [[FbidCheckApi alloc] initWithDict:parmaters];
    ShowLoadingToView(dict);
    [checkApi startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(checkApi.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            NSDictionary *dataDict = requestJSON[ZFResultKey];
            if ([dataDict[@"error"] integerValue] == 0) {
                // 更新用户信息
                [self updateAccountInfo:dataDict];
                
                // 保存LeandCloud数据
                [AccountManager saveLeandCloudData];
                
                if (completion) {
                    completion(@YES);
                }
            } else {
                if (completion) {
                    completion(@NO);
                }
            }
        } else {
            ShowToastToViewWithText(nil, ZFLocalizedString(@"Failed",nil));
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
    }];
}

/**
 * google id检验接口
 */
- (void)requestGoogleidCheckNetwork:(id)parmaters
                         completion:(void (^)(NSInteger error,NSString *errorMsg))completion
                            failure:(void (^)(id obj))failure {
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.eventName = @"google_id_check";
    requestModel.taget = self.controller;
    requestModel.url = API(Port_googleCheckID);
    requestModel.timeOut = 60;
    requestModel.parmaters = @{
                               @"sess_id"      : SESSIONID,
                               @"googleId"     : parmaters[@"googleId"],
                               @"access_token" : parmaters[@"access_token"]
                               };
    ShowLoadingToView(nil);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(nil);
        NSDictionary *dataDict = responseObject[ZFResultKey];
        
        if (ZFJudgeNSDictionary(dataDict) && [dataDict[@"error"] integerValue] == 0) {
            AccountModel *userModel = [AccountModel yy_modelWithJSON:dataDict[@"returnInfo"]];
            [[AccountManager sharedManager] updateUserInfo:userModel];
            [[NSUserDefaults standardUserDefaults] setValue:userModel.email forKey:kUserEmail];
            [[NSUserDefaults standardUserDefaults] setValue:@([dataDict[@"data"][@"cart_number"] integerValue]) forKey:kCollectionBadgeKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // 保存LeandCloud数据
            [AccountManager saveLeandCloudData];
            
            if (completion) {
                completion([dataDict[@"error"] integerValue],@"");
            }
        } else {
            [self handleThirdResult:dataDict completion:completion];
        }
        
    } failure:^(NSError *error) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
    }];
}


- (void)handleThirdResult:(NSDictionary *)dataDict completion:(void (^)(NSInteger error,NSString *errorMsg))completion {
    if (ZFJudgeNSDictionary(dataDict)) {
        
        NSInteger error = [dataDict[@"error"] integerValue];
        NSString *errorString = ZFToString(dataDict[@"msg"]);

        if (completion) {
            if (error == 1 || error == 2 || error != 7 ) {
                completion(error,@"");
            } else {
                if (ZFIsEmptyString(errorString)) {
                    errorString = ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil);
                }
                ShowToastToViewWithText(nil, errorString);
                completion(error,errorString);
            }
        }
    } else {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
    }
}
/**
 * FB登录接口
 */
- (void)requestFBLoginNetwork:(id)parmaters
                   completion:(void (^)(NSInteger error,NSString *errorMsg))completion
                      failure:(void (^)(id obj))failure {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parmaters];
    dict[@"source"] = ZFToString(self.deepLinkSource);
    FBLoginApi *api = [[FBLoginApi alloc] initWithDict:dict];
    api.eventName = @"facebook_login";
    api.taget = self.controller;
    ShowLoadingToView(dict);
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            NSDictionary *dataDict = requestJSON[ZFResultKey];
            NSInteger errorCode = [dataDict[@"error"] integerValue];
            if (ZFJudgeNSDictionary(dataDict) && errorCode == 0) {
                // 更新用户信息
                [self updateAccountInfo:dataDict];
                // 保存LeandCloud数据
                [AccountManager saveLeandCloudData];
                
                if (completion) {
                    completion(errorCode,@"");
                }
            } else  {
                [self handleThirdResult:dataDict completion:completion];
            }
        } else {
            
            NSString *msg = @"";
            if (ZFJudgeNSDictionary(requestJSON)) {
                msg = ZFToString(requestJSON[@"msg"]);
            }
            
            if (!ZFIsEmptyString(msg)) {
                ShowToastToViewWithText(nil, msg);
            } else {
                ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
            }

        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(dict);
        ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
        if (failure) {
            failure(nil);
        }
    }];
}

/**
 * Google登录接口
 */
- (void)requestGoogleLoginNetwork:(id)parmaters
                       completion:(void (^)(NSInteger error,NSString *errorMsg))completion
                          failure:(void (^)(id obj))failure {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parmaters];
    dict[@"source"] = ZFToString(self.deepLinkSource);
    GoogleLoginApi *api = [[GoogleLoginApi alloc] initWithDict:dict];
    api.eventName = @"google_login";
    api.taget = self.controller;
    
    ShowLoadingToView(dict);
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
         if (ZFJudgeNSDictionary(requestJSON) && [requestJSON[@"statusCode"] integerValue] == 200) {
             NSDictionary *dataDict = requestJSON[ZFResultKey];
             if ([dataDict[@"error"] integerValue] == 0) {
                 
                 AccountModel *userModel = [AccountModel yy_modelWithJSON:dataDict[@"returnInfo"]];
                 [[AccountManager sharedManager] updateUserInfo:userModel];
                 [[NSUserDefaults standardUserDefaults] setValue:userModel.email forKey:kUserEmail];
                 [[NSUserDefaults standardUserDefaults] setValue:@([dataDict[@"returnInfo"][@"cart_number"] integerValue]) forKey:kCollectionBadgeKey];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 // 保存LeandCloud数据
                 [AccountManager saveLeandCloudData];
                 
                 if (completion) {
                     completion(0,@"");
                 }

             } else{
                 [self handleThirdResult:dataDict completion:completion];
             }
             
         } else {
             NSString *msg = @"";
             if (ZFJudgeNSDictionary(requestJSON)) {
                 msg = ZFToString(requestJSON[@"msg"]);
             }
             
             if (!ZFIsEmptyString(msg)) {
                 ShowToastToViewWithText(nil, msg);
             } else {
                 ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
             }
         }

    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
        if (failure) {
            failure(nil);
        }
    }];
}

/**
* VKontakte登录
*/
- (void)requestVKontakteLoginNetwork:(id)parmaters
                          completion:(void (^)(NSInteger error,NSString *errorMsg))completion
                             failure:(void (^)(id obj))failure {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parmaters];
    dict[@"source"] = ZFToString(self.deepLinkSource);
    ZFVKontakteApi *api = [[ZFVKontakteApi alloc] initWithDict:dict];
    api.eventName = @"vkontakte_login";
    api.taget = self.controller;
    
    ShowLoadingToView(dict);
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
         if ([requestJSON[@"statusCode"] integerValue] == 200) {
             NSDictionary *dataDict = requestJSON[ZFResultKey];
             if (ZFJudgeNSDictionary(dataDict) && [dataDict[@"error"] integerValue] == 0) {
                 
                 AccountModel *userModel = [AccountModel yy_modelWithJSON:dataDict[@"returnInfo"]];
                 [[AccountManager sharedManager] updateUserInfo:userModel];
                 [[NSUserDefaults standardUserDefaults] setValue:userModel.email forKey:kUserEmail];
                 [[NSUserDefaults standardUserDefaults] setValue:@([dataDict[@"returnInfo"][@"cart_number"] integerValue]) forKey:kCollectionBadgeKey];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 // 保存LeandCloud数据
                 [AccountManager saveLeandCloudData];
                 
                 if (completion) {
                     completion(0,@"");
                 }

             }else{
                 [self handleThirdResult:dataDict completion:completion];
             }
         } else {
             NSString *msg = @"";
             if (ZFJudgeNSDictionary(requestJSON)) {
                 msg = ZFToString(requestJSON[@"msg"]);
             }
             
             if (!ZFIsEmptyString(msg)) {
                 ShowToastToViewWithText(nil, msg);
             } else {
                 ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
             }
        }

    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
        if (failure) {
            failure(nil);
        }
    }];
}
/**
 * 注册接口--用户注册
 */
- (void)requestRegisterNetwork:(YWLoginModel *)model
                    completion:(void (^)(id obj))completion
                       failure:(void (^)(id obj))failure {
    
    ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
    NSString *device_id = [AccountManager sharedManager].device_id;
    NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    NSString *ad_id = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    NSDictionary *dataDict = @{@"repassword"        : ZFToString(model.password),
                               @"sex"               : ZFToString(model.sex),
                               @"af_uid"            : [AppsFlyerTracker sharedTracker].getAppsFlyerUID,
                               @"sess_id"           : SESSIONID,
                               @"issubscribe"       : ZFToString(@(model.isSubscribe)),
                               @"source"            : ZFToString(self.deepLinkSource),
                               ZFApiCountryIdKey    : ZFToString(accountModel.region_id),
                               @"password"          : ZFToString(model.password),
                               ZFApiCountryCodeKey  : ZFToString(accountModel.region_code),
                               ZFApiLangKey         : ZFToString(lang),
                               @"wj_linkid"         : [NSStringUtils getLkid],
                               ZFApiDeviceId        : ZFToString(device_id),
                               @"email"             : ZFToString(model.email),
                               @"ad_id"             : ZFToString(ad_id),
                               };
    
    NSString *dataJson = [dataDict yy_modelToJSONString];
    NSString *encryptString = [RSA encryptString:dataJson publicKey:kEncryptPublicKey];
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.eventName = @"sign_up";
    requestModel.taget = self.controller;
    requestModel.url = API(Port_register);
    requestModel.forbidAddPublicArgument = YES; // 注册接口需要加密,不添加公共参数
    requestModel.parmaters = @{@"is_enc"  : @"2",
                               @"data"    : ZFToString(encryptString) };
    ShowLoadingToView(nil);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        HideLoadingFromView(nil);
        [self dealwithLoginAndReginster:responseObject completion:completion];
        
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);        
        if (failure) {
            failure(nil);
        }
        ShowToastToViewWithText(nil, error.domain);
    }];
}

/**
 * 忘记密码
 */
- (void)requestForgotNetwork:(id)parmaters
                  completion:(void (^)(id))completion
                     failure:(void (^)(id))failure
{
    NSDictionary *dict = parmaters;
    ForgotPasswordApi *api = [[ForgotPasswordApi alloc] initWithEmail:dict[@"email"]];
    api.eventName = @"password_forgot";
    api.taget = self.controller;
    ShowLoadingToView(dict);
    [api  startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            NSDictionary *dataDict = requestJSON[ZFResultKey];
            NSInteger errorCode = [dataDict[@"error"] integerValue];
            NSString *msg = dataDict[@"msg"];
            NSDictionary *result = @{
                                     @"errorCode" : @(errorCode),
                                     @"msg" : ZFToString(msg)
                                     };
            if (completion) {
                completion(result);
            }
            
//            if (errorCode == 0) {
//                
//                //发送邮件成功
//                NSString *tips = [NSString stringWithFormat:@"%@ %@ %@", ZFLocalizedString(@"LoginForgotView_SuccessView_Descripe",nil), dict[@"email"], ZFLocalizedString(@"LoginForgotView_SuccessView_Descripe2",nil)];
//                
//                NSString *cancelTitle = ZFLocalizedString(@"LoginForgotView_OK",nil);
//                ShowAlertView(nil, tips, nil, nil, cancelTitle, nil);
// 
//                if (completion) {
//                    completion(@(YES));
//                }
//            } else {
//                
//            }
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(dict);
        if (failure) {
            failure(nil);
        }
        ShowToastToViewWithText(dict, ZFLocalizedString(@"Global_Network_Not_Available",nil));
    }];
}

- (void)requestNewCountryList:(void (^)(NSArray <YWLoginNewCountryModel *>*list, NSError *error))completion
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(@"common/get_emerging_country");
    ShowLoadingToView(nil);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(nil);
        NSDictionary *resultDict = responseObject[ZFResultKey];
        NSArray *list = [NSArray yy_modelArrayWithClass:[YWLoginNewCountryModel class] json:resultDict];
        if (completion) {
            if ([list count]) {
                completion(list, nil);
            } else {
                completion(nil, [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:@{}]);
            }
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)requestsSendVerifyCode:(NSString *)regionCode phone:(NSString *)phone completion:(void (^) (NSError *error))completion
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(@"common/send_verify_code");
    requestModel.parmaters = @{
                               @"region_id" : ZFToString(regionCode),
                               @"phone" : ZFToString(phone),
                               @"sign" : @"register_code_verify"
                               };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *resultDict = responseObject[ZFResultKey];
//        NSInteger returnCode = [responseObject[@"returnCode"] integerValue];
        NSInteger errorCode = [resultDict[@"error"] integerValue];
        if (errorCode == 1) {
            ShowToastToViewWithText(nil, resultDict[@"msg"]);
            if (completion) {
                completion([NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:@{@"msg" : ZFToString(resultDict[@"msg"])}]);
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }
    } failure:^(NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

/**
 *  新兴市场国家用户注册
 */
- (void)requestNewCountryRegister:(YWLoginModel *)model completion:(void(^)(NSError *error))completion
{
    ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
    NSString *device_id = [AccountManager sharedManager].device_id;
    NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    NSString *ad_id = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    NSDictionary *dataDict = @{@"repassword"        : ZFToString(model.password),
                               @"sex"               : ZFToString(model.sex),
                               @"af_uid"            : [AppsFlyerTracker sharedTracker].getAppsFlyerUID,
                               @"sess_id"           : SESSIONID,
                               @"issubscribe"       : ZFToString(@(model.isSubscribe)),
                               @"source"            : ZFToString(self.deepLinkSource),
                               ZFApiCountryIdKey    : ZFToString(accountModel.region_id),
                               ZFApiCountryCodeKey  : ZFToString(accountModel.region_code),
                               ZFApiLangKey         : ZFToString(lang),
                               @"wj_linkid"         : [NSStringUtils getLkid],
                               ZFApiDeviceId        : ZFToString(device_id),
                               @"ad_id"             : ZFToString(ad_id),
                               @"phone"             : ZFToString(model.phoneNum),
                               @"verify_code"       : ZFToString(model.VerificationCodeNum),
                               @"region_id"         : ZFToString(model.region_id)
                               };
    
    NSString *dataJson = [dataDict yy_modelToJSONString];
    NSString *encryptString = [RSA encryptString:dataJson publicKey:kEncryptPublicKey];
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.eventName = @"sign_up";
    requestModel.taget = self.controller;
    requestModel.url = API(@"user/phone_sign");
    requestModel.forbidAddPublicArgument = YES; // 注册接口需要加密,不添加公共参数
    requestModel.parmaters = @{@"is_enc"  : @"2",
                               @"data"    : ZFToString(encryptString) };
    ShowLoadingToView(nil);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        HideLoadingFromView(nil);
        [self dealwithLoginAndReginster:responseObject completion:completion];
        
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        if (completion) {
            completion(error);
        }
        ShowToastToViewWithText(nil, error.domain);
    }];
}

@end
