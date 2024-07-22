//
//  ZFSystemPhototHelper.m
//  ZZZZZ
//
//  Created by YW on 2018/5/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSystemPhototHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "AliImageReshapeController.h"
#import "NSString+Extended.h"
#import "ZFActionSheetView.h"
#import "UIImage+ZFExtended.h"
#import "YWLocalHostManager.h"
#import "MF_Base64Additions.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import <objc/runtime.h>
#import "AccountManager.h"
#import "Constants.h"

typedef NS_ENUM(NSUInteger, ZFPhotoChooseType){
    ZFPhotoTakePhotoType = 0,  //来源:相机
    ZFPhotoAlbumsType = 1     //来源:相册
};

static char const * const kPhototHelperObjKey  = "kPhototHelperObjKey";

@interface ZFSystemPhototHelper ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, ALiImageReshapeDelegate>
@property (nonatomic, weak) UIViewController *superController;
@property (nonatomic, copy) DidUploadBlock didUploadBlock;

//默认上传
@property (nonatomic, assign) BOOL           isUpdate;
@end

@implementation ZFSystemPhototHelper

+ (void)showActionSheetChoosePhoto:(UIViewController *)control
                         callBlcok:(DidUploadBlock)block
{
    if (!control || ![control isKindOfClass:[UIViewController class]]) return;
    
    ZFSystemPhototHelper *phototHelper = [[ZFSystemPhototHelper alloc] init];
    phototHelper.superController = control;
    phototHelper.didUploadBlock = block;
    phototHelper.isUpdate = YES;
    [phototHelper showChooseAlertView];
}

+ (void)showActionSheetChoosePhoto:(UIViewController *)control
                          isUpdate:(BOOL)isUpdate
                         callBlcok:(DidUploadBlock)block
{
    if (!control || ![control isKindOfClass:[UIViewController class]]) return;
    
    ZFSystemPhototHelper *phototHelper = [[ZFSystemPhototHelper alloc] init];
    phototHelper.superController = control;
    phototHelper.didUploadBlock = block;
    phototHelper.isUpdate = isUpdate;
    [phototHelper showChooseAlertView];
}

+ (void)showActionChoosePhoto:(UIViewController *)control
                    callBlcok:(DidUploadBlock)block {
    
    ZFSystemPhototHelper *phototHelper = [[ZFSystemPhototHelper alloc] init];
    phototHelper.superController = control;
    phototHelper.didUploadBlock = block;
    phototHelper.isUpdate = NO;
    [phototHelper relationshipSuperController:YES];
    [phototHelper choosePhotoAction:ZFPhotoAlbumsType];
}
#pragma mark - 判断用户是否有权限访问相册/相机

/**
 * 判断相册权限
 */
+ (BOOL)isCanUsePhotos {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

/**
 * 判断相机权限
 */
+ (BOOL)isCanUseCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

#pragma mark - 头像点击 action
- (void)showChooseAlertView {
    NSString *photoTitle = ZFLocalizedString(@"AccoundHeaderView_TackPhoto",nil);
    NSString *albumsTitle = ZFLocalizedString(@"AccoundHeaderView_ChooseAlbum",nil);
    NSString *cancelTitle = ZFLocalizedString(@"Cancel",nil);
    [ZFActionSheetView actionSheetByBottomCornerRadius:^(NSInteger buttonIndex, id title) {
        [self relationshipSuperController:YES];
        if (buttonIndex == 0) {
            [self choosePhotoAction:ZFPhotoTakePhotoType];
        } else {
            [self choosePhotoAction:ZFPhotoAlbumsType];
        }
    } cancelButtonBlock:nil sheetTitle:nil cancelButtonTitle:cancelTitle otherButtonTitleArr:@[photoTitle, albumsTitle]];
}

/**
 * 把当前对象关联到父控制器, 否则会提前释放当前对象
 */
- (void)relationshipSuperController:(BOOL)markup
{
    if (markup) {
        objc_setAssociatedObject(self.superController, kPhototHelperObjKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self.superController, kPhototHelperObjKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

/**
 * 移除
 */
- (void)dismissPickerController:(UIViewController *)reshaper
{
    [reshaper dismissViewControllerAnimated:YES completion:^{
        [self relationshipSuperController:NO];
        // 在部分机器上发现全屏播放完视频后会出现状态栏显示的bug by: YW
        showSystemStatusBar();
    }];
}

#pragma mark - 进入拍照或选择照片

- (void)choosePhotoAction:(ZFPhotoChooseType)chooseType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.navigationBar.translucent = NO;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    UIBarButtonItem *barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor blackColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (chooseType) {
            case ZFPhotoTakePhotoType:
            {
                if (![ZFSystemPhototHelper isCanUseCamera]) {
                    ShowToastToViewWithText(self.superController.view, ZFLocalizedString(@"AccoundHeaderView_Settings_Camera",nil));
                    return;
                }
                sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.allowsEditing = YES;
            }
                break;
            case ZFPhotoAlbumsType:
            {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
                break;
            default:
                break;
        }
        
    } else {
        
        if(chooseType == ZFPhotoTakePhotoType) {
            ShowToastToViewWithText(self.superController.view, ZFLocalizedString(@"AccoundHeaderView_Divice_Unavailable",nil));
            return;
        } else {
            if (![ZFSystemPhototHelper isCanUsePhotos]) {
                ShowToastToViewWithText(self.superController.view, ZFLocalizedString(@"AccoundHeaderView_Settings_Photos",nil));
                return;
            }
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }
    imagePickerController.delegate = self;
    imagePickerController.sourceType = sourceType;
    [self.superController presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissPickerController:picker];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    AliImageReshapeController *vc = [[AliImageReshapeController alloc] init];
    vc.sourceImage = image;
    vc.reshapeScale = 1/1;
    vc.delegate = self;
    [picker pushViewController:vc animated:YES];
}

#pragma mark - ALiImageReshapeDelegate

- (void)imageReshaperController:(AliImageReshapeController *)reshaper didFinishPickingMediaWithInfo:(UIImage *)image
{
    if (!image) {
        [self dismissPickerController:reshaper];
        return;
    }
    
    if (image.size.width != 640) {
        image = [image scaleToSize:640/image.size.width];
    }
    //图片压缩
    NSData* imageData = [self compressImageWithOriginImage:image];
    // 将图片以base64的字符串返回
    NSString *imageString = [imageData base64String];
    
    if (!imageString) {
        [self dismissPickerController:reshaper];
        return;
    }
    
    if (!self.isUpdate) {
        if (self.didUploadBlock) {
            self.didUploadBlock(image);
        }
        [self dismissPickerController:reshaper];
        return;
    }
    //上传图片
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_updatePicture);
    requestModel.parmaters = @{@"image":imageString};
    
    ShowLoadingToView(nil);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(nil);
        if (ZFJudgeNSDictionary(responseObject)) {
            NSDictionary *resultDic = responseObject[ZFResultKey];
            
            if (ZFJudgeNSDictionary(resultDic)) {
                NSDictionary *dataDic = resultDic[@"data"];
                
                //针对上传头像成功后返回的url归档.
                [[AccountManager sharedManager] updateUserAvatar:dataDic[@"url"]];
                ShowToastToViewWithText(self.superController.view, resultDic[@"msg"]);
            }
        }
        if (self.didUploadBlock) {
            self.didUploadBlock(image);
        }
        [self dismissPickerController:reshaper];
        
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        ShowToastToViewWithText(self.superController.view, ZFLocalizedString(@"Global_Network_Not_Available",nil));
        [self dismissPickerController:reshaper];
    }];
}

- (void)imageReshaperControllerDidCancel:(AliImageReshapeController *)reshaper {
    [self dismissPickerController:reshaper];
}

#pragma mark - 对图片进行处理

- (NSData *)compressImageWithOriginImage:(UIImage *)originImage {
    NSData* imageData;
    float i = 1.0;
    do {
        imageData = UIImageJPEGRepresentation(originImage, i);
        i -= 0.1;
    } while (imageData.length > 2*1024*1024);
    return imageData;
}

- (void)dealloc
{
    YWLog(@"ZFSystemPhototHelper dealloc");
}

@end
