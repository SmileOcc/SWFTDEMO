//
//  NSString+Check.m
//  uSmartOversea
//
//  Created by JC_Mac on 2018/11/29.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "NSString+Check.h"
#import "NSString+YYAdd.h"

@implementation NSString (Check)

- (BOOL)isNotEmpty {
    if ([self isKindOfClass:[NSString class]] && self.length > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)includeChinese
{
    for(int i=0; i< [self length];i++)
    {
        int a =[self characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

- (BOOL)isAllNumber {
    
    NSString *regex =@"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}

- (BOOL)isAllNumberSpace {
    NSString *regex =@"^[0-9\\s]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}

+ (NSString *)removePreAfterSpace:(NSString *)str {

    NSString *trimmedString = [str stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString;
}

- (unsigned long long)versionValue {
    NSArray<NSString *> *array = [self componentsSeparatedByString:@"."];
    NSAssert(array.count <= 3, @"version字符串格式不对");
    NSMutableString *valueString = [[NSMutableString alloc] initWithString:@""];
    [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.length < 3) {
            [valueString appendString:[NSString stringWithFormat:@"%03d",[obj intValue]]];
        } else {
            [valueString appendString:obj];
        }
    }];
    
    return [valueString unsignedLongLongValue];
}

- (int)systemVersionValue {
    NSArray<NSString *> *array = [self componentsSeparatedByString:@"."];
    NSAssert(array.count <= 3, @"systemVersion字符串格式不对");
    NSMutableString *valueString = [[NSMutableString alloc] initWithString:@""];
    [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 1 && obj.length < 2) {
            [valueString appendString:[NSString stringWithFormat:@"%02d",[obj intValue]]];
        } else if (idx == 2 && obj.length < 4) {
            [valueString appendString:[NSString stringWithFormat:@"%04d",[obj intValue]]];
        } else {
            [valueString appendString:obj];
        }
    }];
    
    return [valueString intValue];
}

@end
