//
//  CheckFbidApi.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface CheckFbidApi : OSSVBasesRequests
- (instancetype)initWithFbid:(NSString *)fbid token:(NSString *)token;
@end
