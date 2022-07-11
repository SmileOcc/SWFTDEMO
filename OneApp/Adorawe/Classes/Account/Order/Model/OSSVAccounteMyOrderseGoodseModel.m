//
//  OSSVAccounteMyOrderseGoodseModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteMyOrderseGoodseModel.h"

@implementation OSSVAccounteMyOrderseGoodseModel

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"money_info" : [OSSVOrdereMoneyeInfoModel class],
    };
    
}

@end
