//
//  ZFSearchImageModel.m
//  ZZZZZ
//
//  Created by YW on 8/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchImageModel.h"
#import "ZFSearchMetaModel.h"

@implementation ZFSearchImageModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"metaModel"        : @"metadata"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"metaModel" : [ZFSearchMetaModel class]
             };
}


@end
