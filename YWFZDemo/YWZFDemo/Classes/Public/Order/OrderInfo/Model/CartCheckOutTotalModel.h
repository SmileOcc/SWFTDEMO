//
//  CartCheckOutTotalModel.h
//  Dezzal
//
//  Created by 7FD75 on 16/8/6.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CartCheckOutTotalModel : NSObject

@property (nonatomic, copy) NSString *need_traking_number;

@property (nonatomic, copy) NSString *coupon_amount;

@property (nonatomic, copy) NSString *coupon_code;

@property (nonatomic, copy) NSString *discount_amount;

@property (nonatomic, copy) NSString *goods_price;

@property (nonatomic, copy) NSString *insure_fee;

@property (nonatomic, copy) NSString *saving;

@property (nonatomic, copy) NSString *activities_amount; // 满减优惠价格

@property (nonatomic, copy) NSString *student_discount_amount;  // 学生卡优惠价格

@end
