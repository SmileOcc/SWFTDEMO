//
//  ZFShareManager.h
//  ZZZZZ
//
//  Created by YW on 8/8/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ZFShareTypeKey     @"shareType" //分享类型
#define ZFShareStatusKey   @"Status" //分享状态, 1:完成(可能失败) 0:取消或失败

//分享类型
typedef NS_ENUM(NSUInteger, ZFShareType) {
    /**
     *  Messenger 分享
     */
    ZFShareTypeMessenger,
    /**
     *  WhatsApp 分享
     */
    ZFShareTypeWhatsApp,
    /**
     *  Facebook 分享
     */
    ZFShareTypeFacebook,
    /**
     *  copy link
     */
    ZFShareTypeCopy,
    /**
     *  Pinterest 分享
     */
    ZFShareTypePinterest,
    /**
     *  系统更多 分享
     */
    ZFShareTypeMore,
    /**
     *  VKontakte 分享
     */
    ZFShareTypeVKontakte
};

@class NativeShareModel;

@interface ZFShareManager : NSObject

+ (instancetype)shareManager;

/**
 * 分享数据模型
 */
@property (nonatomic, strong) NativeShareModel   *model;

/**
 * 当前分享的类型: 0:FaceBook 1:Messager 2:Copy
 */
@property (nonatomic, assign) ZFShareType currentShareType;

/**
 * WhatApp 分享
 */
- (void)shareToWhatsApp;

/**
 * FaceBook 分享
 */
- (void)shareToFacebook;

/**
 * Messenger 分享
 */
- (void)shareToMessenger;

/**
 * Pinterest 分享
 */
- (void)shareToPinterest;

/**
 * copy link
 */
- (void)copyLinkURL;

/**
 * Pinterest分享图片
 */
- (void)shareToPinterestWithImage:(UIImage *)shareImage;
/**
 * 系统更多分享
 */
- (void)shareToMore;

/**
 * 对Pinterest分享进行授权
 */
+ (void)authenticatePinterest;

/**
* 对VKontakte分享
*/
- (void)shareVKontakte;


/**
 * 获取分享平台类型名字
 */
+ (NSString *)fetchShareTypePlatform:(ZFShareType)shareType;

@end
