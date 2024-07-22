//
//  NSArrayUtils.h
//  Yoshop
//
//  Created by YW on 16/5/31.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArrayUtils : NSObject
/**
 *  判断数组中是否有空值
 *
 *  @param array 需要判断的数组
 *  @param count 数组的个数
 *
 *  @return YES表示数组中有空值,NO表示数组中没有空值
 */
+ (BOOL)haveEmptyObject:(NSArray *)array withCount:(int)count;

/**
 *  判断数组是否为空
 *
 *  @param array 需要判断的数组
 *
 *  @return YES表示数组为空,NO表示数组不为空
 */
+ (BOOL)isEmptyArray:(id)array;
@end
