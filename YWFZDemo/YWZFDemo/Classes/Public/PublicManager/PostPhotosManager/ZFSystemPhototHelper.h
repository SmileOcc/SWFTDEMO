//
//  ZFSystemPhototHelper.h
//  ZZZZZ
//
//  Created by YW on 2018/5/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^DidUploadBlock)(UIImage *uploadImage);

@interface ZFSystemPhototHelper : NSObject

/**
 选择系统照片和相机
 
 @param control 打开的控制器
 @param block 处理回调
 */
+ (void)showActionSheetChoosePhoto:(UIViewController *)control
                         callBlcok:(DidUploadBlock)block;

//是否上传图片
+ (void)showActionSheetChoosePhoto:(UIViewController *)control
                          isUpdate:(BOOL)isUpdate
                         callBlcok:(DidUploadBlock)block;


//直接打开相册
+ (void)showActionChoosePhoto:(UIViewController *)control
                    callBlcok:(DidUploadBlock)block;

+ (BOOL)isCanUsePhotos;
@end
