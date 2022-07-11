//
//  STLShareAndEarnApi.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/17.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface STLShareAndEarnApi : OSSVBasesRequests

- (instancetype)initWithType:(NSString *)type h_url:(NSString *)h_url sku:(NSString *)sku;

@end

NS_ASSUME_NONNULL_END
