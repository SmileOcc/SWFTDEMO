//
//  RateModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RateModel : NSObject<NSCoding>

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *symbol;
/**
 *  0 代表 精度可选数据仅为0， 所有的价格都要取整
 *  2 代表 货币精度是2, 所有的价格都要保留到小数点后两位
 */
//这两个暂时没用了
@property (nonatomic, copy) NSString *exponent;
@property (nonatomic, copy) NSString *rate;

@property (nonatomic, assign) NSInteger is_default;


@end
