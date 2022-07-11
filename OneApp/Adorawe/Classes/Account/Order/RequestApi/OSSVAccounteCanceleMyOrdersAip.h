//
//  OSSVAccounteCanceleMyOrdersAip.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVAccounteCanceleMyOrdersAip : OSSVBasesRequests
- (instancetype)initWithOrderId:(NSString*)orderId;
@end
