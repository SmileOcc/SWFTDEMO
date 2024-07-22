//
//  ZFCMSCouponModel.m
//  ZZZZZ
//
//  Created by YW on 2019/11/7.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSCouponModel.h"


@implementation ZFCMSCouponModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"idx" : @"id",};
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init]; return [self yy_modelInitWithCoder:aDecoder];
}

@end
