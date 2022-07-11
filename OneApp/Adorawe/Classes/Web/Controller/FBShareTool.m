//
//  FBShareTool.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "FBShareTool.h"
//#import <FBSDKShareKit/FBSDKShareKit.h>

@interface FBShareTool ()
//<FBSDKSharingDelegate>

@end

@implementation FBShareTool

- (void)shareToFacebook {
//    FBSDKShareLinkContent  *content = [[FBSDKShareLinkContent alloc] init];
////    if (self.shareContent)  content.contentDescription = self.shareContent;
//    if (self.shareURL)      content.contentURL = [NSURL URLWithString:self.shareURL];
//    if (self.shareTitle)    content.quote = self.shareTitle;
////    if (self.shareImage)    content.imageURL = [NSURL URLWithString:self.shareImage];
//    //FBSDKShareDialogModeFeedWeb 使用这个有时候会引起奔溃
//    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
//    dialog.shareContent = content;
//    dialog.mode = FBSDKShareDialogModeFeedBrowser;
//    dialog.delegate = self;
//    [dialog show];
    
}

//#pragma mark - FBSDKSharingDelegate
//- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
//{
//    [self dismissViewControllerAnimated:NO completion:^{
//        [HUDManager showShimmerMessage:STLLocalizedString_(@"Share_VC_Shared_Facebook_Success",nil)];
//    }];
//}
//
//- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
//{
//    [self dismissViewControllerAnimated:NO completion:^{
//        [HUDManager showHUDWithMessage:STLLocalizedString_(@"Failed",nil)];
//    }];
//}
//
//- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
//{
//    [self dismissViewControllerAnimated:NO completion:^{
//        [HUDManager showHUDWithMessage:STLLocalizedString_(@"cancel",nil)];
//    }];
//
//}



@end
