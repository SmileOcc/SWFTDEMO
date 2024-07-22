//
//  ZFGeshopNavtiveAOP.h
//  ZZZZZ
//
//  Created by YW on 2019/10/15.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//
//  Geshop原生专题Aop

#import <Foundation/Foundation.h>
#import "ZFAnalyticsInjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFGeshopNavtiveAOP : NSObject
<
    ZFAnalyticsInjectProtocol
>
@property (nonatomic, copy) NSString *nativeThemeId;
@property (nonatomic, copy) NSString *nativeThemeName;
@property (nonatomic, copy) NSString *selectedSort;

@end

NS_ASSUME_NONNULL_END
