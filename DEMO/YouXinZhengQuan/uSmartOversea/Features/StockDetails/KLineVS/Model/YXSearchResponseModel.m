//
//  YXSearchResponseModel.m
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/12/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXSearchResponseModel.h"
#import "YXSecu.h"

@implementation YXSearchResponseModel
+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"list": [YXSecu class]};
}

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"list": @"data.list",
             };
}
@end
