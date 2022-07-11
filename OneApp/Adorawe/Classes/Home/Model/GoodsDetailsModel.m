//
//  GoodsDetailsModel.m
//  Yoshop
//
//  Created by huangxieyue on 16/6/2.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "GoodsDetailsModel.h"
#import "GoodsDetailsListModel.h"

@implementation GoodsDetailsModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"result" : [GoodsDetailsListModel class]
             };
}

+ (NSArray *)modelPropertyWhitelist {
    return  @[
              @"statusCode",
              @"result",
              @"message",
              ];
}

@end
