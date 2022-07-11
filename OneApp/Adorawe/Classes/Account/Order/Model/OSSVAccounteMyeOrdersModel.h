//
//  OSSVAccounteMyeOrdersModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVAccounteMyeOrdersModel : NSObject
@property (nonatomic,strong) NSArray *orderList; //订单列表
@property (nonatomic,assign) NSInteger totalCount;//订单总个数
@property (nonatomic,assign) NSInteger totalPage;//订单总页数
@property (nonatomic,assign) NSInteger pageSize;//每页返回总个数
@property (nonatomic,assign) NSInteger page;//当前页数
/// 0 默认流程A流程需要发送短信 1 B流程 需要多次确认
@property (nonatomic,copy) NSString *order_flow_switch;
/// 0 不展示订单列表顶部切换国家提示 1 展示
@property (nonatomic,copy) NSString *show_ip_change_tips;
@end
