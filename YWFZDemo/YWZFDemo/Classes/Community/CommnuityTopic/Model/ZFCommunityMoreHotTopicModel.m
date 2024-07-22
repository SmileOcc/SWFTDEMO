
//
//  ZFCommunityMoreHotTopicModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityMoreHotTopicModel.h"

@implementation ZFCommunityMoreHotTopicModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"topicId"             :   @"id",
             @"siteVersion"         :   @"site_version",
             @"title"               :   @"title",
             @"content"             :   @"content",
             @"label"               :   @"label",
             @"labelStatus"         :   @"label_status",
             @"iosIndexpic"         :   @"ios_indexpic",
             @"iosListpic"          :   @"ios_listpic",
             @"iosDetailpic"        :   @"ios_detailpic",
             @"addTime"             :   @"add_time",
             @"updateTime"          :   @"update_time",
             @"number"              :   @"number",
             @"virtualNumber"       :   @"virtual_number",
             @"readNumber"          :   @"read_number",
             @"orderby"             :   @"orderby",
             @"isTopic"             :   @"is_topic",
             @"status"              :   @"status",
             @"joinNumber"          :   @"join_number"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"topicId" ,
             @"siteVersion",
             @"title",
             @"content",
             @"label",
             @"labelStatus",
             @"iosIndexpic",
             @"iosListpic",
             @"iosDetailpic",
             @"addTime",
             @"updateTime",
             @"number",
             @"virtualNumber",
             @"readNumber",
             @"orderby",
             @"isTopic",
             @"status",
             @"joinNumber",
             @"ios_orderpic"
             ];
}

@end
