//
//  ZFShareManager.m
//  ZZZZZ
//
//  Created by YW on 8/8/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFShareManager.h"
#import "NativeShareModel.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <VK-ios-sdk/VKSdk.h>

#import "PDKBoard.h"
#import "PDKClient.h"
#import "PDKPin.h"
#import "PDKResponseObject.h"
#import "PDKUser.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@interface ZFShareManager ()<FBSDKSharingDelegate>
@end

@implementation ZFShareManager

+ (instancetype)shareManager {
    static ZFShareManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

/** V3.4.0做Pinterest分享时需要分享商详页面的截图去分享,
 *  后来因为SDK问题授权一直会失败,因此后面版本先不处理这个需求
 */
+ (void)authenticatePinterest {
/**
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [PDKClient configureSharedInstanceWithAppId:kPinterestSDKAppId];
        [[PDKClient sharedInstance] silentlyAuthenticateWithSuccess:^(PDKResponseObject *responseObject) {
            YWLog(@"Pinterest授权成功===%@",responseObject);
        } andFailure:^(NSError *error) {
            YWLog(@"Pinterest授权失败===%@",error);
        }];
    });
*/
}

#pragma mark -===========WhatsApp分享===========

- (void)shareToWhatsApp {
    NSString *whatAppShareURL = [self fetchShareUrl:ZFShareTypeWhatsApp].absoluteString;
    NSString *url = [NSString stringWithFormat:@"whatsapp://send?text=%@", whatAppShareURL];
    NSURL *whatsappURL = [NSURL URLWithString:url];
    
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL:whatsappURL];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //分享成功通知
            ShowToastToViewWithText(nil, ZFLocalizedString(@"Share_VC_Shared_Whatapp_Success",nil));
            [self sendShareCompleteNotifycation:YES];
        });
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/en/app/whatsapp-messenger/id310633997?mt=8"]];
    }
}

#pragma mark -===========Facebook分享===========

- (void)shareToFacebook {
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [self fetchShareUrl:ZFShareTypeFacebook];
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.shareContent = content;
    dialog.fromViewController = _model.fromviewController;
    
    Class fbClass = NSClassFromString(@"FBSDKInternalUtility");
    SEL installSel = @selector(isFacebookAppInstalled);
    BOOL hasInstalledFB = NO;
    if ([fbClass respondsToSelector:installSel]) { // 有安装FB就采用原生方式分享
        hasInstalledFB = [fbClass performSelector:installSel];
    } else {
        hasInstalledFB = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fbauth2://"]];
    }
    
    if (hasInstalledFB) { // 有安装FB就采用原生方式分享
        dialog.delegate = self;
        dialog.mode = FBSDKShareDialogModeNative;
    } else {
        dialog.mode = FBSDKShareDialogModeFeedWeb;
    }
    [dialog show];
}

#pragma mark -===========Messenger分享===========

- (void)shareToMessenger {
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [self fetchShareUrl:ZFShareTypeMessenger];
    
    FBSDKMessageDialog *messageDialog = [[FBSDKMessageDialog alloc] init];
    messageDialog.delegate = self;
    [messageDialog setShareContent:content];
    
    if ([messageDialog canShow]) {
        [messageDialog show];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/en/app/facebook-messenger/id454638411?mt=8"]];
    }
}

#pragma mark -===========Pinterest分享===========

/**
 * Pinterest分享商品
 */
- (void)shareToPinterest {
    NSString *imageUrlStr = ZFEscapeString(_model.share_imageURL, YES);
    NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",imageUrlStr]];
    if (!imageUrlStr) {
        imageUrl = [NSURL URLWithString:@"https://about.pinterest.com/sites/about/files/logo.jpg"];
    }
    
    @weakify(self)
    [PDKPin pinWithImageURL:imageUrl
                       link:[self fetchShareUrl:ZFShareTypePinterest]
         suggestedBoardName:@"ZZZZZ"
                       note:self.model.share_description
                withSuccess:^{
                    @strongify(self)
                    ShowToastToViewWithText(nil, ZFLocalizedString(@"Share_VC_Shared_Pinterest_Success",nil));
                    //分享成功通知
                    [self sendShareCompleteNotifycation:YES];
                    
                } andFailure:^(NSError *error) {
                    @strongify(self)
                    ShowToastToViewWithText(nil, ZFLocalizedString(@"Failed",nil));
                    //分享成功通知
                    [self sendShareCompleteNotifycation:NO];
                }];
}

/**
 * Pinterest分享图片
 */
- (void)shareToPinterestWithImage:(UIImage *)shareImage {
    if (![shareImage isKindOfClass:[UIImage class]]) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"Failed",nil));
        [self sendShareCompleteNotifycation:NO];
        return;
    }
    NSURL *shareUrl = [self fetchShareUrl:ZFShareTypePinterest];
    
    @weakify(self)
    ShowLoadingToView(nil);
    [[PDKClient sharedInstance] createPinWithImage:shareImage link:shareUrl onBoard:@"Haha" description:self.model.share_description progress:^(CGFloat percentComplete) {
        YWLog(@"分享图片进度===%.2f",percentComplete);
        
    } withSuccess:^(PDKResponseObject *responseObject) {
        HideLoadingFromView(nil);
        @strongify(self)
        ShowToastToViewWithText(nil, ZFLocalizedString(@"Share_VC_Shared_Pinterest_Success",nil));
        [self sendShareCompleteNotifycation:YES];
     
    } andFailure:^(NSError *error) {
        @strongify(self)
        HideLoadingFromView(nil);
        ShowToastToViewWithText(nil, ZFLocalizedString(@"Failed",nil));
        [self sendShareCompleteNotifycation:NO];
    }];
}


/**
* 对VKontakte分享
*/
- (void)shareVKontakte {
    
    UIViewController * rootVc = [UIApplication sharedApplication].keyWindow.rootViewController;

    VKShareDialogController *shareDialog = [VKShareDialogController new];
    shareDialog.text = ZFToString(_model.share_description);
    
    VKShareLink *shareLink = [[VKShareLink alloc] initWithTitle:ZFToString(_model.share_title) link:[NSURL URLWithString:ZFToString(_model.share_url)]];
    shareDialog.shareLink = shareLink;
    
    NSString *imageUrlStr = ZFEscapeString(_model.share_imageURL, YES);
    NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",imageUrlStr]];
    if (!imageUrlStr) {
        imageUrl = [NSURL URLWithString:@"https://about.pinterest.com/sites/about/files/logo.jpg"];
    }
    
    NSData *imageData  = [[NSData alloc] initWithContentsOfURL:imageUrl];
    UIImage *targetImage = [UIImage imageWithData:imageData];
        
    shareDialog.uploadImages = @[ [VKUploadImage uploadImageWithImage:targetImage andParams:[VKImageParameters jpegImageWithQuality:1.0] ] ];
    [shareDialog setCompletionHandler:^(VKShareDialogController *dialog, VKShareDialogControllerResult result) {
        [rootVc dismissViewControllerAnimated:YES completion:nil];
    }];
    [rootVc presentViewController:shareDialog animated:YES completion:nil];
}
#pragma mark -===========copyLink分享===========

- (void)copyLinkURL {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSURL *url = [self fetchShareUrl:ZFShareTypeCopy];
    if (url) {
        pasteboard.string = url.absoluteString;
    }
    ShowToastToViewWithText(nil, ZFLocalizedString(@"Share_VC_Copied_Success", nil));
}

#pragma mark -===========More分享===========
- (void)shareToMore {
    NSString *textToShare = ZFToString(self.model.share_description);
    NSURL *url = [self fetchShareUrl:ZFShareTypeMore];
    NSArray *activityItems = @[textToShare, url];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems
                                                                            applicationActivities:nil];
    //不出现在活动项目
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList];
    
    //给activityVC的属性completionHandler写一个block。
    //用以UIActivityViewController执行结束后，被调用，做一些后续处理。
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType activityType, BOOL completed, NSArray * returnedItems, NSError * activityError)
    {
        YWLog(@"activityType :%@", activityType);
        /*
         com.apple.UIKit.activity.PostToFacebook
         om.facebook.Messenger.ShareExtension
         com.apple.UIKit.activity.Message
         com.apple.UIKit.activity.Mail
         net.whatsapp.WhatsApp.ShareExtension
         pinterest.ShareExtension
         com.apple.UIKit.activity.PostToTwitter
         */
        if ([ZFToString(activityType).lowercaseString containsString:@"facebook"]) {
            self.currentShareType = ZFShareTypeFacebook;
        } else if ([ZFToString(activityType).lowercaseString containsString:@"messenger"]) {
            self.currentShareType = ZFShareTypeMessenger;
        } else if ([ZFToString(activityType).lowercaseString containsString:@"whatsapp"]) {
            self.currentShareType = ZFShareTypeWhatsApp;
        } else if ([ZFToString(activityType).lowercaseString containsString:@"pinterest"]) {
            self.currentShareType = ZFShareTypePinterest;
        } else {
            self.currentShareType = ZFShareTypeMore;
        }
        
        if (completed) {
            YWLog(@"completed");
            [self sendShareCompleteNotifycation:YES];
        } else {
            YWLog(@"cancel");
            [self sendShareCompleteNotifycation:NO];
        }
    };
    
    // 初始化completionHandler，当post结束之后（无论是done还是cancell）该blog都会被调用
    activityVC.completionWithItemsHandler = myBlock;
    
    UIViewController * rootVc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVc presentViewController:activityVC animated:TRUE completion:nil];
}


#pragma mark -===========数据源===========

/**
 * 获取分享URL, V3.5.0版本需要根据类型拼接不同参数
 * utm_source=appshare&utm_medium="shareType"&utm_campaign=getitfree
 */
- (NSURL *)fetchShareUrl:(ZFShareType)shareType
{
    NSString *share_url = ZFToString(_model.share_url);
    share_url = [share_url stringByAppendingFormat:@"%@", ([share_url containsString:@"?"] ? @"&" : @"?")];
    
    if (![share_url containsString:@"utm_source="]) {
        share_url = [share_url stringByAppendingString:@"utm_source=appshare"];
    }
    
    if (![share_url containsString:@"utm_medium="]) {
        NSString *typeString = [ZFShareManager fetchShareTypePlatform:shareType];
        share_url = [share_url stringByAppendingFormat:@"&utm_medium=%@", typeString];
    }
    
    if (![share_url containsString:@"utm_campaign="]) {
        NSString *sharePageType = [self.model fetchSharePageTypeString];
        share_url = [share_url stringByAppendingFormat:@"&utm_campaign=%@", ZFToString(sharePageType)];
    }
    
    NSString *encodString = ZFEscapeString(share_url, YES);
    YWLog(@"App端分享链接追踪优化(V4.5.6)===%@", encodString);
    return [NSURL URLWithString:ZFToString(encodString)];
}

- (void)setModel:(NativeShareModel *)model {
    _model = model;
    self.currentShareType = 2018;
}

#pragma mark - FBSDKSharingDelegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    if (self.currentShareType == 0) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"Share_VC_Shared_Messenger_Success",nil));
    } else if (self.currentShareType == 1) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"Share_VC_Shared_Whatapp_Success", nil));
    } else if (self.currentShareType == 2) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"Share_VC_Shared_Facebook_Success",nil));
    } else if (self.currentShareType == 4) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"Share_VC_Shared_Pinterest_Success", nil));
    }
    
    //分享成功通知: 因为上面的results返回的是空,因此需要用变量记住分享的类型
    [self sendShareCompleteNotifycation:YES];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    ShowToastToViewWithText(nil, ZFLocalizedString(@"Failed",nil));
    //分享成功通知
    [self sendShareCompleteNotifycation:NO];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    ShowToastToViewWithText(nil, ZFLocalizedString(@"Share_VC_Cancel",nil));
    //分享成功通知
    [self sendShareCompleteNotifycation:NO];
}

/**
 * 发送分享状态
 */
- (void)sendShareCompleteNotifycation:(BOOL)shareStatus {
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    infoDic[ZFShareTypeKey] = @(self.currentShareType);
    infoDic[ZFShareStatusKey] = @(shareStatus);
    [[NSNotificationCenter defaultCenter] postNotificationName:ZFShareCompleteNotification object:infoDic userInfo:nil];
}

/**
 * 获取分享平台类型名字
 */
+ (NSString *)fetchShareTypePlatform:(ZFShareType)shareType {
    NSString *share_channel = @"";
    switch (shareType) {
        case ZFShareTypeWhatsApp: {
            share_channel = @"WhatsApp";
        }
            break;
        case ZFShareTypeFacebook: {
            share_channel = @"facebook";
        }
            break;
        case ZFShareTypeMessenger: {
            share_channel = @"messenger";
        }
            break;
        case ZFShareTypePinterest: {
            share_channel = @"pinterest";
        }
            break;
        case ZFShareTypeCopy: {
            share_channel = @"copylink";
        }
            break;
        case ZFShareTypeMore: {
            share_channel = @"more";
        }
            break;
        case ZFShareTypeVKontakte: {
            share_channel = @"VKontakte";
        }
            break;
    }
    return share_channel;
}

@end
