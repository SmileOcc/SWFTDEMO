//
//  OSSVWhatseAppSubscribeeAip.h
// XStarlinkProject
//
//  Created by Kevin on 2021/9/9.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVWhatseAppSubscribeeAip : OSSVBasesRequests
- (instancetype)initWithStatus:(NSString *)status phoneHead:(NSString *)phoneHead phone:(NSString *)phone;
@end

NS_ASSUME_NONNULL_END
