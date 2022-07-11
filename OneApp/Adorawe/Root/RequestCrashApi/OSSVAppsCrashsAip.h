//
//  OSSVAppsCrashsAip.h
// XStarlinkProject
//
//  Created by Kevin on 2021/4/23.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVAppsCrashsAip : OSSVBasesRequests

- (instancetype)initWithReportAppCrashDeviceInfo:(NSString *)deviceInfo crashInfo:(NSString *)crashInfo;

@end

NS_ASSUME_NONNULL_END
