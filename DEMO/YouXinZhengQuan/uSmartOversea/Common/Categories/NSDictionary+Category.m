//
//  NSDictionary+Category.m
//  iBoxCategory
//
//  Created by TBD on 2018/4/23.



#import "NSDictionary+Category.h"

@implementation NSDictionary (Category)

- (BOOL)yx_boolValueForKey:(id<NSCopying>)key {
    return [self yx_boolValueForKey:key defaultValue:NO];
}

- (BOOL)yx_boolValueForKey:(id<NSCopying>)key defaultValue:(BOOL)defaultValue {
    id value = self[key];
    
    if (value == [NSNull null] || value == nil) {
        return defaultValue;
    } else {
        return [value boolValue];
    }
}

- (int)yx_intValueForKey:(id<NSCopying>)key {
    return [self yx_intValueForKey:key defaultValue:0];
}

- (int)yx_intValueForKey:(id<NSCopying>)key defaultValue:(int)defaultValue {
    id value = self[key];
    
    if (value == [NSNull null] || value == nil) {
        return defaultValue;
    } else {
        return [value intValue];
    }
}

- (NSString *)yx_stringValueForKey:(id<NSCopying>)key {
    return [self yx_stringValueForKey:key defaultValue:nil];
}

- (NSString *)yx_stringValueForKey:(id<NSCopying>)key defaultValue:(NSString *)defaultValue {
    id value = self[key];
    if (value == nil || value == [NSNull null]) {
        return defaultValue;
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    
    return value;
}

- (long long)yx_longLongValueForKey:(id<NSCopying>)key {
    return [self yx_longLongValueForKey:key defaultValue:0];
}

- (long long)yx_longLongValueForKey:(id<NSCopying>)key defaultValue:(long long)defaultValue {
    id value = self[key];
    
    if (value == [NSNull null] || value == nil) {
        return defaultValue;
    } else {
        return [value longLongValue];
    }
}

- (double)yx_doubleValueForKey:(id<NSCopying>)key {
    return [self yx_doubleValueForKey:key defaultValue:0];
}

- (double)yx_doubleValueForKey:(id<NSCopying>)key defaultValue:(double)defaultValue {
    id value = self[key];
    
    if (value == [NSNull null] || value == nil) {
        return defaultValue;
    } else {
        return [value doubleValue];
    }
}

- (NSDictionary *)yx_dictionaryValueForKey:(id<NSCopying>)key {
    NSObject *obj = self[key];
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)obj;
    }
    return nil;
}

- (NSArray *)yx_arrayValueForKey:(id<NSCopying>)key {
    NSObject *obj = self[key];
    if (obj && [obj isKindOfClass:[NSArray class]]) {
        return (NSArray *)obj;
    }
    return nil;
}

- (time_t)yx_timeValueForKey:(id<NSCopying>)key {
    return [self yx_timeValueForKey:key defaultValue:0];
}

- (time_t)yx_timeValueForKey:(id<NSCopying>)key defaultValue:(time_t)defaultValue {
    id timeObject = self[key];
    if ([timeObject isKindOfClass:[NSNumber class]]) {
        NSNumber *n = (NSNumber *)timeObject;
        CFNumberType numberType = CFNumberGetType((__bridge CFNumberRef)n);
        NSTimeInterval t;
        if (numberType == kCFNumberLongLongType) {
            t = [n longLongValue] / 1000;
        }
        else {
            t = [n longValue];
        }
        return t;
    }
    else if ([timeObject isKindOfClass:[NSString class]]) {
        NSString *stringTime   = timeObject;
        if (stringTime.length == 13) {
            long long llt = [stringTime longLongValue];
            NSTimeInterval t = llt / 1000;
            return t;
        }
        else if (stringTime.length == 10) {
            long long lt = [stringTime longLongValue];
            NSTimeInterval t = lt;
            return t;
        }
        else {
            if (!stringTime || (id)stringTime == [NSNull null]) {
                stringTime = @"";
            }
            struct tm created;
            time_t now;
            time(&now);
            
            if (stringTime) {
                if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
                    strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
                }
                return mktime(&created);
            }
        }
    }
    return defaultValue;
}

@end
