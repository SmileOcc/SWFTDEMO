//
//  OSSVDetailPictureArrayModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailPictureArrayModel.h"

@implementation OSSVDetailPictureArrayModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
//             @"goodsSmallImg" : @"goods_thumb",
             @"goodsImg"        : @"goods_img",
             @"goodsBigImg"     : @"goods_original"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
//             @"goodsSmallImg",
             @"goodsImg",
             @"goodsBigImg",
             @"img_width",
             @"img_height"
             ];
}

@end
