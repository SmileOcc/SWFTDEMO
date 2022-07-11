//
//  OSSVAddresseCheckePhoneAip.h
// XStarlinkProject
//
//  Created by odd on 2020/10/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVAddresseCheckePhoneAip : OSSVBasesRequests

- (instancetype)initCheckPhone:(NSString *)phone countryId:(NSString *)countryId countryCode:(NSString *)countryCode;
@end

NS_ASSUME_NONNULL_END
