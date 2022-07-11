//
//  STLHomeBannerTabGoodsApi.h
// XStarlinkProject
//
//  Created by odd on 2020/10/22.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVHomesMenuTabGoodAip : OSSVBasesRequests

-(instancetype)initWithCatId:(NSString *)catId channelId:(NSString*)channel_id page:(NSInteger)page;

@end

NS_ASSUME_NONNULL_END
