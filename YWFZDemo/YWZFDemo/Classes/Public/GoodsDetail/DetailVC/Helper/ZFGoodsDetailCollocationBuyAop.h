//
//  ZFGoodsDetailCollocationBuyAop.h
//  ZZZZZ
//
//  Created by YW on 2019/12/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnalyticsInjectManager.h"

@interface ZFGoodsDetailCollocationBuyAop : NSObject
<
    ZFAnalyticsInjectProtocol
>

- (instancetype)initAopWithSourceType:(ZFAppsflyerInSourceType)sourceType;

@end
