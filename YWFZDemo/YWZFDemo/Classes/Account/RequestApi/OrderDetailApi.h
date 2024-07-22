//
//  OrderDetailApi.h
//  Dezzal
//
//  Created by 7FD75 on 16/8/12.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "SYBaseRequest.h"

@interface OrderDetailApi : SYBaseRequest

-(instancetype)initWithOrderId:(NSString *)orderId;

@end
