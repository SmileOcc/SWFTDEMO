//
//  ZFOrderRefundApi.h
//  ZZZZZ
//
//  Created by YW on 2018/4/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface ZFOrderRefundApi : SYBaseRequest
- (instancetype)initWithOrderSn:(NSString *)orderSn;
@end
