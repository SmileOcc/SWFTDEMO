//
//  ZFPiecingOrderModel.h
//  ZZZZZ
//
//  Created by YW on 2018/9/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFPiecingOrderPriceModel : NSObject

@property (nonatomic, strong) NSString *priceSectionID; //价格区间列表id
@property (nonatomic, strong) NSString *number; //价格区间列表
@property (nonatomic, strong) NSString *start_price; //开始价格区间
@property (nonatomic, strong) NSString *end_price; //结束价格区间
@property (nonatomic, assign) BOOL checked; //是否选中该标签
@end
