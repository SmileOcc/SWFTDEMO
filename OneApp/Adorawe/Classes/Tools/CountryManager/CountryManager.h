//
//  CountryManager.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryManager : NSObject
/**
 *  国家信息本地存储
 */
+ (void)saveLocalCountry:(NSArray *)array;
/**
 *  获取国家列表
 */
+ (NSArray *)countryList;
@end
