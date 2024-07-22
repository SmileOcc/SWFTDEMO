//
//  ZFCommunityChannelModel.m
//  ZZZZZ
//
//  Created by YW on 2018/11/23.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityChannelModel.h"

@implementation ZFCommunityChannelModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"data"          : [ZFCommunityChannelItemModel class]
             };
}
@end



@implementation ZFCommunityChannelItemModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"idx"   : @"id" };
}


@end


