//
//  ZFCartGoodsModel.m
//  ZZZZZ
//
//  Created by YW on 2017/9/16.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCartGoodsModel.h"
#import "ZFMultAttributeModel.h"

@implementation ZFCartGoodsModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"tagsArray"             : @"tags"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"multi_attr"       : [ZFMultAttributeModel class],
             @"tagsArray"        : [ZFGoodsTagModel class]
             };
}

- (NSString *)cartSizeAttrTitle {
    if (!_cartSizeAttrTitle) {
        NSMutableString *colorString = [NSMutableString new];
        if (self.attr_color.length > 0
            && self.attr_size.length > 0) {
            [colorString appendFormat:@"%@/%@", self.attr_color, self.attr_size];
            
        } else if (self.attr_color.length > 0) {
            [colorString appendString:self.attr_color];
            
        } else if (self.attr_size.length > 0) {
            [colorString appendString:self.attr_size];
        }
        _cartSizeAttrTitle = colorString;
    }
    return _cartSizeAttrTitle;
}

- (BOOL)showMarketPrice
{
    if (self.price_type == 1 || self.price_type == 2 || self.price_type == 3 || self.price_type == 4 || self.price_type == 5) {
        return YES;
    }
    return NO;
}

@end
