//
//  DiscoveryApi.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVHomeDiscoverAip : OSSVBasesRequests

- (instancetype)initWithDiscoveryPage:(NSInteger)page pageSize:(NSInteger)pageSize channelId:(NSString *)channelid;

@end
