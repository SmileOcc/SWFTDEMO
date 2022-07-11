//
//  OSSVFeedbacksReplaysModel.m
// XStarlinkProject
//
//  Created by odd on 2021/4/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVFeedbacksReplaysModel.h"

@implementation OSSVFeedbacksReplaysModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"replyMessage" : [STLFeedbackReplayMessageModel class],
             @"feedbackImg" : [STLFeedbackReplayImageModel class]
             };
}
@end


@implementation STLFeedbackReplayImageModel


@end

@implementation STLFeedbackReplayMessageModel


@end
