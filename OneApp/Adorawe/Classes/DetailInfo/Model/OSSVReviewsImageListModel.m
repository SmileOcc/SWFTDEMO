//
//  OSSVReviewsImageListModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVReviewsImageListModel.h"

@implementation OSSVReviewsImageListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"smallPic" : @"small_pic",
             @"originPic" : @"origin_pic"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"smallPic",
             @"originPic"
             ];
}

@end
