//
//  STLBindCountryModel.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLBindCountryModel.h"

@implementation STLBindCountryModel
+(NSDictionary<NSString *,id> *)modelCustomPropertyMapper{
    return @{
        @"countryId": @"id",
    };
}
@end
