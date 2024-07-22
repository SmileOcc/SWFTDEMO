//
//  ZFOrderDetailStructModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFOrderDeatailListModel.h"

typedef NS_ENUM(NSInteger, ZFOrderDetailStructType) {
    ZFOrderDetailStructTypeOrderNumber = 0,
    ZFOrderDetailStructTypePaymentInfo,
    ZFOrderDetailStructTypeAddress,
    ZFOrderDetailStructTypeGoodsInfo,
    ZFOrderDetailStructTypePriceInfo,
    ZFOrderDetailStructTypeGoodsHeader,
    ZFOrderDetailStructTypeBanner,
    ZFOrderDetailStructTypeOrderPartHint,
};

@interface ZFOrderDetailStructModel : NSObject

@property (nonatomic, assign, readonly) ZFOrderDetailStructType type;
@property (nonatomic, assign, readonly) NSInteger               cellsCount;

/** 绑一个商品模型, 只有
 *  type = ZFOrderDetailStructTypeGoodsInfo
 *  type = ZFOrderDetailStructTypeOrderNumber 时,才有值
 */
@property (nonatomic, strong) ZFOrderDetailChildModel           *childModel;

- (instancetype)initWithType:(ZFOrderDetailStructType)type cellsCount:(NSInteger)cellsCount;
@end
