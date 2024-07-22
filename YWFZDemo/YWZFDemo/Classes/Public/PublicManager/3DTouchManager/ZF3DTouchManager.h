//
//  ZF3DTouchManager.h
//  ZZZZZ
//
//  Created by YW on 2018/4/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZF3DTouchManager : NSObject

/**
 *  注册3DTouch快捷方式
 */
+ (void)register3DTouchShortcut;

/**
 * 处理3DTouch页面跳转
 */
+ (void)dealWith3DTouchPushVC:(UIApplicationShortcutItem *)shortcutItem;

@end


