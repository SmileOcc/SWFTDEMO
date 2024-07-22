
//
//  ZFOrderReviewListModel.m
//  ZZZZZ
//
//  Created by YW on 2018/3/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderReviewListModel.h"
#import "ZFRequestModel.h"
#import "ZFPubilcKeyDefiner.h"

@implementation ZFOrderReviewListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"result" : @"goods",
             };
}


+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"result" : [ZFOrderReviewModel class],
             @"size" : [ZFOrderReviewListSizeModel class]
             };
}
@end


@implementation ZFOrderReviewListSizeModel

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"waist" : [ZFOrderSizeModel class],
             @"height" : [ZFOrderSizeModel class],
             @"hips" : [ZFOrderSizeModel class],
             @"bust" : [ZFOrderSizeModel class]
             };
}

@end
