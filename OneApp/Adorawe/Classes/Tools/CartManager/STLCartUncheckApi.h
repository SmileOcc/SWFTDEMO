//
//  STLCartClearApi.h
// XStarlinkProject
//
//  Created by odd on 2021/1/20.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface STLCartUncheckApi : OSSVBasesRequests
- (instancetype)initWithCartsIds:(NSArray *)goodsIds;

@end

NS_ASSUME_NONNULL_END
