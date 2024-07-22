//
//  ZFCategoryWaterfallModel.m
//  ZZZZZ
//
//  Created by YW on 2018/8/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityCategoryPostModel.h"

@implementation ZFCommunityCategoryPostModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"cat_id"   : @"id",
              @"cat_description"   : @"description"
              };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"sonList"             : [ZFCommunityCategoryPostChannelModel class]
             };
}
@end
