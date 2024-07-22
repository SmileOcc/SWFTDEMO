//
//  ZFGoodsTagModel.m
//  ZZZZZ
//
//  Created by YW on 27/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsTagModel.h"
#import <YYModel/YYModel.h>

@implementation ZFGoodsTagModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"tagColor"   : @"color",
             @"tagTitle"   : @"title"
             };
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init]; return [self yy_modelInitWithCoder:aDecoder];
}


@end
