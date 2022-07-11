//
//  OSSVCheckOutPayModule.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVPayPalModule.h"
#import "OSSVCodPayModule.h"
#import "OSSVPayOnlineModule.h"
@interface OSSVCheckOutPayModule : NSObject

+(id<OSSVCheckOutPayModuleProtocol>)handleCheckOutPay:(NSString *)payCode;

@end
