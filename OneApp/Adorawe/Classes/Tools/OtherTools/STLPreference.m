//
//  STLPreference.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/22.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLPreference.h"

@implementation STLPreference
+(NSUserDefaults *)store{
    return [NSUserDefaults standardUserDefaults];
}


+(void)setObject:(id)object key:(NSString *)key{
    [self.store setObject:object forKey:key];
    [self.store synchronize];
}
+(id)objectForKey:(NSString *)key{
    return [self.store objectForKey:key];
}

+(void)setIsFirstIntoDetails:(BOOL)value{
    NSString *key = [NSString stringWithFormat:@"isFirstIntoDetails_%@",OSSVAccountsManager.sharedManager.device_id];
    [self setObject:value ? @"YES" : @"NO" key:key];
    [self.store synchronize];
}

+(BOOL)isFirstIntoDetails{
    NSString *key = [NSString stringWithFormat:@"isFirstIntoDetails_%@",OSSVAccountsManager.sharedManager.device_id];
    id savedValue = [self objectForKey:key];
    return  !savedValue ?  YES : [savedValue isEqualToString:@"YES"];
}


@end
