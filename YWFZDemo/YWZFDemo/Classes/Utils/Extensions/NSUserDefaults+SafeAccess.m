//
//  NSUserDefaults+SafeAccess.m
//  iOS-Categories (https://github.com/shaojiankui/iOS-Categories)
//
//  Created by Jakey on 15/5/23.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import "NSUserDefaults+SafeAccess.h"
#import "NSDictionary+SafeAccess.h"

@implementation NSUserDefaults (SafeAccess)
+ (NSString *)stringForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:defaultName];
}

+ (NSArray *)arrayForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:defaultName];
}

+ (NSDictionary *)dictionaryForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:defaultName];
}

+ (NSData *)dataForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] dataForKey:defaultName];
}

+ (NSArray *)stringArrayForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] stringArrayForKey:defaultName];
}

+ (NSInteger)integerForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] integerForKey:defaultName];
}

+ (float)floatForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] floatForKey:defaultName];
}

+ (double)doubleForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:defaultName];
}

+ (BOOL)boolForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:defaultName];
}

+ (NSURL *)URLForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] URLForKey:defaultName];
}

#pragma mark - WRITE FOR STANDARD

+ (void)setZFObject:(id)value forKey:(NSString *)defaultName {
    if (!defaultName) return;
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        value = [(NSDictionary *)value deleteAllNullValue];
        
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *tmpValueArr = [NSMutableArray arrayWithArray:value];

        [(NSArray *)value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *notNullDic = [(NSDictionary *)obj deleteAllNullValue];
                if (notNullDic) {
                    [tmpValueArr replaceObjectAtIndex:idx withObject:notNullDic];
                }
                
            } else if ([obj isKindOfClass:[NSNull class]]) {
                [tmpValueArr replaceObjectAtIndex:idx withObject:@""];
            }
        }];
        value = tmpValueArr;
    }
    
    if (![value isKindOfClass:[NSNull class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:defaultName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - READ ARCHIVE FOR STANDARD

+ (id)arcObjectForKey:(NSString *)defaultName {
    if (!defaultName) return nil;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:defaultName] isKindOfClass:[NSData class]]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:defaultName]];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:defaultName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return nil;
    }
}

#pragma mark - WRITE ARCHIVE FOR STANDARD

+ (void)setArcObject:(id)value forKey:(NSString *)defaultName {
    if (!defaultName) return;
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        value = [(NSDictionary *)value deleteAllNullValue];
    }
    
    if (value && defaultName) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:value] forKey:defaultName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
