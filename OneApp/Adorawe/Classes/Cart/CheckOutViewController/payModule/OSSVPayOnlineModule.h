//
//  OSSVPayOnlineModule.h
// XStarlinkProject
//
//  Created by Kevin on 2020/12/16.
//  Copyright © 2020 starlink. All rights reserved.
//-------最新接入，web 支付----

#import <Foundation/Foundation.h>
#import "OSSVCheckOutPayModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVPayOnlineModule : NSObject
<
OSSVCheckOutPayModuleProtocol
>
@end

NS_ASSUME_NONNULL_END
