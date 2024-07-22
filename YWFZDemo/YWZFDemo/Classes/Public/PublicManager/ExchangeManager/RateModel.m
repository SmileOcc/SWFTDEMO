//
//  RateModel.m
//  Yoshop
//
//  Created by YW on 16/6/1.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "RateModel.h"
#import <YYModel/YYModel.h>

#define RATE_CODE @"code"
#define RATE_RATE @"rate"
#define RATE_SYMBOL @"symbol"
#define RATE_EXPONET @"exponet"

@implementation RateModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init]; return [self yy_modelInitWithCoder:aDecoder];
}

-(NSString*) description{
    NSString* descriptionString = [NSString stringWithFormat:@"code:%@ \n rate:%@ \n symbol:%@ \n ", self.code, self.rate, self.symbol];
    
    return descriptionString;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"code"     : @"name",
             @"symbol"     : @"sign"
             };
}

@end
