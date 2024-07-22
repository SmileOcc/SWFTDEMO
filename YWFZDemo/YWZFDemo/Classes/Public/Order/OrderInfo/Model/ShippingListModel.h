//
//  ShippingListModel.h
//  Dezzal
//
//  Created by 7FD75 on 16/8/6.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShippingListModel : NSObject

@property (nonatomic, copy) NSString *iD;
@property (nonatomic, copy) NSString *ship_desc;
@property (nonatomic, copy) NSString *ship_name;
@property (nonatomic, copy) NSString *ship_price;
@property (nonatomic, copy) NSString *ship_save;
@property (nonatomic, copy) NSString *sort_order;
@property (nonatomic, copy) NSString *total_ship_price;
@property (nonatomic, copy) NSString *default_select; // 默认选中物流方式
@property (nonatomic, copy) NSString *is_cod_ship; // 货到付款对应的物流方式
@property (nonatomic, copy) NSString *ship_tips; // 偏远运费提示语
//@property (nonatomic, copy) NSString *
@end
