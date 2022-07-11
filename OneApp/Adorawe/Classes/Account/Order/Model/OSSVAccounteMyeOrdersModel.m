//
//  OSSVAccounteMyeOrdersModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteMyeOrdersModel.h"
#import "OSSVAccounteMyeOrdersListeModel.h"

@implementation OSSVAccounteMyeOrdersModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"pageSize" : @"page_size",
             @"orderList" : @"order_list",
             @"totalPage" : @"total_page",
             @"order_flow_switch":@"order_flow_switch",
             @"show_ip_change_tips":@"show_ip_change_tips",
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"orderList" : [OSSVAccounteMyeOrdersListeModel class]};
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[@"orderList",@"totalCount",@"pageSize",@"page",@"totalPage",@"order_flow_switch",@"show_ip_change_tips"];
}
@end
