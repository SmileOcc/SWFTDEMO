//
//  CartCodModel.h
//  ZZZZZ
//
//  Created by YW on 24/8/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CartCodModel : NSObject

/**
 * cod 运费
 */
@property (nonatomic, copy) NSString   *codFee;

/**
 * 购物车总价最大值
 */
@property (nonatomic, copy) NSString   *totalMax;


/**
 * 购物车总价最小值
 */
@property (nonatomic, copy) NSString   *totalMin;

@end
