//
//  GoodsDetialSizeModel.m
//  Dezzal
//
//  Created by ZJ1620 on 16/8/1.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "GoodsDetialSizeModel.h"
#import "NSString+Extended.h"


@implementation ZFSizeTipsTextModel
@end


@implementation ZFSizeTipsArrModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"tipsTextModelArray"  : @"str_arr",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"tipsTextModelArray" : [ZFSizeTipsTextModel class]
             };
}

- (NSArray *)configuTipsTitleWidth {
    NSArray *textModelArray = [NSArray arrayWithArray:self.tipsTextModelArray];
    for (ZFSizeTipsTextModel *textModel in textModelArray) {
        CGSize size = [textModel.title textSizeWithFont:[UIFont systemFontOfSize:12]
                                      constrainedToSize:CGSizeMake(MAXFLOAT, 27) lineBreakMode:NSLineBreakByWordWrapping
                                         paragraphStyle:nil];
        CGFloat sideSpace = 8 * 2;
        textModel.titleWith = size.width + sideSpace <= 62 ? 62 : size.width + sideSpace;
    }
    return textModelArray;
}

@end



@implementation GoodsDetialSizeModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"goods_id"           : @"goods_id",
             @"attr_value"         : @"attr_value",
             @"is_click"           : @"is_click",
             @"data_tips"          : @"data_tips",
             @"sizeTipsArrModel"   : @"data_tips_arr",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"sizeTipsArrModel" : [ZFSizeTipsArrModel class]
             };
}

@end
