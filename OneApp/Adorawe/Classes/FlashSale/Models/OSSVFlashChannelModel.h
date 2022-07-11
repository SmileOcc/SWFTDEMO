//
//  OSSVFlashChannelModel.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVFlashChannelModel : NSObject<YYModel>
@property (nonatomic, copy) NSString *activeId;
@property (nonatomic, copy) NSString *expireTime;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *timeLabel;
//0未开始   1进行中   2已结束
@property (nonatomic, copy) NSString *status;

///1.3.8
@property (nonatomic,assign) NSTimeInterval  start_time;
@property (nonatomic,copy) NSString         *date_label;
@property (nonatomic,copy) NSString         *calendar_tips;
@property (nonatomic,copy) NSString         *calendar_link;
@end

NS_ASSUME_NONNULL_END
