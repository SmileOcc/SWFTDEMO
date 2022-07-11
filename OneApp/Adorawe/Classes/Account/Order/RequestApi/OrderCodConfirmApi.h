//
//  OSSVOrdereCodeConfirmAip.h
// XStarlinkProject
//
//  Created by odd on 2020/9/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVOrdereCodeConfirmAip : STLBaseRequest

- (instancetype)initWithOrderId:(NSString *)orderId code:(NSString *)code addressId:(NSString *)addressId;

@end

NS_ASSUME_NONNULL_END
