//
//  OSSVCreateOrderModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCreateOrderModel.h"

@implementation OSSVCreateOrderModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"orderList" : kResult
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"orderList" : [STLOrderModel class],
             };
}

@end

@implementation STLOrderModel

@end
