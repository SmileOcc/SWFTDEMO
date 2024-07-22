
//
//  ZFOrderReviewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/3/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderReviewModel.h"

@implementation ZFOrderReviewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.overallid = -1;
        self.userSelectStartCount = 5.f;
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"reviewList" : [ZFOrderReviewInfoModel class],
             @"goods_info" : [ZFOrderReviewGoodsModel class],
             };
}
@end
