//
//  CountryListModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CountryListModel.h"
#import "CountryModel.h"

#define COUNTRY_KEY @"key"
#define COUNTRY_LIST @"countryList"

@implementation CountryListModel
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.key forKey:COUNTRY_KEY];
    [aCoder encodeObject:self.countryList forKey:COUNTRY_LIST];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.key = [aDecoder decodeObjectForKey:COUNTRY_KEY];
        self.countryList = [aDecoder decodeObjectForKey:COUNTRY_LIST];
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"countryList" : @"country_list"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"countryList" : [CountryModel class]
             };
}

+ (NSArray *)modelPropertyWhitelist {
    return @[@"key",@"countryList"];
}
@end
