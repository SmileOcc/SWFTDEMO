//
//  CartGoodsModel.h
//  ZZZZZ
//
//  Created by 7FD75 on 16/9/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckOutGoodListModel.h"

@interface CartGoodsModel : NSObject

@property (nonatomic, strong) NSArray<CheckOutGoodListModel *> *goods_list;

@property (nonatomic, copy) NSString *is_use_pcode_success;

@property (nonatomic, copy) NSString *pcode_msg;



@end
