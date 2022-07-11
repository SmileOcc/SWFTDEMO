//
//  OSSVTransporteSpliteAip.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/27.
//  Copyright © 2020 starlink. All rights reserved.
//  ------物流拆单 API-----

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVTransporteSpliteAip : OSSVBasesRequests
- (instancetype)initWithOrderNumber:(NSString *)orderNumber;
@end

NS_ASSUME_NONNULL_END
