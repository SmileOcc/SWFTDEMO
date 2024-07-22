//
//  ZFOrderReviewApi.h
//  ZZZZZ
//
//  Created by YW on 2018/3/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SYBaseRequest.h"

@interface ZFOrderReviewApi : SYBaseRequest

- (instancetype)initWithOrderId:(NSString *)orderId goodsId:(NSString *)goodsId;

@end
