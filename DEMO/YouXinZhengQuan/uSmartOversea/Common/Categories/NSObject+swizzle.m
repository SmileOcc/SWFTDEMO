//
//  NSObject+swizzle.m
//  uSmartOversea
//
//  Created by rrd on 2018/7/19.
//Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "NSObject+swizzle.h"
#import <objc/runtime.h>
@implementation NSObject (swizzle)

+(void)swizzleObjectClass:(Class)cls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    
    
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    BOOL didAddMethod = class_addMethod(cls,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
   
}

@end
