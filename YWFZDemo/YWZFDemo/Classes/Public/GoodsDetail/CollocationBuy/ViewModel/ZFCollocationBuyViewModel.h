//
//  ZFCollocationBuyViewModel.h
//  ZZZZZ
//
//  Created by YW on 2019/8/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZFCollocationBuyModel;


@interface ZFCollocationBuyViewModel : NSObject

/**
 * 请求商品搭配购数据
 */
+ (NSURLSessionDataTask *)requestCollocationBuy:(NSString *)goods_sn
                                  showFirstPage:(BOOL)showFirstPage
                                     completion:(void (^)(ZFCollocationBuyModel *))completion;

@end
