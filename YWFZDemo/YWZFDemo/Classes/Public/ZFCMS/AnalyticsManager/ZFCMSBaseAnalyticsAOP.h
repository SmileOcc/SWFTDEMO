//
//  ZFCMSBaseAnalyticsAOP.h
//  ZZZZZ
//
//  Created by YW on 2019/6/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFAppsflyerAnalytics.h"
#import "ZFAnalyticsExposureSet.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ZFAnalyticsAOPSource) {
    ZFAnalyticsAOPSourceDefault = 0,
    /**首页*/
    ZFAnalyticsAOPSourceHome,
    /**社区首页*/
    ZFAnalyticsAOPSourceCommunityHome,
    /**个人中心*/
    ZFAnalyticsAOPSourceAccount,
    /**商品详情*/
    ZFAnalyticsAOPSourceGoodsDetail,
};

@interface ZFCMSBaseAnalyticsAOP : NSObject

/**自定义id*/
@property (nonatomic, copy) NSString                  *idx;
/**来源*/
@property (nonatomic, assign) ZFAnalyticsAOPSource    source;
@property (nonatomic, copy) NSString                  *sourceKey;

@property (nonatomic, copy) NSString                  *impressionList;
@property (nonatomic, copy) NSString                  *screenName;

@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;

/** 返回来源对应的key*/
+ (NSString *)sourceString:(ZFAnalyticsAOPSource)AOPSource;


//- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx;


/** 根据key+随机数生成标识*/
+ (NSString *)generateAnalyticsAopId:(NSString *)sourceKey;
@end

NS_ASSUME_NONNULL_END
