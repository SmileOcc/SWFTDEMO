//
//  RateModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "RateModel.h"
#define RATE_CODE @"code"
#define RATE_RATE @"rate"
#define RATE_SYMBOL @"symbol"
#define RATE_Exponet @"exponent"
#define RATE_IsDefault @"is_default"

@implementation RateModel

-(instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.code forKey:RATE_CODE];
    [aCoder encodeObject:self.rate forKey:RATE_RATE];
    [aCoder encodeObject:self.symbol forKey:RATE_SYMBOL];
    [aCoder encodeObject:self.exponent forKey:RATE_Exponet];
    [aCoder encodeInteger:self.is_default forKey:RATE_IsDefault];

}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.code = [aDecoder decodeObjectForKey:RATE_CODE];
        self.rate = [aDecoder decodeObjectForKey:RATE_RATE];
        self.symbol = [aDecoder decodeObjectForKey:RATE_SYMBOL];
        self.exponent = [aDecoder decodeObjectForKey:RATE_Exponet];
        self.is_default = [aDecoder decodeIntegerForKey:RATE_IsDefault];

    }
    return self;
}

//- (id)copyWithZone:(NSZone *)zone
//{
//    RateModel *copy = [[[self class] allocWithZone:zone] init];
//    copy.code = [self.code copy];
//    copy.rate = [self.rate copy];
//    copy.symbol = [self.symbol copy];
//    return copy;
//}
//- (id)mutableCopyWithZone:(NSZone *)zone
//{
//    RateModel *copy = [[[self class] allocWithZone:zone] init];
//    copy.code = [self.code mutableCopy];
//    copy.rate = [self.rate mutableCopy];
//    copy.symbol = [self.symbol mutableCopy];
//    return copy;
//}

-(NSString*) description{
    NSString* descriptionString = [NSString stringWithFormat:@"code:%@ \n rate:%@ \n symbol:%@ \n exponent:%@ \n is_default:%li", self.code, self.rate, self.symbol, self.exponent,(long)self.is_default];
    
    return descriptionString;
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[@"code",@"rate",@"symbol",@"exponent",@"is_default"];
}
@end
