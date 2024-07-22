//
//  ZFCommunityHotTopicModel.h
//  ZZZZZ
//
//  Created by YW on 2019/10/16.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZFCommunityHotTopicPicModel;

@interface ZFCommunityHotTopicModel : NSObject

@property (nonatomic, copy) NSString *idx;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *hot_content;
@property (nonatomic, copy) NSString *activity_content;
@property (nonatomic, copy) NSString *activity_start_time;
@property (nonatomic, copy) NSString *activity_end_time;

@property (nonatomic, strong) ZFCommunityHotTopicPicModel *pic;

@property (nonatomic, assign) BOOL isMark;

@end


@interface ZFCommunityHotTopicPicModel : NSObject

@property (nonatomic, copy) NSString *small_pic;
@property (nonatomic, copy) NSString *origin_pic;
@property (nonatomic, copy) NSString *big_pic;
@property (nonatomic, copy) NSString *small_pic_height;
@property (nonatomic, copy) NSString *small_pic_width;
@property (nonatomic, copy) NSString *big_pic_height;
@property (nonatomic, copy) NSString *big_pic_width;

@end
