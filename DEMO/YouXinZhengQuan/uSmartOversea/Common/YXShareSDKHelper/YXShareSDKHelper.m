//
//  YXShareHelper.m
//  uSmartOversea
//
//  Created by ellison on 2018/9/12.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXShareSDKHelper.h"
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <WechatConnector/WechatConnector.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import "uSmartOversea-Swift.h"
//#import "uSmartOversea-Swift.h"

#if (defined IMPORT_SUB_WechatSession) || (defined IMPORT_SUB_WechatTimeline)
#import "WXApi.h"
#endif

@interface YXShareSDKHelper() <WXApiDelegate>

@property (nonatomic, assign) BOOL isAuth;

@end

@implementation YXShareSDKHelper

+ (instancetype)shareInstance {
    static YXShareSDKHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[YXShareSDKHelper alloc] init];
    });
    return helper;
}

+ (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didFinishLaunch:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
}

+ (void)_didFinishLaunch:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
            [YXShareSDKHelper shareInstance].platforms = [YXShareSDKHelper _getPlatforms];
            [YXShareSDKHelper shareInstance].platformTypes = [YXShareSDKHelper _getPlatformTypes];

            [YXShareSDKHelper _setConfigurationWithSSDKRegister:platformsRegister];
        }];
    });
}

+ (void)_setConfigurationWithSSDKRegister:(SSDKRegister *)platformsRegister {

#if (defined IMPORT_SUB_WechatSession) || (defined IMPORT_SUB_WechatTimeline)
    [platformsRegister setupWeChatWithAppId:MOBSSDKWeChatAppID appSecret:MOBSSDKWeChatAppSecret universalLink:YX_WECHAT_UNIVERSAL_LINKS];
#endif
#ifdef IMPORT_Facebook
    [platformsRegister setupFacebookWithAppkey:MOBSSDKFacebookAppID appSecret:MOBSSDKFacebookAppSecret displayName:MOBSSDKFacebookDisplayName];
#endif
#ifdef IMPORT_Twitter
    [platformsRegister setupTwitterWithKey:MOBSSDKTwitterConsumerKey secret:MOBSSDKTwitterConsumerSecret redirectUrl:MOBSSDKTwitterRedirectUri];
#endif
    
    [platformsRegister setupInstagramInFBWithClientId:MOBSSDKInstagramAppID clientSecret:MOBSSDKInstagramAppSecret redirectUrl:MOBSSDKInstagramRedirectUri];
    
    [platformsRegister setupLineAuthType:SSDKAuthorizeTypeBoth];
}

+ (NSArray *)_getPlatforms
{
    NSMutableArray *platforms = [NSMutableArray array];

#ifdef IMPORT_SUB_WechatSession
    [platforms addObject:@(SSDKPlatformSubTypeWechatSession)];
#endif
#ifdef IMPORT_SUB_WechatTimeline
    [platforms addObject:@(SSDKPlatformSubTypeWechatTimeline)];
#endif
#ifdef IMPORT_Facebook
    [platforms addObject:@(SSDKPlatformTypeFacebook)];
#endif
#ifdef IMPORT_Twitter
    [platforms addObject:@(SSDKPlatformTypeTwitter)];
#endif
    [platforms addObject:@(SSDKPlatformTypeInstagram)];
    [platforms addObject:@(SSDKPlatformTypeWhatsApp)];
    [platforms addObject:@(SSDKPlatformTypeTelegram)];
    [platforms addObject:@(SSDKPlatformTypeLine)];
    return platforms;
}
//指定的平台是否已经安装了
+ (BOOL)isClientIntalled:(SSDKPlatformType)platformType {
    return [ShareSDK isClientInstalled:platformType];
}

+ (NSArray *)_getPlatformTypes {
    NSMutableArray * platformTypes = [NSMutableArray array];
#if (defined IMPORT_SUB_WechatSession) || (defined IMPORT_SUB_WechatTimeline)
    [platformTypes addObject:@(SSDKPlatformTypeWechat)];
#endif
#ifdef IMPORT_Facebook
    [platformTypes addObject:@(SSDKPlatformTypeFacebook)];
#endif
#ifdef IMPORT_Twitter
    [platformTypes addObject:@(SSDKPlatformTypeTwitter)];
#endif

    return platformTypes;
}
//返回第三方平台对应标题
+ (NSString *)titleForPlatforms:(SSDKPlatformType)platformType {
    switch (platformType) {
        case SSDKPlatformTypeWechat:
            return [YXLanguageUtility kLangWithKey:@"share_wechat"];
        case SSDKPlatformSubTypeWechatTimeline:
            return [YXLanguageUtility kLangWithKey:@"share_wechat_timeline"];
        case SSDKPlatformTypeFacebook:
            return [YXLanguageUtility kLangWithKey:@"share_facebook"];
        case SSDKPlatformTypeTwitter:
            return [YXLanguageUtility kLangWithKey:@"share_twitter"];
        case SSDKPlatformTypeWhatsApp:
            return [YXLanguageUtility kLangWithKey:@"share_whatsapp"];
        case SSDKPlatformTypeFacebookMessenger:
            return [YXLanguageUtility kLangWithKey:@"share_facebook_messenger"];
        case SSDKPlatformTypeCopy:
            return [YXLanguageUtility kLangWithKey:@"share_copy_url"];
        case SSDKPlatformTypeLine:
            return [YXLanguageUtility kLangWithKey:@"share_line"];
        case SSDKPlatformTypeInstagram:
            return [YXLanguageUtility kLangWithKey:@"share_instagram"];
        case SSDKPlatformTypeTelegram:
            return [YXLanguageUtility kLangWithKey:@"share_telegram"];
        default:
            break;
    }
    return @"";
}

#pragma mark - Authorize Methods
//授权
- (void)authorize:(SSDKPlatformType)platformType withCallback:(ShareCallback)callback {
    if (_isAuth) {
        return;
    }
    _isAuth = YES;
    NSMutableDictionary *setting = nil;

    __weak typeof(self) weakSelf = self;
    [ShareSDK authorize:platformType settings:setting onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.isAuth = NO;

        switch (state) {
            case SSDKResponseStateSuccess:
            {
                callback(true, user.dictionaryValue, platformType);
                break;
            }
            case SSDKResponseStateFail:
            {
                if (error.code == 200301) { //取消授权
                    callback(false, @{}, platformType);
                } else {
                    callback(false, @{@"error": error}, platformType);
                }
                break;
            }
                break;
            case SSDKResponseStateCancel:
            {

                callback(false, @{}, platformType);
                break;
            }
            default:
                callback(false, nil, platformType);
                break;
        }
    }];
}
//取消授权
- (void)cancelAuthorize:(SSDKPlatformType)platformType withCallback:(ShareCallback)callback {
    [ShareSDK cancelAuthorize:platformType result:^(NSError *error) {
        callback(true, @{@"error": error}, platformType);
    }];
}

#pragma mark - UserInfo Methods
//获取用户信息
- (void)getUserInfo:(SSDKPlatformType)platformType withCallback:(ShareCallback)callback {
    [ShareSDK getUserInfo:platformType onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        switch (state) {
            case SSDKResponseStateSuccess:
            {
                NSLog(@"获取成功 %@, %@", user.dictionaryValue,@(platformType));
                callback(true, user.dictionaryValue, platformType);
            }
                break;
            case SSDKResponseStateFail:
            {
                NSLog(@"获取失败, %@, %@",error, @(platformType));
                callback(false, @{@"error": error}, platformType);
            }
                break;
            case SSDKResponseStateCancel:
            {
                callback(false, @{}, platformType);
            }
                break;
            default:
                callback(false, nil, platformType);
                break;
        }
    }];
}

#pragma mark - Share Methods
//自定义分享
- (void)share:(SSDKPlatformType)platformType parameters:(NSMutableDictionary *)params  withCallback:(ShareCallback)callback {
    //三、无UI分享
    [ShareSDK share:platformType parameters:params
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
         switch (state) {
             case SSDKResponseStateSuccess:
             {
                 callback(true, userData, platformType);
             }
                 break;
             case SSDKResponseStateFail:
             {
                 if ((platformType == SSDKPlatformTypeFacebook || platformType == SSDKPlatformTypeUnknown) && error != nil) {
                     NSDictionary *userInfo = error.userInfo;
                     if (userInfo[@"error_code"] && userInfo[@"error_message"]) {
                         NSInteger error_code = [userInfo[@"error_code"] integerValue];
                         NSString *error_message = userInfo[@"error_message"];
                         if (error_code == 200302 && [error_message isEqualToString:@"分享状态未知"]) {
                             callback(true, userData, platformType);
                         } else {
                             callback(false, @{@"error": error}, platformType);
                         }
                     } else {
                         callback(false, @{@"error": error}, platformType);
                     }
                 } else {
                     callback(false, @{@"error": error}, platformType);
                 }
             }
                 break;
             case SSDKResponseStateCancel:
             {
                 callback(false, @{}, platformType);
             }
                 break;
             default:
                 callback(false, nil, platformType);
                 break;
                 
         }
     }];
}
//通用分享
- (void)share:(SSDKPlatformType)platformType text:(NSString *)text images:(id)images url:(NSURL *)url title:(NSString *)title type:(SSDKContentType)type withCallback:(ShareCallback)callback {
    if (platformType == SSDKPlatformTypeWechat || platformType == SSDKPlatformSubTypeWechatTimeline) {
        if (text.length > 200) {
            text = [text substringToIndex:200];
        }
        if (title.length > 100) {
            title = [title substringToIndex:100];
        }
    } else if (platformType == SSDKPlatformTypeTwitter) {
        if (text.length > 140) {
            text = [text substringToIndex:140];
        }
    }
    
    if ((platformType == SSDKPlatformTypeLine || platformType == SSDKPlatformTypeWhatsApp) && url != nil ) {//line whatsapp 只支持文字不支持链接 分享
        text = [NSString stringWithFormat:@"%@ %@",text,url.absoluteString];
        url = nil;
    }
    
    if (platformType == SSDKPlatformTypeTelegram) {//telegram 只支持纯图片 或 链接
        title = @"";
        text = @"";
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (platformType == SSDKPlatformTypeFacebook) {
        if (url == nil || url.absoluteString == nil || url.absoluteString.length == 0) {
            [parameters SSDKSetupShareParamsByText:text
                                            images:images
                                               url:url
                                             title:title
                                              type:type];
        } else {
            [parameters SSDKSetupFacebookParamsByText:text image:images url:url urlTitle:title urlName:nil attachementUrl:nil hashtag:nil quote:nil shareType:SSDKFacebookShareTypeNative type:SSDKContentTypeWebPage];
        }
    } else {
        //通用参数设置
        [parameters SSDKSetupShareParamsByText:text
                                        images:images
                                           url:url
                                         title:title
                                          type:type];
    }
    [self share:platformType parameters:parameters withCallback:callback];
}
//v4.1.2 为微信小程序分享增加
- (void)shareMiniProgramByPlatformType:(SSDKPlatformType)platformType
                                 title:(NSString *)title
                           description:(NSString *)description
                            webpageUrl:(NSURL *)webpageUrl
                                  path:(NSString *)path
                            thumbImage:(id)thumbImage
                          hdThumbImage:(id)hdThumbImage
                              userName:(NSString *)userName
                       withShareTicket:(BOOL)withShareTicket
                       miniProgramType:(NSUInteger)type
                    forPlatformSubType:(SSDKPlatformType)platformSubType
                              callback:(ShareCallback)callback {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    //通用参数设置
    [parameters SSDKSetupWeChatMiniProgramShareParamsByTitle:title description:description webpageUrl:webpageUrl path:path thumbImage:thumbImage hdThumbImage:hdThumbImage userName:userName withShareTicket:withShareTicket miniProgramType:type forPlatformSubType:platformSubType];
    [self share:platformType parameters:parameters withCallback:callback];
}


#pragma mark - handleOpenURL
- (void)handleOpenURL:(NSURL *)url {
    [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity {
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

#pragma mark - WXApiDelegate
- (void)onReq:(id)req {
    if ([req isKindOfClass:[BaseReq class]]) {
        NSLog(@"--->%s wxapi onreq:%@",__func__,req);
    } else {
        NSLog(@"--->%s qqapi onreq:%@",__func__,req);
    }
}

- (void)onResp:(id)resp {
    if ([resp isKindOfClass:[BaseResp class]]) {
        NSLog(@"--->%s wxapi onresp:%@",__func__,resp);
    } else {
        NSLog(@"--->%s qqapi onresp:%@",__func__,resp);
    }
}

- (void)isOnlineResponse:(NSDictionary *)response {
    NSLog(@"--->%s qqapi isOnlineResponse:%@",__func__,response);
}

@end
