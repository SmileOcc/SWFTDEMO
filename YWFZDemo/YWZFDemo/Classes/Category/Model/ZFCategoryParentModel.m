//
//  ZFCategoryParentModel.m
//  ZZZZZ
//
//  Created by YW on 2019/3/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCategoryParentModel.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"

@implementation ZFCategoryAttributes
@end


@implementation ZFCategoryTabContainer
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"tabContainerId"     : @"id",
              @"categoryIds"        : @"categories",
              @"categoryNames"      : @"cat_name"
    };
}

// 防止数据异常: 图片宽高比 - 宽
-(NSString *)imgWidth{
    if ([_imgWidth isEqualToString:@"0"] || ZFIsEmptyString(_imgWidth)) {
        if (_type == ZFSubCategoryModel_GoodsType) { // v455默认商品比例宽、高 3/4
            return @"3";
        }
        return @"920";//banner: 默认比例 920 : 336
    } else {
        CGFloat value = [_imgWidth floatValue];
        if (value < 0) {
            if (_type == ZFSubCategoryModel_GoodsType) {// v455默认商品比例宽、高 3/4
                return @"3";
            }
            return @"920";
        }
    }
    return _imgWidth;
}

// 防止数据异常: 图片宽高比 - 高
-(NSString *)imgHeight{
    if ([_imgHeight isEqualToString:@"0"] || ZFIsEmptyString(_imgHeight)) {
        if (_type == ZFSubCategoryModel_GoodsType) {// v455默认商品比例宽、高 3/4
            return @"4";
        }
        return @"336";//banner: 默认比例 920 : 336
    } else {
        CGFloat value = [_imgHeight floatValue];
        if (value < 0) {
            if (_type == ZFSubCategoryModel_GoodsType) {// v455默认商品比例宽、高 3/4
                return @"4";
            }
            return @"336";
        }
    }
    return _imgHeight;
}


@end


@implementation ZFCategoryTabNav
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"tabNavId"   : @"id" };
}
@end


@implementation ZFCategoryParentModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"parentId"   : @"id" };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"TabContainer"   : [ZFCategoryTabContainer class] };
}

@end


@implementation ZFSubCategorySectionModel

@end


