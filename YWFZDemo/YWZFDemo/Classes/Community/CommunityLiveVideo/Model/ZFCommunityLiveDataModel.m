//
//  ZFCommunityLiveDataModel.m
//  ZZZZZ
//
//  Created by YW on 2019/4/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveDataModel.h"

@implementation ZFCommunityLiveDataModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"live_list"             : [ZFCommunityLiveListModel class],
             @"end_live_list"             : [ZFCommunityLiveListModel class],
             };
}
@end
