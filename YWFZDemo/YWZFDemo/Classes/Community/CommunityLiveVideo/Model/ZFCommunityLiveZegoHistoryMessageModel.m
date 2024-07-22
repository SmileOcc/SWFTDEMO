//
//  ZFCommunityLiveZegoHistoryMessageModel.m
//  ZZZZZ
//
//  Created by YW on 2019/8/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveZegoHistoryMessageModel.h"

@implementation ZFCommunityLiveZegoHistoryMessageModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"list"             : [ZFZegoMessageInfo class]
             };
}
@end
