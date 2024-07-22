//
//  Configuration.h
//  ZZZZZ
//
//  Created by YW on 2017/3/2.
//  Copyright © 2018年 YW. All rights reserved.
//

#ifndef Configuration_h
#define Configuration_h

/**
 * 一键切换网络环境, (0️⃣:主干   1️⃣:预发布   2️⃣:线上)
 * ⚠️警告⚠️:开发期间不要提交类型为2️⃣的环境到git主仓库,
 * 线上发版时直接改成2️⃣的Type, 切换到Release模式打包发布即可
 */
#define AppRequestType                      1


// 1为加密   0不加密
#define ISENC                               @"1"
#define kDesEncrypt_key                     @"1_"
#define kDesEncrypt_iv                      @"1)d1"
#define kZZZZZAppId                         @"11111"
#define kZZZZZTeamId                        @"11111"
#define kZZZZZScheme                        @"ZZZZZ"

//-----------------------------------支付拦截配置------------------------------------------
//支付开发环境
#define PAY_DEV_SUCCESS                     @"/m-ywf-a-dopaypal.htm"
#define MY_ACCOUNT_BACK_DEV_URL             @"/m-users-a-index.htm"
#define RETURN_TO_HOME_BACK_DEV_URL         @"/m-ywf-a-payok.htm"

//EBANX支付成功
#define PAY_EBANX_DEV_SUCCESS               @"/m-ebanx-a-response.html"

#define PAY_DEV_FAIL1                       @"/?from=ios"
#define PAY_DEV_FAIL2                       @"/m-ywf-a-fails.htm"
#define PAY_DEV_FAIL3                       @"/pay/error"
#define PAY_DEV_FAIL4                       @"/m-ywf-a-refuse.htm"
#define PAYPAL_CANCEL_DEV                   @"/shopping-cart.html"

//EBANX支付取消
#define PAY_EBANX_DEV_CANCEL                @"/m-ywf-a-cart.htm"

//支付正式环境
#define PAY_SUCCESS                         @"/m-ywf-a-dopaypal.htm"
#define MY_ACCOUNT_BACK_URL                 @"/m-ywf-a-payok.htm"
#define RETURN_TO_HOME_BACK_URL             @"/m-ywf-a-payok.htm"

//EBANX支付成功
#define PAY_EBANX_SUCCESS                   @"/m-ebanx-a-response.html"

#define PAY_FAIL1                           @"/?from=ios"
#define PAY_FAIL2                           @"/m-ywf-a-fails.htm"
#define PAY_FAIL3                           @"/m-ywf-a-fails.htm"
#define PAY_FAIL4                           @"/m-ywf-a-refuse.htm"
#define PAY_FAIL5                           @"/m-ywf-a-refuse.htm"
#define PAYPAL_CANCEL                       @"/shopping-cart.html"

//EBANX支付取消
#define PAY_EBANX_CANCEL                    @"/m-ywf-a-cart.htm"

//快捷支付
#define QUICK_FILTER_CATCH_URL              @"/soa_pay/quicksuccess/?token="
#define QUICK_FILTER_CANCEL_URL             @"/soa_pay/cancel/?token="
//-----------------------------------GA帐号配置------------------------------------------

//google analytics
#define kCfgGATrackingId                    @"GoogleTrackingId"
#define kCfgDevGATrackingId                 @"devGoogleTrackingId"

// Appflyer数据
#define APPFLYER_PARAMS                     @"appflyer_params"
#define MEDIA_SOURCE                        @"media_source"
#define CAMPAIGN                            @"campaign"
#define LKID                                @"lkid"
#define FIRST_LOAD                          @"firstLoad"
#define ADID                                @"ad_id"
#define APPFLYER_ALL_PARAMS                 @"APPFLYER_ALL_PARAMS"
// Branch参数
#define BRANCH_PARAMS_TIME                  @"branch_params_time"
#define BRANCH_PARAMS                       @"branch_params"
#define BRANCH_LINKID                       @"branch_linkid"
#define UTM_SOURCE                          @"utm_source"
#define UTM_CAMPAIGN                        @"utm_campaign"
#define UTM_MEDIUM                          @"utm_medium"
#define POSTBACK_ID                         @"postback_id"
#define AFF_MSS_INFO                        @"aff_mss_info"

#define kRequestUserIdKey                   @"kRequestUserIdKey"
#define kRequestModelKey                    @"kRequestModelKey"
// 下单取时 pid, c参数
#define NOTIFICATIONS_PAYMENT_PARMATERS     @"notificationPaymentParmaters"
#define SAVE_NOTIFICATIONS_PARMATERS_TIME   @"saveNotificationsParmatersTime"
#define AFADGroup                           @"adgroup"

// ZZZZZ内部以图搜图加密key
#define kSearchImageEncryptKey              @"e10adc3949ba59abbe56e057f20f883e"

// ZZZZZ: 编辑用户信息, 登录, 注册, 获取用户信息接口加密key
#define kEncryptPublicKey @"-----BEGIN PUBLIC KEY-----\
xxx==\
-----END PUBLIC KEY-----"

//-----------------------------公共key-------------------------------
#define kInputBranchKey                     @"kInputBranchKey"
#define kInputCommunityBranchKey            @"kInputCommunityBranchKey"
#define kChangeBranchKey                    @"kChangeBranchKey"
#define kInputCMSBranchKey                  @"kInputCMSBranchKey"
#define kEnvSettingTypeKey                  @"kEnvSettingTypeKey"
#define kInputCountryIPKey                  @"kInputCountryIPKey"
#define kInputCatchLogTagKey                @"kInputCatchLogTagKey"
#define kInputCatchLogUrlKey                @"kInputCatchLogUrlKey"
#define kInputScreenShotKey                 @"kInputScreenShotKey"

#define kTrackingId YW_GA_CURRENT == nil ? YW_GA_DEFAULT : YW_GA_CURRENT
//#define kTrackingId  @"UA-87302294-4" // RG

#define YW_GA_CONFIG @{\
    @"en" : @{\
                kCfgGATrackingId                :@"UA-1-3",\
                kCfgDevGATrackingId             :@"UA-1-3",\
            },\
    @"ar" : @{\
                kCfgGATrackingId                :@"UA-1-9",\
                kCfgDevGATrackingId             :@"UA-1-5",\
            },\
    @"es" : @{\
                kCfgGATrackingId                :@"UA-1-14",\
                kCfgDevGATrackingId             :@"UA-1-3",\
            }   ,\
    @"fr" : @{\
                kCfgGATrackingId                :@"UA-1-12",\
                kCfgDevGATrackingId             :@"UA-1-3",\
            },\
}\

// -------------------------- 客服webSiteKey --------------
#define ZF_CUSTOMER_WEBSITEKEY  @{@"en":@"1", @"ar":@"1", @"es":@"1", @"fr":@"1"}

//#define ZF_WEBSITE_KEY  ZF_CUSTOMER_WEBSITEKEY[[ZFLocalizationString shareLocalizable].nomarLocalizable]
#define ZF_WEBSITE_KEY  @"1"

// -------------------------- VK --------------

#define ZF_VKApply_ID  @"1"

#endif /* Configuration_h */

