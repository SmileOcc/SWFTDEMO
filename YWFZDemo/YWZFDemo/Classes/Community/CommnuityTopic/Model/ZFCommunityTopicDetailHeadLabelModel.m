//
//  ZFCommunityTopicDetailHeadLabelModel.m
//  ZZZZZ
//
//  Created by DBP on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailHeadLabelModel.h"

@implementation TopicDetailHeadActivityModel

@end


@implementation ZFCommunityTopicDetailHeadLabelModel

+ (CGFloat)iphoneTopSpace {
    //v4.4.0版本修改
    //return IPHONE_X_5_15 ? 34.0 : 0.0;
    return 0.0;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"topicLabelId"    :   @"id",
             @"content"         :   @"content",
             @"topicLabel"      :   @"label",
             @"labelStatus"     :   @"label_status",
             @"number"          :   @"number",
             @"virtualNumber"   :   @"virtual_number",
             @"joinNumber"      :   @"join_number",
             @"type"            :   @"type",
             @"title"           :   @"title",
             @"iosDetailpic"    :   @"ios_detailpic",
             @"tab_name"        :   @"tab_name",
             @"activity"        :   @"activity",
             @"liked_num"       :   @"liked_num",
             @"top_review"      :   @"top_review",
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"topicLabelId",
             @"content",
             @"topicLabel",
             @"labelStatus",
             @"number",
             @"virtualNumber",
             @"joinNumber",
             @"type",
             @"title",
             @"iosDetailpic",
             @"tab_name",
             @"activity",
             @"liked_num",
             @"top_review",
             ];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"activity"             : [TopicDetailHeadActivityModel class],
             @"top_review"           : [ZFCommunityTopicDetailListModel class]
             };
}


- (NSString *)countDownTimerKey {
    if (!_countDownTimerKey) {
        _countDownTimerKey = @"TopicDetailHeadLabelMode_DownTimerKey";
    }
    return _countDownTimerKey;
}
@end
