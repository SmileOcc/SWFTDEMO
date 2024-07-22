
//
//  ZFCartListModel.m
//  ZZZZZ
//
//  Created by YW on 2017/9/16.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCartListModel.h"
#import "ZFCartListResultModel.h"
#import "ZFRequestModel.h"
#import "ZFPubilcKeyDefiner.h"

@implementation ZFCartListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             ZFResultKey : [ZFCartListResultModel class],
             };
}


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"statusCode" : @"statusCode",
             @"msg" : @"msg",
             ZFResultKey : ZFResultKey,
             };
}
@end
