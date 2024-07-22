//
//  RateModel.h
//  Yoshop
//
//  Created by YW on 16/6/1.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RateModel : NSObject<NSCoding>
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *rate;
@property (nonatomic, copy) NSString *symbol;
///新增取整精度字段 取值 0， 2
@property (nonatomic, assign) NSInteger exponet;
///千位分隔符
@property (nonatomic, copy) NSString *thousandSign;
///小数点符号
@property (nonatomic, copy) NSString *decimalSign;
///货币位置标识   1：左   2：右
@property (nonatomic, copy) NSString *position;
@end
