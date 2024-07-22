//
//  ZFCollectionPostAnalyticsAOP.h
//  ZZZZZ
//
//  Created by YW on 2019/6/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSBaseAnalyticsAOP.h"
#import "AnalyticsInjectManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCollectionPostAnalyticsAOP : ZFCMSBaseAnalyticsAOP
<
    ZFAnalyticsInjectProtocol
>

- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx;

@end

NS_ASSUME_NONNULL_END
