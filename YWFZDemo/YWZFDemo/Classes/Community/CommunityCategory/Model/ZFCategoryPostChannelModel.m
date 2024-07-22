//
//  ZFCategoryPostTitleModel.m
//  Zaful
//
//  Created by occ on 2018/8/15.
//  Copyright © 2018年 Zaful. All rights reserved.
//

#import "ZFCommunityCategoryPostChannelModel.h"

@implementation ZFCommunityCategoryPostChannelModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"channel_id"   : @"id",
              @"channel_description"   : @"description"
              };
}

@end
