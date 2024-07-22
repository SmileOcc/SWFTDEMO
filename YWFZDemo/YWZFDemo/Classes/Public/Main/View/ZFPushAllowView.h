//
//  ZFPushAllowView.h
//  ZZZZZ
//
//  Created by YW on 30/3/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPushManager.h"

///APP登录注册时， 弹窗标志位
#define ZFUserLoginRegisterOpenPushAllowView @"ZFUserLoginRegisterOpenPushAllowView"

@interface ZFPushAllowView : UIView

///APP 启动的时候调用的方法
+ (void)AppDidFinishLanuchShowPushAllowView:(void(^)(void))completionBlock;

///APP 登录注册调用的方法
+ (void)AppLoginRegisterShowPushAllowView:(void(^)(void))completionBlock;
@end
