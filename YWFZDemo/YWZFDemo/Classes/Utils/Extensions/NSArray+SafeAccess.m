//
//  NSArray+SafeAccess.m
//  iOS-Categories (https://github.com/shaojiankui/iOS-Categories)
//
//  Created by Jakey on 15/2/8.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import "NSArray+SafeAccess.h"

@implementation NSArray (SafeAccess)

-(id)objectWithIndex:(NSUInteger)index{
    
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    if (index <self.count) {
        return self[index];
    }else{
        return nil;
    }
}

- (NSString*)stringWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return @"";
    }
    
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null])
    {
        return @"";
    }
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString*)value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    
    return nil;
}


- (NSNumber*)numberWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    id value = [self objectWithIndex:index];
    if ([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber*)value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        return [f numberFromString:(NSString*)value];
    }
    return nil;
}

- (NSDecimalNumber *)decimalNumberWithIndex:(NSUInteger)index{
    
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    id value = [self objectWithIndex:index];
    
    if ([value isKindOfClass:[NSDecimalNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber * number = (NSNumber*)value;
        return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString * str = (NSString*)value;
        return [str isEqualToString:@""] ? nil : [NSDecimalNumber decimalNumberWithString:str];
    }
    return nil;
}

- (NSArray*)arrayWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null])
    {
        return nil;
    }
    if ([value isKindOfClass:[NSArray class]])
    {
        return value;
    }
    return nil;
}


- (NSDictionary*)dictionaryWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null])
    {
        return nil;
    }
    if ([value isKindOfClass:[NSDictionary class]])
    {
        return value;
    }
    return nil;
}

- (NSInteger)integerWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return 0;
    }
    
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
    {
        return [value integerValue];
    }
    return 0;
}

- (NSUInteger)unsignedIntegerWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return 0;
    }
    id value = [self objectWithIndex:index];
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
    {
        return [value unsignedIntegerValue];
    }
    return 0;
}

- (BOOL)boolWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return NO;
    }
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return NO;
    }
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value boolValue];
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return [value boolValue];
    }
    return NO;
}
- (int16_t)int16WithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return 0;
    }
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value shortValue];
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return [value intValue];
    }
    return 0;
}
- (int32_t)int32WithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return 0;
    }
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value intValue];
    }
    return 0;
}
- (int64_t)int64WithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return 0;
    }
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value longLongValue];
    }
    return 0;
}

- (char)charWithIndex:(NSUInteger)index{
    
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return 0;
    }
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value charValue];
    }
    return 0;
}

- (short)shortWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return 0;
    }
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value shortValue];
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return [value intValue];
    }
    return 0;
}
- (float)floatWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return 0;
    }
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value floatValue];
    }
    return 0;
}
- (double)doubleWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return 0;
    }
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
    {
        return [value doubleValue];
    }
    return 0;
}

- (NSDate *)dateWithIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat {
    
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    formater.dateFormat = dateFormat;
    id value = [self objectWithIndex:index];
    
    if (value == nil || value == [NSNull null])
    {
        return nil;
    }
    
    if ([value isKindOfClass:[NSString class]] && ![value isEqualToString:@""] && !dateFormat) {
        return [formater dateFromString:value];
    }
    return nil;
}

//CG
- (CGFloat)CGFloatWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return 0.0;
    }
    id value = [self objectWithIndex:index];
    
    CGFloat f = [value doubleValue];
    
    return f;
}

- (CGPoint)pointWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return CGPointZero;
    }
    id value = [self objectWithIndex:index];

    CGPoint point = CGPointFromString(value);
    
    return point;
}
- (CGSize)sizeWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return CGSizeZero;
    }
    
    id value = [self objectWithIndex:index];

    CGSize size = CGSizeFromString(value);
    
    return size;
}
- (CGRect)rectWithIndex:(NSUInteger)index
{
    // 兼容判断
    if (![self isKindOfClass:[NSArray class]]) {
        return CGRectZero;
    }
    id value = [self objectWithIndex:index];
    
    CGRect rect = CGRectFromString(value);
    
    return rect;
}
@end


#pragma --mark NSMutableArray setter

@implementation NSMutableArray (SafeAccess)

-(void)addObj:(id)i{
    
    // 兼容判断
    if (![self isKindOfClass:[NSMutableArray class]]) {
        return ;
    }
    
    if (i!=nil) {
        [self addObject:i];
    }
}

-(void)addString:(NSString*)i
{
    // 兼容判断
    if (![self isKindOfClass:[NSMutableArray class]]) {
        return ;
    }
    if (i!=nil) {
        [self addObject:i];
    }
}

-(void)addBool:(BOOL)i
{
    // 兼容判断
    if (![self isKindOfClass:[NSMutableArray class]]) {
        return ;
    }
    [self addObject:@(i)];
}

-(void)addInt:(int)i
{
    // 兼容判断
    if (![self isKindOfClass:[NSMutableArray class]]) {
        return ;
    }
    [self addObject:@(i)];
}

-(void)addInteger:(NSInteger)i
{
    // 兼容判断
    if (![self isKindOfClass:[NSMutableArray class]]) {
        return ;
    }
    [self addObject:@(i)];
}

-(void)addUnsignedInteger:(NSUInteger)i
{
    // 兼容判断
    if (![self isKindOfClass:[NSMutableArray class]]) {
        return ;
    }
    [self addObject:@(i)];
}

-(void)addCGFloat:(CGFloat)f
{
    // 兼容判断
    if (![self isKindOfClass:[NSMutableArray class]]) {
        return ;
    }
   [self addObject:@(f)];
}

-(void)addChar:(char)c
{
    // 兼容判断
    if (![self isKindOfClass:[NSMutableArray class]]) {
        return ;
    }
    [self addObject:@(c)];
}

-(void)addFloat:(float)i
{
    // 兼容判断
    if (![self isKindOfClass:[NSMutableArray class]]) {
        return ;
    }
    [self addObject:@(i)];
}

-(void)addPoint:(CGPoint)o
{
    // 兼容判断
    if (![self isKindOfClass:[NSMutableArray class]]) {
        return ;
    }
    [self addObject:NSStringFromCGPoint(o)];
}

-(void)addSize:(CGSize)o
{
    // 兼容判断
    if (![self isKindOfClass:[NSMutableArray class]]) {
        return ;
    }
   [self addObject:NSStringFromCGSize(o)];
}

-(void)addRect:(CGRect)o
{
    // 兼容判断
    if (![self isKindOfClass:[NSMutableArray class]]) {
        return ;
    }
    [self addObject:NSStringFromCGRect(o)];
}
@end

