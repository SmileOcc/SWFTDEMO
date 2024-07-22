//
//  ZFCommunityMessageListModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityMessageListModel.h"
#import "ZFCommunityMessageModel.h"

@implementation ZFCommunityMessageListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"messageList"    :   [ZFCommunityMessageModel class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"messageList"       : @"list",
             @"pageCount"        : @"pageCount",
             @"curPage"          : @"curPage",
             @"type"            : @"type"
             };
}
@end
