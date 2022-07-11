//
//  STLSearchRecommendApi.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/5/17.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVSearchsRecommendsAip : OSSVBasesRequests

- (instancetype)initWithSearchRecommendWithKeyword:(NSString *)keyword  Page:(NSInteger)page pageSize:(NSInteger)pageSize;

@end

NS_ASSUME_NONNULL_END
