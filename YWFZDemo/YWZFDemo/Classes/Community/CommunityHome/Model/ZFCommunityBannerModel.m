//
//  ZFCommunityBannerModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityBannerModel.h"
#import <YYModel/YYModel.h>

@implementation ZFCommunityBannerModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init]; return [self yy_modelInitWithCoder:aDecoder];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{@"href_type"     :@"href_type",
             @"href_location" :@"href_location",
             @"key"           :@"key",
             @"title"         :@"title",
             @"image"         :@"image",
             @"cat_node"      :@"cat_node"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[ @"href_type",
              @"href_location",
              @"key",
              @"title",
              @"image",
              @"cat_node"];
}
@end
