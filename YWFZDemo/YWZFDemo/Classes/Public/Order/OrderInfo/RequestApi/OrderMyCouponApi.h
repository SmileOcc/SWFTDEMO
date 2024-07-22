//
//  OrderMyCouponApi.h
//  Dezzal
//
//  Created by 7FD75 on 16/8/18.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSStringUtils.h"

@interface OrderMyCouponApi : SYBaseRequest

-(instancetype)initWithCouponCode:(NSString *)code;

@end
