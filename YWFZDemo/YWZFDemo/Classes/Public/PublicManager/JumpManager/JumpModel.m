//
//  JumpModel.m
//  ZZZZZ
//
//  Created by DBP on 16/10/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "JumpModel.h"
#import <YYModel/YYModel.h>

@implementation JumpModel

- (instancetype)init{
    self = [super init];
    if (self) {
        self.pushPtsModel = [[ZFPushPtsModel alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init]; return [self yy_modelInitWithCoder:aDecoder];
}

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"actionType"               : @"actionType",
             @"endTime"                  : @"endTime",
             @"bannerId"                 : @"id",
             @"imageURL"                 : @"image_url",
             @"isShare"                  : @"is_share",
             @"leftTime"                 : @"leftTime",
             @"name"                     : @"name",
             @"serverTime"               : @"serverTime",
             @"shareTitle"               : @"share_title",
             @"shareImageURL"            : @"share_img",
             @"shareLinkURL"             : @"share_link",
             @"shareDoc"                 : @"share_doc",
             @"goodsShopPrice"           : @"shop_price",
             @"startTime"                : @"startTime",
             @"url"                      : @"url"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist
{
    
    return  @[
              @"actionType",
              @"endTime",
              @"bannerId",
              @"imageURL",
              @"isShare",
              @"leftTime",
              @"name",
              @"serverTime",
              @"shareImageURL",
              @"shareTitle",
              @"shareLinkURL",
              @"shareDoc",
              @"goodsShopPrice",
              @"startTime",
              @"url",
              @"giftId",
              @"img_is_show",
              @"imgSrc",
              @"color"
              ];
}

@end

@implementation ZFPushPtsModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init]; return [self yy_modelInitWithCoder:aDecoder];
}

@end
