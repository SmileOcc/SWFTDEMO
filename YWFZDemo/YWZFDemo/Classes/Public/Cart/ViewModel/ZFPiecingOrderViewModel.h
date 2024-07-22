//
//  ZFPiecingOrderViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/9/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFGoodsModel.h"

@interface ZFPiecingOrderViewModel : NSObject

/**
 * 购物车-凑单商品列表标签页
 */
+ (void)requestPiecingOrderData:(NSString *)price_index
                 finishedHandle:(void (^)(NSDictionary *resultDict))finishedHandle;

/**
 * 请求精选商品列表 (从deeplink进来)
 */
+ (void)requestHandpickGoodsList:(NSString *)goodsIDs
                      completion:(void (^)(NSArray<ZFGoodsModel *> *goodsModelArray))completion;

@end
