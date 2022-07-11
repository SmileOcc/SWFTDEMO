//
//  OSSVAccounteMyOrdersAip.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVAccounteMyOrdersAip : OSSVBasesRequests
- (instancetype)initWithPage:(NSInteger)page pageSize:(NSInteger)pageSize Status:(NSString *)status;
@end
