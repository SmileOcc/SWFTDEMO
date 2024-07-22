//
//  ZFLocationInfoModel.m
//  ZZZZZ
//
//  Created by YW on 2017/12/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFLocationInfoModel.h"

@implementation ZFLocationInfoModel
+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"name"     :        @"name",
             @"cid"      :        @"id",
             @"code"     :        @"code",
             @"pid"      :        @"parent_id",
             @"type"     :        @"type",
             @"name_ar"  :        @"name_ar",
             };
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self yy_modelInitWithCoder:aDecoder];
}
@end





@implementation ZFAddressLocationInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"address_components" : [ZFAddressLocationComponentsModel class],
             };
}

@end



@implementation ZFAddressLocationComponentsModel

@end
