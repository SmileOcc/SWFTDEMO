//
//  CountryManager.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CountryManager.h"

@implementation CountryManager
+ (void)saveLocalCountry:(NSArray *)array {
    NSMutableData *data = [[NSMutableData alloc] init];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:array forKey:kCountryKey];
    
    [archiver finishEncoding];
    
    [data writeToFile:[STL_PATH_DIRECTORY stringByAppendingPathComponent:kCountryName] atomically:YES];
}

+ (NSArray *)countryList {
    NSData *data = [[NSData alloc] initWithContentsOfFile:[STL_PATH_DIRECTORY stringByAppendingPathComponent:kCountryName]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *array = [unarchiver decodeObjectForKey:kCountryKey];
    [unarchiver finishDecoding];//一定不要忘记finishDecoding，否则会报错
    return array;
}
@end
