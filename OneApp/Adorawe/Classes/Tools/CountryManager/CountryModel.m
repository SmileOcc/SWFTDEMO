//
//  CountryModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CountryModel.h"
#import "ProvinceModel.h"

#define COUNTRY_ID @"countryId"
#define COUNTRY_NAME @"countryName"
#define COUNTRY_PROVINCE @"province"
#define COUNTRY_CODE @"countryCode"
#define COUNTRY_ANDROID_CODE @"code"
#define COUNTRY_IOS_CODE @"code_name"
#define COUNTRY_PICTURE @"picture"
#define COUNTRY_FLAGURL @"flagURL"

@implementation CountryModel
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.countryId forKey:COUNTRY_ID];
    [aCoder encodeObject:self.countryName forKey:COUNTRY_NAME];
    [aCoder encodeObject:self.provinceList forKey:COUNTRY_PROVINCE];
    [aCoder encodeObject:self.countryCode forKey:COUNTRY_CODE];
    [aCoder encodeObject:self.androidCode forKey:COUNTRY_ANDROID_CODE];
    [aCoder encodeObject:self.iosCodeName forKey:COUNTRY_IOS_CODE];
    [aCoder encodeObject:self.picture forKey:COUNTRY_PICTURE];
    [aCoder encodeObject:self.flagURL forKey:COUNTRY_FLAGURL];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.countryId = [aDecoder decodeObjectForKey:COUNTRY_ID];
        self.countryName = [aDecoder decodeObjectForKey:COUNTRY_NAME];
        self.provinceList = [aDecoder decodeObjectForKey:COUNTRY_PROVINCE];
        self.countryCode = [aDecoder decodeObjectForKey:COUNTRY_CODE];
        self.androidCode = [aDecoder decodeObjectForKey:COUNTRY_ANDROID_CODE];
        self.iosCodeName = [aDecoder decodeObjectForKey:COUNTRY_IOS_CODE];
        self.picture = [aDecoder decodeObjectForKey:COUNTRY_PICTURE];
        self.flagURL = [aDecoder decodeObjectForKey:COUNTRY_FLAGURL];
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"countryId" : @"country_id",
             @"countryName" : @"country_name",
             @"provinceList" : @"province",
             @"countryCode":@"code",
             @"phoneHeadArr" : @"phone_head_arr",
             @"phoneRemainLength" : @"phone_remain_length",
             @"androidCode" : @"code",
             @"iosCodeName" : @"code_name",
             @"picture" : @"picture",
             @"country_code":@"country_code",
             @"flagURL":@"flagURL",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"provinceList" : [ProvinceModel class]
             };
}

+ (NSArray *)modelPropertyWhitelist {
    return @[@"countryId",@"countryName",@"provinceList",@"countryCode",@"phoneHeadArr",@"phoneRemainLength",@"androidCode",@"iosCodeName",@"picture",@"country_code",@"flagURL"];
}
@end
