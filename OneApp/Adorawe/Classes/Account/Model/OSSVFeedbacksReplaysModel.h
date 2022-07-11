//
//  OSSVFeedbacksReplaysModel.h
// XStarlinkProject
//
//  Created by odd on 2021/4/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STLFeedbackReplayMessageModel;
@class STLFeedbackReplayImageModel;

@interface OSSVFeedbacksReplaysModel : NSObject

@property (nonatomic,copy) NSString *feedbackType;
@property (nonatomic,copy) NSString *feedbackTypeName;
@property (nonatomic,copy) NSString *addTime;
@property (nonatomic,copy) NSString *feedbackContents;
@property (nonatomic,copy) NSString *userImg;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *listTime;
@property (nonatomic,strong) NSArray <STLFeedbackReplayImageModel*>*feedbackImg;


@property (nonatomic, strong) NSArray <STLFeedbackReplayMessageModel*> *replyMessage;

@end


@interface STLFeedbackReplayImageModel : NSObject

@property (nonatomic,copy) NSString *img_thumb;
@property (nonatomic,copy) NSString *img_original;
@property (nonatomic,copy) NSString *feedback_id;

@end



@interface STLFeedbackReplayMessageModel : NSObject

@property (nonatomic,copy) NSString *feedback_id;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *reply_user_name;
@property (nonatomic,copy) NSString *reply_user_id;
@property (nonatomic,copy) NSString *is_read;
@property (nonatomic,copy) NSString *reply_time;

@end
