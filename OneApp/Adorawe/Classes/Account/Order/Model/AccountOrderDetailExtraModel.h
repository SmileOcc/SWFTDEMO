//
//  OSSVAccounteOrdereDetailExtraeModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVAccounteOrdereDetailExtraeModel : NSObject

@property (nonatomic,copy) NSString *url;//西联支付汇款信息H5
@property (nonatomic,copy) NSString *method;//提交方式
@property (nonatomic,strong) NSDictionary *data;//提交的参数
@property (nonatomic,copy) NSString *coupon;//优惠券 编码
//@property (nonatomic,copy) NSString *orderAmount;//订单总额
@property (nonatomic,copy) NSString *orderShipping;//订单邮费
@property (nonatomic,copy) NSString *order_amount_new;//订单总额 美金 无单位

@end
