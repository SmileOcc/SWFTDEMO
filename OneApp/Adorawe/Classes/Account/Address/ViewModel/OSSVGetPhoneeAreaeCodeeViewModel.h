//
//  STLGetPhoneAreaCode.h
// XStarlinkProject
//
//  Created by Kevin on 2021/3/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVGetPhoneeAreaeCodeeViewModel : BaseViewModel

- (void)requestPhoneAreaCodeForCountryCodeWithParmater:(NSString *)countryCode completion:(void (^)(id))completion failure:(void (^)(id))failure;

@end

NS_ASSUME_NONNULL_END
