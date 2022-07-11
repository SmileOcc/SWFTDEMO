//
//  STLSaveFCMTokenApi.h
// XStarlinkProject
//
//  Created by odd on 2020/11/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVSaveFCMsTokenAip : OSSVBasesRequests

-(instancetype)initWithFCMParams:(NSDictionary *)fcmDic;
@end

NS_ASSUME_NONNULL_END
