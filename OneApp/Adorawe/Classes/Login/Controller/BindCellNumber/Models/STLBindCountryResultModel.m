//
//  STLBindCountryResponseModel.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLBindCountryResultModel.h"

@implementation STLBindCountryResultModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{
        @"countries": STLBindCountryModel.class,
    };
}
@end
