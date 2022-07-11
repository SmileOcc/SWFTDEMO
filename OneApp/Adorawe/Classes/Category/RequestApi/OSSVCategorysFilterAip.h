//
//  OSSVCategorysFilterAip.h
// XStarlinkProject
//
//  Created by odd on 2021/4/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCategorysFilterAip : OSSVBasesRequests

- (instancetype)initWithCategoriesFilterCatId:(NSString *)catId;

@end

NS_ASSUME_NONNULL_END
