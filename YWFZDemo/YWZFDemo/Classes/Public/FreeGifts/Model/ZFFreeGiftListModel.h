//
//  ZFFreeGiftListModel.h
//  ZZZZZ
//
//  Created by YW on 2018/5/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFFreeGiftGoodsModel.h"

@interface ZFFreeGiftListModel : NSObject

@property (nonatomic, copy) NSString                                        *title;
@property (nonatomic, copy) NSString                                        *sub_title;
@property (nonatomic, copy) NSString                                        *diff_amount;

@property (nonatomic, strong) NSArray<ZFFreeGiftGoodsModel *>               *goods_list;

@end
