//
//  STLThemeActivityGoodsApi.h
// XStarlinkProject
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVThemesActivtyGoodAip : OSSVBasesRequests

-(instancetype)initWithCustomeId:(NSString *)specialID type:(NSString *)type page:(NSInteger)page pageSize:(NSInteger)pageSize;
@end

NS_ASSUME_NONNULL_END
