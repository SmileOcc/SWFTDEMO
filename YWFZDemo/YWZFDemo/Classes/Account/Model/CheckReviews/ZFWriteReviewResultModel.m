
//
//  ZFWriteReviewResultModel.m
//  ZZZZZ
//
//  Created by YW on 2018/3/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFWriteReviewResultModel.h"

@implementation ZFWriteReviewResultModel
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"review" : [ZFOrderReviewInfoModel class]
             };
}
@end
