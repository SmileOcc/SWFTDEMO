//
//  ZFSkinModel.m
//  ZZZZZ
//
//  Created by YW on 2018/5/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSkinModel.h"

@implementation ZFSkinModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"lange": @"lang",
             @"ID": @"id",
             @"channelSelectedColor": @"channel_selected_color",
             @"channelTextColor": @"channel_text_color"
             };
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init]; return [self yy_modelInitWithCoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

@end



@implementation ZFLoadSkinModel


@end
