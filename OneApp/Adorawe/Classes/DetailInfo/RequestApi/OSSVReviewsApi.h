//
//  OSSVReviewsApi.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface OSSVReviewsApi : OSSVBasesRequests

- (instancetype)initWithSKU: (NSString *)sku spu:(NSString *)spu goodsID:(NSString *)goodsID page:(NSString *)page pageSize:(NSString *)pageSize;

@end
