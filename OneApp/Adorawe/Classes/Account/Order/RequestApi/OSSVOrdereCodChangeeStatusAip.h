//
//  OSSVOrdereCodChangeeStatusAip.h
// XStarlinkProject
//
//  Created by odd on 2020/10/21.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVOrdereCodChangeeStatusAip : OSSVBasesRequests

- (instancetype)initWithOrderId:(NSString *)orderId;

@end

NS_ASSUME_NONNULL_END
