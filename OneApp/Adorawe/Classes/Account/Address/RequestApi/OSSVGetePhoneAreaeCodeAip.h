//
//  STLGetPhoneAreaCode.h
// XStarlinkProject
//
//  Created by Kevin on 2021/3/2.
//  Copyright © 2021 starlink. All rights reserved.
//  -----根据国家简码获取区号

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVGetePhoneAreaeCodeAip : OSSVBasesRequests

- (instancetype)initGetPhoneAreaCodeForCountryCode:(NSString *)countryCode;

@end

NS_ASSUME_NONNULL_END
