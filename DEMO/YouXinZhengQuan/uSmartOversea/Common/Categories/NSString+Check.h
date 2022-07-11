//
//  NSString+Check.h
//  uSmartOversea
//
//  Created by JC_Mac on 2018/11/29.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Check)

- (BOOL)isNotEmpty;
- (BOOL)isAllNumber;
- (BOOL)isAllNumberSpace;
+ (NSString *)removePreAfterSpace:(NSString *)str;

- (unsigned long long)versionValue;

- (BOOL)includeChinese;

- (int)systemVersionValue;
@end

