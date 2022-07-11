//
//  OSSVAccountePayeMyOrdersAip.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVAccountePayeMyOrdersAip : OSSVBasesRequests
- (instancetype)initWithOrderId:(NSString*)orderId;
@end
