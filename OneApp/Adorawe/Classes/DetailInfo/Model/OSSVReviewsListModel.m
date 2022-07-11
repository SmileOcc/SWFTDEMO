//
//  OSSVReviewsListModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVReviewsListModel.h"

@implementation OSSVReviewsListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
//             @"userName" : @"nickname",
//             @"time" : @"add_time",
//             @"star" : @"rate_overall",
//             @"imgList" : @"reviewPic"
        @"userName" : @"nick_name",
        @"time" : @"add_time",
        @"star" : @"rate_overall",
        @"imgList" : @"reviewPic"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"imgList" : [OSSVReviewsImageListModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"userName",
             @"content",
             @"time",
             @"star",
             @"avatar",
             @"imgList"
             ];
}

@end
