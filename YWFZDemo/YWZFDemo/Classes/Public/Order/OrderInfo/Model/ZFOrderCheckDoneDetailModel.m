//
//  ZFOrderCheckDoneDetailModel.m
//  ZZZZZ
//
//  Created by YW on 26/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderCheckDoneDetailModel.h"

@implementation ZFOrderCheckDoneDetailModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hacker_point = [ZFHackerPointOrderModel new];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"hacker_point" : [ZFHackerPointOrderModel class],
             };
}

@end
