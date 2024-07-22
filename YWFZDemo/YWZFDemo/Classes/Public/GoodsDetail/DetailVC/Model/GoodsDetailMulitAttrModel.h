//
//  GoodsDetailMulitAttrModel.h
//  ZZZZZ
//
//  Created by YW on 2018/11/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsDetailMulitAttrInfoModel.h"
@interface GoodsDetailMulitAttrModel : NSObject
@property (nonatomic, copy) NSString        *name;
@property (nonatomic, strong) NSArray<GoodsDetailMulitAttrInfoModel *>       *value;
@end
