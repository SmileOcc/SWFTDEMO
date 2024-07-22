//
//  NSArrayUtils.m
//  Yoshop
//
//  Created by YW on 16/5/31.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "NSArrayUtils.h"

@implementation NSArrayUtils
+ (BOOL)haveEmptyObject:(NSArray *)array withCount:(int)count
{
    if (array.count != count) {
        return YES;
    }else
    {
        for (id object in array) {
            if (object == [NSNull null]||object == nil) {
                return YES;
            }
            else{
                if ([object isKindOfClass:[NSString class]] && [(NSString *)object isEqualToString:@""]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

+ (BOOL)isEmptyArray:(id)array
{
    if (![array isKindOfClass:[NSArray class]]) {
        return YES;
    }
    return [(NSArray *)array count] <= 0;
}

+ (id) objectInArray:(NSArray *)array withIndex:(NSUInteger)index
{
    if ([self isEmptyArray:array]) {
        return nil;
    }else if (array.count > index){
        return [array objectAtIndex:index];
    }
    return nil;
}

@end
