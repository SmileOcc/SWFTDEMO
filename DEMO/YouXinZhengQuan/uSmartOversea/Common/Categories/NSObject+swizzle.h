//
//  NSObject+swizzle.h
//  uSmartOversea
//
//  Created by rrd on 2018/7/19.
//Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (swizzle)


/**
 交换方法

 */
+ (void)swizzleObjectClass:(Class)cls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

@end
