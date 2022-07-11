//
//  OSSVGoogleeMapAddresseCollectAip.h
// XStarlinkProject
//
//  Created by Kevin on 2021/4/24.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVGoogleeMapAddresseCollectAip : OSSVBasesRequests

- (instancetype)initGoogleMapAddressWithCountryCode:(NSString *)countryCode
                                        countryName:(NSString *)countryName
                                        proviceName:(NSString *)proviceName
                                           cityName:(NSString *)cityName
                                           latitude:(NSString *)latitude
                                          longitude:(NSString *)longitude
                                            address:(NSString *)addressDetail
                                           areaName:(NSString *)areaName;
@end

NS_ASSUME_NONNULL_END
