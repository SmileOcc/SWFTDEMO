//
//  OSSVChecksReviewssModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVChecksReviewssModel.h"

@implementation OSSVChecksReviewssModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"orderId" : @"order_id",@"rateCount" : @"rate_overall",@"addTime" : @"add_time"};
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[@"orderId",@"content",@"rateCount",@"addTime",@"reviewPic", @"nickname", @"avatar"];
}

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"reviewPic" : [NSDictionary class]};
}

@end
