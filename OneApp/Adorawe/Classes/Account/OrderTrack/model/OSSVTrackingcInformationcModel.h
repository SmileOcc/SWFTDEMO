//
//  OSSVTrackingcInformationcModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVTrackingcGoodListcModel.h"
#import "OSSVTrackingcMessagecModel.h"

@interface OSSVTrackingcInformationcModel : NSObject

@property (nonatomic, strong) NSArray *goodList; // 订单列表
@property (nonatomic, copy) NSString *shippingName; // 物流名字
@property (nonatomic, copy) NSString *shippingNumber; // 物流号
@property (nonatomic, strong) NSArray *tracking_detail; // 订单详细物流信息

@end
