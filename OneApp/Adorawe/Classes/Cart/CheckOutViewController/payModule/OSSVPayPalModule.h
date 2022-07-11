//
//  OSSVPayPalModule.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVCheckOutPayModuleProtocol.h"

///目前支持PP支付，在线支付
@interface OSSVPayPalModule : NSObject
<
OSSVCheckOutPayModuleProtocol
>
@end
