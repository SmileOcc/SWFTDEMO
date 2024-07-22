//
//  ZFAccountGoodsListViewAop.h
//  ZZZZZ
//
//  Created by YW on 2019/11/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnalyticsInjectManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFAccountGoodsListViewAop : NSObject
<
    ZFAnalyticsInjectProtocol
>

- (instancetype)initAopWithSourceType:(ZFAppsflyerInSourceType)sourceType;

@end

NS_ASSUME_NONNULL_END
