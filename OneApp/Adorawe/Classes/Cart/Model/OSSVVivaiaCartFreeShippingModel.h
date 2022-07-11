//
//  OSSVVivaiaCartFreeShippingModel.h
//  Adorawe
//
//  Created by Kevin on 2021/11/15.
//  Copyright © 2021 starlink. All rights reserved.
//  ------用于V站 购物车顶部包邮文案

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVVivaiaCartFreeShippingModel : NSObject

//还差多少包邮
@property (nonatomic, copy) NSString *differ_amount;
//进度条百分比，只会是一个100及以内整数
@property (nonatomic, copy) NSString *percentage;
//包邮文案
@property (nonatomic, copy) NSString *text;
    
@end

NS_ASSUME_NONNULL_END
