//
//  OSSVCategorysSpecialListsAip.h
// XStarlinkProject
//
//  Created by odd on 2020/9/15.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCategorysSpecialListsAip : OSSVBasesRequests

- (instancetype)initCategorySpecial:(NSString *)specialId;

- (instancetype)initWithCustomeId:(NSString *)customId type:(NSString *)type page:(NSInteger)pageIndex;
@end

NS_ASSUME_NONNULL_END
