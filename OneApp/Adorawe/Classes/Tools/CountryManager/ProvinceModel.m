//
//  ProvinceModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "ProvinceModel.h"

#define PROVINCE_ID @"provinceId"
#define PROVINCE_NAME @"provinceName"
#define PROVINCE_ISHADCITY @"isHasCity"

@implementation ProvinceModel
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.provinceId forKey:PROVINCE_ID];
    [aCoder encodeObject:self.provinceName forKey:PROVINCE_NAME];
    [aCoder encodeBool:self.isHasCity forKey:PROVINCE_ISHADCITY];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.provinceId = [aDecoder decodeObjectForKey:PROVINCE_ID];
        self.provinceName = [aDecoder decodeObjectForKey:PROVINCE_NAME];
        self.isHasCity = [aDecoder decodeBoolForKey:PROVINCE_ISHADCITY];
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"provinceId" : @"province_id",@"provinceName" : @"province_name",@"isHasCity":@"has_citys"};
}

+ (NSArray *)modelPropertyWhitelist {
    return @[@"provinceId",@"provinceName",@"isHasCity"];
}
@end
