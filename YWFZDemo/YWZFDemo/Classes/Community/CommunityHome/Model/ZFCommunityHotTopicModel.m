//
//  ZFCommunityHotTopicModel.m
//  ZZZZZ
//
//  Created by YW on 2019/10/16.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHotTopicModel.h"

@implementation ZFCommunityHotTopicModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"idx"   : @"id" };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"pic" : [ZFCommunityHotTopicPicModel class]
             };
}
@end


@implementation ZFCommunityHotTopicPicModel

@end
