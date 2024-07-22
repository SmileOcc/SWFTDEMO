//
//  ZFMyOrderListModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyOrdersModel.h"

@interface ZFMyOrderListModel : NSObject

@property (nonatomic, strong) NSMutableArray<MyOrdersModel *>       *data;
@property (nonatomic, copy)   NSString                              *contact_us;
@property (nonatomic, copy)   NSString                              *page;
@property (nonatomic, copy)   NSString                              *total_page;
@property (nonatomic, copy)   NSString                              *not_paying_order;
@property (nonatomic, copy)   NSString                              *order_tip;

@end
