//
//  SystemConfigUtils.h
//  ZZZZZ
//
//  Created by YW on 2017/2/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemConfigUtils : NSObject
//当前语言是阿拉伯语
+ (BOOL)isRightToLeftLanguage;
//判断当前是否支持View反向
+ (BOOL)isCanRightToLeftShow;
//当前View是反向显示
+ (BOOL)isRightToLeftShow;
@end
