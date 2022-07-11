//
//  SeachApi.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVSearchAip : OSSVBasesRequests

@property (copy,nonatomic) NSString *deepLinkId;

- (instancetype)initWithSearchKeyWord:(NSString *)keyword page:(NSInteger)page pageSize:(NSInteger)pageSize;

@end
