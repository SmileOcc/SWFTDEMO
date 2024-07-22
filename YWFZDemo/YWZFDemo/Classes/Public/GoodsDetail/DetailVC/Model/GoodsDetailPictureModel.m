//
//  GoodsDetailPictureModel.m
//  Dezzal
//
//  Created by ZJ1620 on 16/8/1.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "GoodsDetailPictureModel.h"

@implementation GoodsDetailPictureModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"img_url"          : @"img_url",
             //@"thumb_url"        : @"thumb_url",
             //@"img_original"     : @"img_original",
             @"wp_image"         : @"wp_image",
             @"goods_img_app"    : @"goods_img_app"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"img_url",
             //@"thumb_url",
             //@"img_original",
             @"wp_image",
             @"goods_img_app"
             ];
}



@end
