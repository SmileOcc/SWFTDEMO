//
//  ZFFreeGiftGoodsModel.h
//  ZZZZZ
//
//  Created by YW on 2018/5/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFGoodsModel.h"

@interface ZFFreeGiftGoodsModel : ZFGoodsModel
@property (nonatomic, copy) NSString            *manzeng_id;
@property (nonatomic, assign) BOOL              is_full;
@property (nonatomic, assign) BOOL              is_added;
@end
