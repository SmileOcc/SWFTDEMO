//
//  OSSVBaseeAnalyticAP.h
// XStarlinkProject
//
//  Created by odd on 2020/9/11.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVAnalyticInjectsManager.h"
#import "OSSVAnalyticInjectsProtocol.h"


#define kAnalyticsAOPSourceKey @"sourceKey"
#define kAnalyticsAOPSourceID @"sourceID"
#define kAnalyticsAOPSourceName @"sourceName"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVBaseeAnalyticAP : NSObject

@property (nonatomic, strong) NSMutableArray                *goodsAnalyticsSet;

/**来源*/
@property (nonatomic, assign) STLAppsflyerGoodsSourceType    source;
@property (nonatomic, copy) NSString                         *sourceKey;
@property (nonatomic, strong) NSMutableDictionary            *sourecDic;

@property (nonatomic, strong) id                               anyObject;
@property (nonatomic, weak) STLBaseCtrl                      *controller;
- (void)refreshDataSource;


@end

NS_ASSUME_NONNULL_END
