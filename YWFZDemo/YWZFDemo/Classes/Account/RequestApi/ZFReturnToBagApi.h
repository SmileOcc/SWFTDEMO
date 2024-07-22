//
//  ZFReturnToBagApi.h
//  ZZZZZ
//
//  Created by YW on 2/1/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface ZFReturnToBagApi : SYBaseRequest

- (instancetype)initWithOrderID:(NSString *)orderID;

- (instancetype)initWithorderID:(NSString *)orderID forceId:(NSString *)forceId;

@end
