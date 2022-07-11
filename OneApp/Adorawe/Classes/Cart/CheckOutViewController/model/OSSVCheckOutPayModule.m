//
//  OSSVCheckOutPayModule.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCheckOutPayModule.h"

@implementation OSSVCheckOutPayModule

+(id<OSSVCheckOutPayModuleProtocol>)handleCheckOutPay:(NSString *)payCode
{
    id<OSSVCheckOutPayModuleProtocol>module = nil;
    if ([payCode isEqualToString:@"Cod"]) {
        module = [[OSSVCodPayModule alloc] init];
    } else {
        module = [[OSSVPayOnlineModule alloc] init];
    }
    return module;
}

@end
