//
//  STLCustomerThemeChannelGoodsApi.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.

#import "OSSVBasesRequests.h"

@interface OSSVCustomThemesChannelsGoodsAip : OSSVBasesRequests

-(instancetype)initWithCustomeId:(NSString *)customId sort:(NSString *)sort page:(NSInteger)pageIndex;

-(instancetype)initWithCustomeId:(NSString *)customId sort:(NSString *)sort type:(NSString *)type page:(NSInteger)pageIndex;
@end
