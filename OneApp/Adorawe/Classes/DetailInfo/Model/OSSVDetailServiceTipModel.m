//
//  OSSVDetailServiceTipModel.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailServiceTipModel.h"


@implementation OSSVDetailServiceTipModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"titleString"  : @"title",
             @"contentString": @"content",
             @"titleExt"     : @"titleExt",
             @"contentExt"   : @"contentExt"
           };
}


// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"titleString",
             @"contentString",
             @"titleExt",
             @"contentExt"
              ];
}

@end
